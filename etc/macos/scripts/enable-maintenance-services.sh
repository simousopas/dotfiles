#!/usr/bin/env bash

echo "Enabling user services ..."
uid=$(id -u)
launchctl enable "gui/$uid/com.apple.appstoreagent"
launchctl enable "gui/$uid/com.apple.appstorecomponentsd"
launchctl enable "gui/$uid/com.apple.SoftwareUpdateNotificationManager"

echo "Enabling system services ..."
macos_major_version="$(sw_vers -productVersion | grep -o '^\d*')"
if [ $((macos_major_version)) -ne 26 ]; then
	sudo launchctl enable "system/com.apple.security.syspolicy"
fi
sudo launchctl enable "system/com.apple.appstored"
sudo launchctl enable "system/com.apple.AppStoreDaemon.StorePrivilegedODRService"
sudo launchctl enable "system/com.apple.AppStoreDaemon.StorePrivilegedTaskService"
sudo launchctl enable "system/com.apple.dasd"
sudo launchctl enable "system/com.apple.mobile.softwareupdated"
sudo launchctl enable "system/com.apple.softwareupdated"
