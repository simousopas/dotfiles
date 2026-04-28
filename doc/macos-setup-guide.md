# macOS setup guide
This guide targets macOS Tahoe but most of the settings are applicable to
previous versions too.

## Preparation
- Backup Brave's bookmarks and passwords.
- Backup any data in `~/Documents` and `~/Downloads`.
- Backup any code in `~/Developer` that wasn't pushed to git.
- Remove login and usage data (Aldent, Protonmail, Fastmail, Github, YouTube,
  Brave, Safari, Signal, WhatsApp, Spotify).
- Turn off _Find My_.
- Unpair Bluetooth peripherals.
- [Restore macOS firmware](https://support.apple.com/en-us/108900) on the host.

## Settings
- Don't connect to the Internet until instructed otherwise.
- Create a local account during the initial setup process.
- Remove default widgets on the Desktop.
- Configure _Accessibility_
  - Under _Zoom_, enable _Use keyboard shortcuts to zoom_.
  - Under _Pointer Control_, _Trackpad Options_, enable _Three Finger Drag_ and
    increase _Scroll speed_.
- Disable Software Updates.
- Configure _Mouse_/_Trackpad_
  - Increase mouse's tracking speed and set trackpad's to the maximum.
  - Enable all gestures.
- Configure _Network_
  - Manually set DNS servers for all interfaces
    - IPv4: `1.1.1.1` and `1.0.0.1`
    - IPv6: `2606:4700:4700::1111` and `2606:4700:4700::1001`
  - Disable Thunderbolt Bridge.
- Configure _Battery_
  - Set _Low Power Mode_ to _Only on Battery_.
  - Set charging limit to 80% and enable _Optimize Battery Charging_.
  - Enable _Optimize video streaming while on battery_.
- Set _Show scroll bars_ to _When scrolling_.
- Disable all Siri Suggestions integrations.
- Configure _Desktop & Dock_
  - Remove unnecessary icons from the Dock except for _Contacts_.
  - Reduce the size of the Dock.
  - Set _Minimized window animation_ to _Scale Effect_.
  - Enable auto hide/show the Dock.
  - Disable _Animate opening applications_.
  - Enable indicators for open applications.
  - Disable suggested/recent apps in Dock. 
  - Set _Click wallpaper to show desktop_ to _Only in Stage Manager_.
  - Disable Stage Manager and its recent apps.
  - Only show Widgets _On Desktop_ and _Always_ dim widgets.
  - Set _Prefer tabs when opening documents_ to _Always_.
  - Disable all dragging/tilling gestures.
  - Enable all options of _Mission Control_ options.
  - Set the top-right corner to show the Desktop when hit together with `Cmd`.
- Disable all Mac/iPad integrations and enable Night Shift.
- Configure _Menu Bar_ items.
- Disable all Spotlight integrations and results except for _Apps_.
- Set a static wallpaper.
- Set _Alert volume_ to 50% and disable the startup sound.
- Set a password to be required 5 seconds after the screen turns off.
- Configure _Privacy & Security_
  - Under _Location Services_, _System Services_, disable location access for
    _Suggestions & Search_, _Home_ and _Mac Analytics_. Also enable the location
    icon in Control Center.
  - Add _Full Disk Access_ permission to _Terminal_.
  - Add _App Management_ permission to _Terminal_.
  - Add _Developer Tools_ permission to _Terminal_.
  - Disable _Apple Intelligence Report_.
  - Disable _Background Security Improvements_.
- Configure _Keyboard_
  - Create 10 virtual desktops before opening the _Keyboard_ section.
  - Set the _Key repeat rate_ to fastest value.
  - Set the _Delay until repeat_ to shortest value.
  - Set the Globe key action to _Do Nothing_.
  - Disable all text input automations in _Input Sources_.
  - Remove all _Text Replacements_
  - Configure _Dock_ shortcuts.
  - Configure _Mission Control_ shortcuts.
  - Configure _Spotlight_ shortcuts.
  - Enable standard _F_ keys by default.
  - Assign _Escape_ to the _Caps Lock_ key. Do it to each keyboard.
- Configure _Finder_
  - _Show Path Bar_
  - _Finder Settings_
    - Show all items on the Desktop.
    - New Finder windows open at `$HOME`.
    - Enable _Open folders in tabs instead of new windows_.
    - Remove all tags.
    - Configure the Sidebar's items.
    - When performing a search: Search the current folder.
  - Re-order items in the side bar.
  - `Cmd+J` / Home and Applications
    - Always open and Browse in icon view.
    - Sort by name.
    - Icon size: 44x44.
    - Grid size: one mark less than the default.
    - Disable _Show item info_ and _Show icon preview_.
    - Enable _Show Library Folder_.
    - Press _Use as Defaults_.
  - `Cmd+J` / Desktop
    - Sort by kind.
    - Icon size: 44x44.
    - Text size: 12.
    - Label position: Right.
    - Enable _Show item info_.
    - Disable _Show icon preview_.
  - `Cmd+J` / Other
    - Always open and Browse in column view.
    - Group by kind. Sort by name.
    - Text size: 13.
    - Disable _Show icon preview_.
- Update folders in the Dock
  - Add _Documents_.
  - Set both _Documents_ and _Downloads_ to display as folder and view as list.
- Configure hostname, create folders and set Spotlight's privacy list
  - `sudo scutil --set HostName <hostname>.local`
  - `sudo scutil --set LocalHostName <hostname>`
  - `sudo scutil --set ComputerName <hostname>`
  - `mkdir -p ~/{Developer,Downloads/Safari,.cache,.config,.local,.ssh}`
  - Add `~/Developer` to the sidebar and set its layout.
  - Add the following folders to Spotlight's privacy list
    - `open /{opt,usr/local,Library,System/Library/Frameworks}`
    - `open ~/{Developer,Documents,Downloads,Library,.cache,.config,.local,.ssh}`
- Configure _Contacts_ app
  - _View_, _Hide Lists_.
  - Show First Name: _Before last name_.
  - Sort by _First Name_.
  - Address Format: _Portugal_
  - Delete my contact card.
  - Remove the Contacts app from the Dock.
- Connect to the Internet and configure iCloud
  - Disable sync for Stocks, Home, Wallet, Siri, Image Playground, Journal and
    Music Recognition.
  - Enable sync for _Messages in iCloud_.
  - Enable _Private Relay_.
  - Download and set a static wallpaper if it wasn't available before.
  - Logout from _Game Center_.
  - Enable _FireVault_ under _Privacy and Security_.
  - Review Siri Suggestions integrations under _Apple Intelligence and Siri_.
  - Review _Notifications_ settings.
  - Set Air Pods connection strategy to _When last connected to this Mac_.
  - Rename Touch ID fingers to something more descriptive.
- Configure Safari
  - _View_, _Show Status Bar_.
  - General
    - Safari opens with: _A new private window_.
    - New windows opens with: _Empty Page_.
    - New tabs opens with: _Empty Page_.
    - Homepage: `https://github.com/simousopas`.
    - File download location: `~/Downloads/Safari`.
    - Disable _Open "safe" files after downloading_.
  - Set Tab layout to _Compact_.
  - Disable _Using information from my contacts_ and _Credit cards_ in AutoFill.
  - Search
    - Search engine: _DuckDuckGo_.
    - Disable _Include search engine suggestions_.
    - Disable _Preload Top Hit in the background_.
    - Disable _Show Start Page_.
  - Disable _Warn when visiting a fraudulent website_.
  - Disable _Require Touch ID to view locked tabs_.
  - Enable _Save articles for offline reading automatically_.
  - Enable _Show features for web developers_.
  - Enable _Disable site-specific quirks_.
- Open and configure all 1st-party Apps.

## Development Environment and Installation
- Disable GateKeeper
  - `sudo spctl --global-disable`
  - Go to _Privacy & Security_ and enable _Allow applications from Anywhere_.
- Manually install the latest Command Line Tools from
  [Apple Developer](https://developer.apple.com/download/all).
- Install the SSH keys.
- `git clone git@github.com:simousopas/dotfiles` and  run `./bootstrap.sh`.  
  Manual password input will be required a couple of times during the process.
- Add _Developer Tools_ permission to _Ghostty_.
- Configure 3rd-party apps
  - Disable automatic updates for all apps whenever it's possible.
  - Enable _Voice Isolation_ for all apps that need access to the microphone.
  - Start by configuring _BetterDisplay_, _Mac Mouse Fix_ and _AltTab_.
  - Configure Docker
    - Review startup settings, resources, fs permissions and notifications.
    - Install the  _Disk Usage_, _Logs Explorer_ and _Resource Usage_ extensions.
  - Configure Brave
    - Review all default settings.
    - Enable the _Parallel downloading_ feature in `brave://flags`.
    - Delete all browsing data.
    - Configure microphone, camera and desktop access in `https://talk.brave.com`.
- Exit all apps run `bash etc/macos/scripts/toggle-application-lock.sh`

## Wrap up
- Review the settings of iCloud, Login Items and Siri Suggestions.
- Press `Cmd+Shift+5`, pick _Options_ and set `~/Documents/Captures` as the
  storage location.
- [Disable SIP](https://developer.apple.com/documentation/security/disabling-and-enabling-system-integrity-protection).
- Disable macOS services: `bash etc/macos/scripts/disable-services.sh`
- Open _Ghostty_ and run `purge all`
- Reboot and let the computer settle for some hours. Reboot once more after.

