# Smart Playlist Plugin for Navidrome

A WebAssembly plugin that automatically generates and manages curated smart playlists in your Navidrome library — inspired by Spotify's Daily Mixes, Release Radar, and Artist Radio features.

## Features

| Playlist | Refresh | Description |
|----------|---------|-------------|
| **Daily Mix 1–6** | Daily | Genre-aware mixes built from your recently played and frequent albums |
| **On Repeat** | Daily | Your top songs from your most-played artists |
| **Weekly Discovery** | Weekly | A fresh random selection from your full library |
| **Release Radar** | Weekly | Newest albums, prioritising artists you already know |
| **Your Loved Songs Mix** | Weekly | All your starred/liked songs in a random shuffle |
| **Artist Radio 1–N** | Weekly | One dedicated playlist per top frequent artist |
| **Genre Radio 1–N** | Weekly | One dedicated playlist per top genre by song count |

All playlists are automatically updated on schedule. Changing any configuration option triggers an immediate regeneration.

## How It Works

### WebAssembly sandbox

The plugin is written in Go and compiled to WebAssembly (`.wasm`) using TinyGo. Navidrome loads the `.wasm` file into a sandboxed runtime — the plugin cannot touch your filesystem, network, or memory unless Navidrome explicitly grants permission. That's why `manifest.json` declares permissions like `subsonicapi`, `kvstore`, and `scheduler` — those are the only doors into the outside world.

```
Go source → TinyGo compiler → plugin.wasm → bundled into smart_playlist.ndp → Navidrome loads it
```

### Entry points

Navidrome calls two exported functions inside the plugin:

- **`nd_on_init`** — runs once when the plugin loads. It checks whether playlists need generating right now (first run, config changed, or a day/week has rolled over) and registers an hourly cron schedule.
- **`nd_scheduler_callback`** — runs every hour on the registered schedule. It repeats the same date/config checks and regenerates only what has changed.

### Talking to Navidrome from inside the sandbox

WASM runs in isolation, so it can't call Navidrome functions directly. Instead, Navidrome exposes a set of **host functions** that the plugin imports at the WASM level:

```go
//go:wasmimport extism:host/user subsonicapi_call
func subsonicapi_call(ptr uint64) uint64

//go:wasmimport extism:host/user kvstore_get
func kvstore_get(ptr uint64) uint64
```

Each call works by passing a pointer to JSON in shared WASM memory and reading a JSON response back. The [Extism](https://extism.org/) PDK (`go-pdk`) handles the memory mechanics — `pdk.AllocateBytes` writes data into shared memory, and `pdk.FindMemory` reads the response out. The plugin uses four host functions:

| Host function | What it does |
|---|---|
| `subsonicapi_call` | Query the music library (search songs, create/update playlists) |
| `kvstore_get` / `kvstore_set` | Read and write persistent key-value storage (last update dates, config hash) |
| `config_get` / `config_getint` | Read user-configured settings from the plugin settings panel |
| `scheduler_schedulerecurring` | Register the hourly cron job |
| `users_getusers` | Fetch the admin username needed for Subsonic API calls |

### Scheduling and change detection

- **Hourly tick**: `nd_on_init` registers a cron (`0 0 * * * *`) so `nd_scheduler_callback` fires at the top of every hour.
- **Daily cycle**: If the stored date differs from today, Daily Mixes and On Repeat are regenerated.
- **Weekly cycle**: If the stored ISO week differs from the current week, all weekly playlists are regenerated.
- **Config change detection**: A hash of all config values is stored in the KV store. Any settings change causes an immediate full refresh regardless of the schedule.

### Playlist selection algorithm

Songs are picked using a round-robin artist/album algorithm — no two consecutive tracks from the same album — so mixes feel varied rather than clustered by artist.

### Auto-cleanup

On every `nd_on_init` the plugin scans existing playlists and:
- Removes duplicates (same base name, multiple entries)
- Deletes playlists for any toggled-off feature
- Prunes excess slots when counts are reduced (e.g. dropping Artist Radios from 5 to 3 deletes slots 4 and 5)
- Renames playlists in-place when the prefix changes

## Installation

### 1. Build the Plugin

```bash
docker compose up plugin-builder
```

This compiles the Go source to WebAssembly and packages it as `plugins/smart_playlist.ndp`.

### 2. Start Navidrome

```bash
docker compose up navidrome
```

### 3. Enable in the UI

1. Open the Navidrome Web UI at `http://localhost:4533`
2. Go to **Settings → Plugins**
3. Find **Smart Playlist** and toggle it **on**

Playlists will appear in your library within a few seconds.

## Configuration

All options are accessible from **Settings → Plugins → Smart Playlist**.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `prefix` | string | `✨ ` | Text/emoji prepended to every smart playlist name |
| `dailySize` | integer | `30` | Number of songs in each Daily Mix and On Repeat |
| `weeklySize` | integer | `25` | Number of songs in Weekly Discovery, Release Radar, and Loved Mix |
| `artistRadioSize` | integer | `30` | Number of songs in each Artist Radio playlist |
| `dailyMixCount` | integer (1–6) | `3` | How many Daily Mix playlists to create |
| `numArtistRadios` | integer (1–20) | `5` | How many Artist Radio playlists to create |
| `numGenreRadios` | integer (1–10) | `3` | How many Genre Radio playlists to create |
| `enableOnRepeat` | boolean | `true` | Toggle the On Repeat playlist |
| `enableReleaseRadar` | boolean | `true` | Toggle the Release Radar playlist |
| `enableLovedMix` | boolean | `true` | Toggle the Loved Songs Mix playlist |
| `enableWeeklyDiscovery` | boolean | `true` | Toggle the Weekly Discovery playlist |
| `enableArtistRadio` | boolean | `true` | Toggle all Artist Radio playlists |
| `enableGenreRadio` | boolean | `true` | Toggle all Genre Radio playlists |

## Cleanup Behaviour

The plugin performs a global cleanup on every startup:

- **Duplicates**: If multiple playlists share the same base name, all but the first are deleted.
- **Disabled features**: Playlists for any toggled-off feature are immediately deleted.
- **Reduced counts**: If you lower `numArtistRadios` from 5 to 3, slots 4 and 5 are deleted.
- **Prefix changes**: When the prefix changes the existing playlist is renamed in-place (no duplicate is created).

## Troubleshooting

Check Navidrome logs for plugin activity:

```bash
docker compose logs navidrome | grep "Smart Playlist:"
```

Common log lines:

- `Smart Playlist: Initializing...` — plugin started
- `Smart Playlist: Config changed, forcing refresh.` — settings were changed
- `Smart Playlist: Refreshing Daily Mixes...` — daily cycle triggered
- `Smart Playlist: Refreshing Weekly Mixes...` — weekly cycle triggered
- `Smart Playlist: Generating Artist Radio N for: <name>` — individual artist radio being built

## Building from Source

Requirements: Docker (no local Go or TinyGo installation needed).

```bash
# Build WASM and package plugin
docker compose up plugin-builder

# Rebuild after code changes
docker compose up --build plugin-builder
```

The output is `plugins/smart_playlist.ndp` — a zip archive containing `manifest.json` and `plugin.wasm`.
