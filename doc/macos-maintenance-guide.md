# macOS maintenance guide
This guide targets macOS Tahoe but most of the guide, if not all of it, is
applicable to previous versions too.

## Preparation
- Check if there any updates for [MongoDB Tools](https://github.com/mongodb/mongo-tools/tags)
  and update `etc/scripts/install-mongo-utils.sh`.
- Enable `softwareupdated`.
  ```
  sudo launchctl enable system/com.apple.mobile.softwareupdated
  sudo launchctl enable system/com.apple.softwareupdated
  ```
- Reboot.
- Check for updates from Apple `softwareupdate --list`.
- Install updates from Apple
  - Regular install: `softwareupdate --install "<label>"`.
  - Update w/ restart: `sudo softwareupdate --restart --install "<label>"`.
- Reboot
- Install App Store update.
- Open 1st party apps and make sure they're working as intended.

## Updates
- Update dotfiles `./configure.sh`.
- Update hosts `bash etc/scripts/install-hosts.sh [--force-hostname <host>]`
- Update Azahar `bash etc/macos/scripts/install-azahar.sh [--version <ver>]`
- Update iSMC `bash etc/macos/scripts/install-iscm.sh [--version <ver>]`
- Update MelonDS `bash etc/macos/scripts/install-melonds.sh [--version <ver>]`
- Update MongoDB Shell `bash etc/scripts/install-mongo-utils.sh shell [--version <ver>]`
- Update MongoDB Tools `bash etc/scripts/install-mongo-utils.sh tools [--version <ver>]`
- Update SkyEmu `bash etc/macos/scripts/install-skyemu.sh [--version <ver>]`
- Update vcpkg `bash etc/scripts/install-vcpkg.sh [--tag <tag>]`
- Update Homebrew's apps.
  - Quit all apps.
  - Unlock apps: `bash etc/macos/scripts/toggle-application-lock.sh --unlock`
  - Update Homebrew environment: `brew update`
  - Update formulae with special needs:
    `brew install --ignore-dependencies jdtls maven zls`
  - Update all outdated formulae and apps: `brew upgrade --greedy`
  - Unlink specific formulae: `brew unlink python@3.14 openssl@3`
  - Purge the cache: `brew cleanup [--dry-run]`
- Update Mise plugins and tools
  - Update all plugins: `mise plugins upgrade`
  - Update all tools: `mise upgrade`
- Update Python packages
  - List outdated packages: `pip3 list --user --outdated`
  - Update specific package: `pip3 install --user --upgrade <package>`
- Open updated apps and make sure they're working as intended.
- Update Brave's Content Filters list.
- Update VSCode's plugins.
- Review the settings of iCloud, Login Items, Siri Suggestions and
  Notifications.

## Wrap up
- Lock apps: `bash etc/macos/scripts/toggle-application-lock.sh`
- Disable SIP in case it got enabled
  - `csrutil status`.
  - [Disable SIP](https://developer.apple.com/documentation/security/disabling-and-enabling-system-integrity-protection).
- Disable `softwareupdated`.
  ```
  sudo launchctl disable system/com.apple.mobile.softwareupdated
  sudo launchctl disable system/com.apple.softwareupdated
  ```
- Save any configuration changes: `bash etc/macos/scripts/export-defaults.sh`
- Open _Ghostty_ and purge all caches: `purge all` 
- Reboot.
