# Catalog

`catalog.json` is the list of distros Testux offers. The app downloads it from `main` on
every start, so a merged change here reaches every user without a new release. The copy
built into the binary is only the offline fallback.

## Format

```jsonc
{
  "version": 1,
  "app": { "latest": "0.1.0", "url": "https://github.com/luxend0/testux/releases/latest" },
  "categories": [                      // the app's tabs, in display order
    { "id": "beginner", "title": { "en": "Beginner", "de": "Einsteiger" } }
  ],
  "checklist": [                       // shown for every distro
    {
      "id": "browser",
      "title":  { "en": "Open a website", "de": "Eine Webseite öffnen" },
      "detail": { "en": "...", "de": "..." }
    }
  ],
  "distros": [
    {
      "id": "linuxmint-cinnamon",      // stable, also names the cached ISO and test disk
      "name": "Linux Mint",
      "edition": "Cinnamon",           // optional
      "version": "22.2",
      "category": "beginner",          // id of an entry in "categories"
      "summary":     { "en": "...", "de": "..." },
      "description": { "en": "...", "de": "..." },
      "notes":       { "en": "...", "de": "..." },   // optional caveats
      "website": "https://linuxmint.com",
      "color": "#87cf3e",
      "desktop": "Cinnamon",           // one plain name, the Desktop filter matches it exactly
      "base": "Ubuntu",
      "releaseModel": "fixed",         // fixed | rolling
      "iso": {
        "url": "https://mirror.example/linuxmint-22.2-cinnamon-64bit.iso",
        "sha256": "",                  // either the hash itself ...
        "sha256Url": "https://mirror.example/sha256sum.txt",  // ... or a checksum listing
        "size": 2900000000             // bytes, used for progress and space checks
      },
      "secureBoot": true,              // boots with Secure Boot enabled
      "liveSession": true,             // false = installer only, no desktop to try
      "nvidiaReady": true,             // proprietary NVIDIA driver on the ISO or offered
      "minRamMb": 4096,
      "checklist": []                  // optional extras, same shape as above
    }
  ]
}
```

A catalog without `categories` is rejected, a distro whose `category` is not listed is
skipped. A category without distros is allowed.

The checksum listing is searched for the last path segment of `iso.url`. When it names a
different file but holds exactly one entry, that entry is used: "current" links such as
KDE neon's and openSUSE Tumbleweed's publish a listing that names the dated file the link
points to. Every text field that users read is localized; `en` is required, other
languages fall back to it.

`tools/check_catalog.py` verifies every URL and checksum listing. CI runs it weekly and on
every change to this directory.
