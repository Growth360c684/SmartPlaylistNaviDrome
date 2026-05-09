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

- **Hourly check**: A background cron job runs at the top of every hour.
- **Daily cycle**: If the current date differs from the stored date, Daily Mixes and On Repeat are regenerated.
- **Weekly cycle**: If the current ISO week differs from the stored week, all Weekly playlists (Discovery, Release Radar, Loved Mix, Artist Radios, Genre Radios) are regenerated.
- **Config change detection**: A hash of all config values is stored. Any change to settings triggers an immediate full refresh.
- **Smart selection**: Songs are chosen using a round-robin artist/album algorithm to ensure variety — no two consecutive tracks from the same album.
- **Auto-cleanup**: On every startup the plugin scans existing playlists, removes duplicates, deletes playlists for disabled features, and prunes excess slots when counts are reduced.

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
