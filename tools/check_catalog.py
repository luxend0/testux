#!/usr/bin/env python3
"""Validate catalog/catalog.json and check that every ISO and checksum listing is reachable.

Usage: tools/check_catalog.py [catalog.json] [--offline]

Exits non-zero when the schema is broken, an ISO URL does not answer with 200, or a
checksum listing does not name the ISO. Size drift above 10 % is only a warning.
"""

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.parse import unquote, urlparse

RELEASE_MODELS = {"fixed", "rolling"}
REQUIRED_TEXT = ("id", "name", "version", "website", "base")
COLOR = re.compile(r"^#[0-9a-fA-F]{6}$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")
SIZE_TOLERANCE = 0.10
TIMEOUT = 30
ATTEMPTS = 3  # mirror redirectors (Fedora's in particular) reset connections now and then
USER_AGENT = "testux-catalog-check/1 (+https://github.com/luxend0/testux)"


def localized_errors(value, where, required=True):
    if value is None and not required:
        return []
    if not isinstance(value, dict) or not str(value.get("en", "")).strip():
        return [f"{where}: needs a non-empty 'en' text"]
    return [f"{where}.{lang}: must be a string" for lang, text in value.items()
            if not isinstance(text, str)]


def checklist_errors(items, where):
    if not isinstance(items, list):
        return [f"{where}: must be a list"]
    errors = []
    for i, item in enumerate(items):
        if not isinstance(item, dict) or not item.get("id"):
            errors.append(f"{where}[{i}]: needs an id")
            continue
        errors += localized_errors(item.get("title"), f"{where}[{item['id']}].title")
        errors += localized_errors(item.get("detail"), f"{where}[{item['id']}].detail")
    return errors


def category_errors(categories):
    if not isinstance(categories, list) or not categories:
        return ["categories: must be a non-empty list"]
    errors, seen = [], set()
    for i, category in enumerate(categories):
        category_id = category.get("id") if isinstance(category, dict) else None
        if not category_id:
            errors.append(f"categories[{i}]: needs an id")
            continue
        if category_id in seen:
            errors.append(f"categories: duplicate id '{category_id}'")
        seen.add(category_id)
        errors += localized_errors(category.get("title"), f"categories[{category_id}].title")
    return errors


def listed_categories(catalog):
    categories = catalog.get("categories")
    if not isinstance(categories, list):
        return set()
    return {c.get("id") for c in categories if isinstance(c, dict)}


def distro_errors(distro, category_ids):
    where = distro.get("id") or "<distro without id>"
    errors = [f"{where}: missing '{key}'" for key in REQUIRED_TEXT if not distro.get(key)]
    if distro.get("category") not in category_ids:
        errors.append(f"{where}: category '{distro.get('category')}' is not listed in categories")
    if distro.get("releaseModel") not in RELEASE_MODELS:
        errors.append(f"{where}: releaseModel must be one of {sorted(RELEASE_MODELS)}")
    if not COLOR.match(str(distro.get("color", ""))):
        errors.append(f"{where}: color must look like #rrggbb")
    for key in ("summary", "description"):
        errors += localized_errors(distro.get(key), f"{where}.{key}")
    # Short labels: a plain string, or localized when the word itself needs translating.
    for key, required in (("desktop", True), ("edition", False)):
        value = distro.get(key)
        if isinstance(value, str):
            if required and not value.strip():
                errors.append(f"{where}: missing '{key}'")
        else:
            errors += localized_errors(value, f"{where}.{key}", required=required)
    errors += localized_errors(distro.get("notes"), f"{where}.notes", required=False)
    errors += checklist_errors(distro.get("checklist", []), f"{where}.checklist")
    for key in ("secureBoot", "liveSession", "nvidiaReady"):
        if not isinstance(distro.get(key), bool):
            errors.append(f"{where}: '{key}' must be true or false")
    if not isinstance(distro.get("bareMetal", True), bool):
        errors.append(f"{where}: 'bareMetal' must be true or false when present")
    elif distro.get("bareMetal") is False and not distro.get("notes"):
        errors.append(f"{where}: 'bareMetal': false needs notes explaining why")
    if not isinstance(distro.get("minRamMb"), int) or distro["minRamMb"] <= 0:
        errors.append(f"{where}: minRamMb must be a positive integer")

    iso = distro.get("iso") or {}
    if not str(iso.get("url", "")).startswith("https://"):
        errors.append(f"{where}: iso.url must be an https URL")
    sha256 = iso.get("sha256", "")
    if sha256 and not SHA256.match(sha256):
        errors.append(f"{where}: iso.sha256 must be 64 lowercase hex digits")
    if not sha256 and not str(iso.get("sha256Url", "")).startswith("https://"):
        errors.append(f"{where}: needs iso.sha256 or an https iso.sha256Url")
    if not isinstance(iso.get("size"), int) or iso["size"] <= 0:
        errors.append(f"{where}: iso.size must be a positive integer")
    return errors


def schema_errors(catalog):
    errors = []
    app = catalog.get("app") or {}
    if not app.get("latest") or not app.get("url"):
        errors.append("app: needs 'latest' and 'url'")
    errors += checklist_errors(catalog.get("checklist"), "checklist")
    errors += category_errors(catalog.get("categories"))
    category_ids = listed_categories(catalog)
    distros = catalog.get("distros")
    if not isinstance(distros, list) or not distros:
        return errors + ["distros: must be a non-empty list"]
    ids = [d.get("id") for d in distros]
    errors += [f"{i}: duplicate id" for i in sorted({i for i in ids if ids.count(i) > 1})]
    for distro in distros:
        errors += distro_errors(distro, category_ids)
    return errors


def request(url, method="GET", headers=None):
    headers = {"User-Agent": USER_AGENT, **(headers or {})}
    for attempt in range(1, ATTEMPTS + 1):
        try:
            return urllib.request.urlopen(
                urllib.request.Request(url, method=method, headers=headers), timeout=TIMEOUT)
        except urllib.error.HTTPError:
            raise  # a real answer from the server, retrying will not change it
        except (urllib.error.URLError, OSError):
            if attempt == ATTEMPTS:
                raise
            time.sleep(2 * attempt)


def remote_size(url):
    """Size of the file behind url in bytes, following redirects."""
    try:
        with request(url, "HEAD") as response:
            return int(response.headers.get("Content-Length", 0))
    except urllib.error.HTTPError as error:
        if error.code not in (403, 405, 501):
            raise
    # Some mirrors refuse HEAD; ask for the first byte and read the total from Content-Range.
    with request(url, headers={"Range": "bytes=0-0"}) as response:
        total = response.headers.get("Content-Range", "").rpartition("/")[2]
        return int(total) if total.isdigit() else int(response.headers.get("Content-Length", 0))


def find_sha256(listing, file_name):
    """Mirror of Checksum::findSha256 in the app, plus the single-entry rule."""
    entries = []
    for line in listing.splitlines():
        line = line.strip()
        bsd = re.match(r"^SHA256 \((.+)\) = ([0-9a-fA-F]{64})$", line)
        gnu = re.match(r"^([0-9a-fA-F]{64}) [ *]?(?:\./)?(.+)$", line)
        if bsd:
            entries.append((bsd.group(2).lower(), bsd.group(1)))
        elif gnu:
            entries.append((gnu.group(1).lower(), gnu.group(2).strip()))
        elif re.fullmatch(r"[0-9a-fA-F]{64}", line):
            entries.append((line.lower(), None))
    for sha256, name in entries:
        if name is not None and name.removeprefix("./") == file_name:
            return sha256
    # A bare hash, or a "current" link whose listing names the dated file it points to.
    return entries[0][0] if len(entries) == 1 else ""


def check_remote(distro):
    """Returns (errors, warnings) for one distro's download."""
    iso = distro["iso"]
    errors, warnings = [], []
    where = distro["id"]
    try:
        size = remote_size(iso["url"])
        if size and abs(size - iso["size"]) > iso["size"] * SIZE_TOLERANCE:
            warnings.append(f"{where}: catalog size {iso['size']} but server says {size}")
    except (urllib.error.URLError, OSError, ValueError) as error:
        errors.append(f"{where}: ISO not reachable: {error}")

    if not iso.get("sha256"):
        file_name = unquote(urlparse(iso["url"]).path.rsplit("/", 1)[-1])
        try:
            with request(iso["sha256Url"]) as response:
                listing = response.read(1 << 20).decode("utf-8", "replace")
            if not find_sha256(listing, file_name):
                errors.append(f"{where}: {file_name} is not listed in {iso['sha256Url']}")
        except (urllib.error.URLError, OSError) as error:
            errors.append(f"{where}: checksum listing not reachable: {error}")
    return errors, warnings


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    default = Path(__file__).resolve().parent.parent / "catalog" / "catalog.json"
    parser.add_argument("catalog", nargs="?", type=Path, default=default)
    parser.add_argument("--offline", action="store_true", help="only validate the schema")
    args = parser.parse_args()

    try:
        catalog = json.loads(args.catalog.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        sys.exit(f"cannot read {args.catalog}: {error}")

    errors = schema_errors(catalog)
    warnings = []
    if not errors and not args.offline:
        with ThreadPoolExecutor(max_workers=8) as pool:
            for distro_errors_, distro_warnings in pool.map(check_remote, catalog["distros"]):
                errors += distro_errors_
                warnings += distro_warnings

    for warning in warnings:
        print(f"warning: {warning}")
    for error in errors:
        print(f"error: {error}")
    count = len(catalog.get("distros") or [])
    print(f"{count} distros, {len(errors)} errors, {len(warnings)} warnings")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
