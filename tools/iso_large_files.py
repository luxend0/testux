#!/usr/bin/env python3
"""List files of 4 GiB or more inside remote ISO images, without downloading them.

Usage: tools/iso_large_files.py [catalog.json | ISO URL ...]

Bare-metal boot copies the ISO contents to a FAT32 partition, which cannot hold a file of
4 GiB or more. This reads the ISO 9660 directory tree through HTTP range requests (a few
MB per image) and prints every such file. Files that big are stored as several extents
("multi-extent" records), which are added up per file.
"""

import json
import struct
import sys
import urllib.request
from pathlib import Path

SECTOR = 2048
CHUNK = 64 * 1024
FAT32_LIMIT = 4 * 1024**3
USER_AGENT = "testux-iso-check/1 (+https://github.com/luxend0/testux)"


class RemoteImage:
    """Random access to an image over HTTP range requests, cached in 64 KiB chunks."""

    def __init__(self, url):
        request = urllib.request.Request(url, method="HEAD", headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(request, timeout=30) as response:
            self.url = response.geturl()  # resolve mirror redirects once
        self.chunks = {}

    def chunk(self, index):
        if index not in self.chunks:
            start = index * CHUNK
            request = urllib.request.Request(self.url, headers={
                "User-Agent": USER_AGENT, "Range": f"bytes={start}-{start + CHUNK - 1}"})
            with urllib.request.urlopen(request, timeout=60) as response:
                if response.status != 206:
                    raise RuntimeError(f"{self.url}: server ignores range requests")
                self.chunks[index] = response.read()
        return self.chunks[index]

    def read(self, offset, size):
        data = b""
        while size > 0:
            index, skip = divmod(offset, CHUNK)
            piece = self.chunk(index)[skip:skip + size]
            if not piece:
                break
            data += piece
            offset += len(piece)
            size -= len(piece)
        return data


def records(directory):
    """Yields (name, extent, size, is_dir, more_extents_follow) for one directory extent."""
    pos = 0
    while pos < len(directory):
        length = directory[pos]
        if length == 0:  # records never span sectors, skip to the next one
            pos = (pos // SECTOR + 1) * SECTOR
            continue
        record = directory[pos:pos + length]
        extent, size = struct.unpack_from("<I", record, 2)[0], struct.unpack_from("<I", record, 10)[0]
        flags, name_length = record[25], record[32]
        name = record[33:33 + name_length]
        pos += length
        if name in (b"\x00", b"\x01"):  # "." and ".."
            continue
        yield name.decode("ascii", "replace").split(";")[0], extent, size, bool(flags & 2), bool(flags & 0x80)


def large_files(image):
    """Paths and sizes of all files >= 4 GiB in the image's primary ISO 9660 tree."""
    descriptor = image.read(16 * SECTOR, SECTOR)
    if descriptor[1:6] != b"CD001" or descriptor[0] != 1:
        raise RuntimeError("no ISO 9660 primary volume descriptor")
    root = descriptor[156:190]
    pending = [("", struct.unpack_from("<I", root, 2)[0], struct.unpack_from("<I", root, 10)[0])]
    seen, found = set(), []
    while pending:
        path, extent, size = pending.pop()
        if extent in seen:
            continue
        seen.add(extent)
        files, continued = [], False
        for name, child_extent, child_size, is_dir, more in records(image.read(extent * SECTOR, size)):
            if is_dir:
                pending.append((f"{path}/{name}", child_extent, child_size))
            elif continued:  # next extent of the previous file
                files[-1][1] += child_size
            else:
                files.append([f"{path}/{name}", child_size])
            continued = more and not is_dir
        found += [(name, total) for name, total in files if total >= FAT32_LIMIT]
    return found


def urls_from(arguments):
    if not arguments:
        arguments = [str(Path(__file__).resolve().parent.parent / "catalog" / "catalog.json")]
    for argument in arguments:
        if argument.endswith(".json"):
            catalog = json.loads(Path(argument).read_text(encoding="utf-8"))
            yield from ((d["id"], d["iso"]["url"]) for d in catalog["distros"])
        else:
            yield argument, argument


def main():
    failed = False
    for name, url in urls_from(sys.argv[1:]):
        try:
            files = large_files(RemoteImage(url))
        except Exception as error:  # report and keep going with the other images
            print(f"{name}: error: {error}")
            failed = True
            continue
        listing = ", ".join(f"{path} ({size / 1024**3:.2f} GiB)" for path, size in files)
        print(f"{name}: {listing or 'no file of 4 GiB or more'}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
