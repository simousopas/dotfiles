#!/usr/bin/env bash

# NOTE: This script is specially targeted for macOS OCLP hosts.
# It defines a set of macOS services that are not necessary under and OCLP host.

user_services=(
	com.apple.accessibility.axassetsd
	com.apple.accessibility.heard
	com.apple.accessibility.MotionTrackingAgent
	com.apple.AddressBook.ContactsAccountsService
	com.apple.AddressBook.ContactsAccountsService
	com.apple.AMPArtworkAgent
	com.apple.AMPDeviceDiscoveryAgent
	com.apple.AMPDevicesAgent
	com.apple.AMPLibraryAgent
	com.apple.AMPSystemPlayerAgent
	com.apple.amsengagementd
	com.apple.ap.adprivacyd
	com.apple.ap.adservicesd
	com.apple.ap.promotedcontentd
	com.apple.appstoreagent
	com.apple.appstorecomponentsd
	com.apple.assistant_cdmd
	com.apple.assistant_service
	com.apple.assistantd
	com.apple.avconferenced
	com.apple.betaenrollmentd
	com.apple.BiomeAgent
	com.apple.biomesyncd
	com.apple.BTServer.cloudpairing
	# com.apple.calaccessd
	# com.apple.CalendarAgent
	com.apple.CallHistoryPluginHelper
	com.apple.cloudd
	com.apple.cloudpaird
	com.apple.cloudphotod
	com.apple.CloudPhotosConfiguration
	com.apple.CloudSettingsSyncAgent
	com.apple.cmio.ContinuityCaptureAgent
	com.apple.CommCenter-osx
	com.apple.commerce
	# com.apple.ContactsAgent
	com.apple.ContextStoreAgent
	# com.apple.CoreLocationAgent
	com.apple.corespeechd
	# com.apple.dataaccess.dataaccessd
	com.apple.diagnosticextensionsd
	com.apple.diagnostics_agent
	com.apple.DiagnosticsReporter
	com.apple.email.maild
	com.apple.ensemble
	com.apple.familycircled
	com.apple.familycontrols.useragent
	com.apple.familynotificationd
	com.apple.financed
	com.apple.findmy.findmylocateagent
	com.apple.findmymacmessenger
	com.apple.followupd
	com.apple.GameController.gamecontrolleragentd
	com.apple.gamed
	com.apple.generativeexperiencesd
	com.apple.geoanalyticsd
	# com.apple.geod
	# com.apple.geodMachServiceBridge
	com.apple.helpd
	com.apple.homed
	com.apple.icloud.fmfd
	com.apple.icloud.findmydeviced.findmydevice-user-agent
	com.apple.icloud.searchpartyuseragent
	com.apple.icloudmailagent
	com.apple.iCloudNotificationAgent
	com.apple.iCloudUserNotifications
	com.apple.imagent
	com.apple.imautomatichistorydeletionagent
	com.apple.imtransferagent
	com.apple.inputanalyticsd
	com.apple.intelligencecontextd
	com.apple.intelligenceflowd
	com.apple.intelligenceplatformd
	com.apple.itunescloudd
	com.apple.knowledge-agent
	com.apple.knowledgeconstructiond
	com.apple.macos.studentd
	com.apple.ManagedClient.cloudconfigurationd
	com.apple.ManagedClientAgent.enrollagent
	com.apple.maps.destinationd
	com.apple.Maps.mapspushd
	com.apple.Maps.pushdaemon
	com.apple.mediaanalysisd
	com.apple.mediastream.mstreamd
	com.apple.naturallanguaged
	# com.apple.navd
	com.apple.newsd
	com.apple.parsec-fbf
	com.apple.parsecd
	com.apple.passd
	com.apple.photoanalysisd
	com.apple.photolibraryd
	# com.apple.progressd
	com.apple.protectedcloudstorage.protectedcloudkeysyncing
	# com.apple.quicklook
	# com.apple.quicklook.ThumbnailsAgent
	# com.apple.quicklook.ui.helper
	com.apple.rapportd
	com.apple.rapportd-user
	com.apple.remindd
	com.apple.replicatord
	com.apple.ReportCrash
	com.apple.routined
	com.apple.Safari.History
	com.apple.Safari.PasswordBreachAgent
	com.apple.Safari.SafeBrowsing.Service
	com.apple.SafariBookmarksSyncAgent
	com.apple.SafariCloudHistoryPushAgent
	com.apple.SafariHistoryServiceAgent
	com.apple.SafariLaunchAgent
	com.apple.SafariNotificationAgent
	# com.apple.screensharing.agent
	# com.apple.screensharing.menuextra
	# com.apple.screensharing.MessagesAgent
	com.apple.ScreenTimeAgent
	com.apple.security.cloudkeychainproxy3
	com.apple.security.keychain-circle-notification
	com.apple.sharingd
	com.apple.sidecar-hid-relay
	com.apple.sidecar-relay
	com.apple.Siri.agent
	com.apple.siri.context.service
	com.apple.siriactionsd
	com.apple.siriinferenced
	com.apple.siriknowledged
	com.apple.sirittsd
	com.apple.SiriTTSTrainingAgent
	com.apple.SoftwareUpdateNotificationManager
	com.apple.StatusKitAgent
	# com.apple.storedownloadd
	com.apple.suggestd
	# com.apple.telephonyutilities.callservicesd
	com.apple.tipsd
	com.apple.TMHelperAgent
	com.apple.TMHelperAgent.SetupOffer
	com.apple.transparencyd
	com.apple.triald
	# com.apple.universalaccessd
	com.apple.UsageTrackingAgent
	com.apple.videosubscriptionsd
	com.apple.voicebankingd
	com.apple.watchlistd
	# com.apple.weatherd
	com.apple.WiFiVelocityAgent
	com.apple.XProtect.agent.scan
	com.apple.XProtect.daemon.scan
	com.apple.XProtect.daemon.scan.startup
	com.apple.XprotectFramework.PluginService
)
echo "Disabling user services ..."
uid=$(id -u)
for service in "${user_services[@]}"; do
	echo -e "\t-> gui/$uid/$service"
	launchctl disable "gui/$uid/$service"
done

system_services=(
	com.apple.analyticsd
	com.apple.appstored
	com.apple.AppStoreDaemon.StorePrivilegedODRService
	com.apple.AppStoreDaemon.StorePrivilegedTaskService
	com.apple.audioanalyticsd
	com.apple.backupd
	com.apple.backupd-helper
	com.apple.biomed
	com.apple.cloudd
	com.apple.cloudpaird
	com.apple.cloudphotod
	com.apple.CloudPhotosConfiguration
	com.apple.coreduetd
	com.apple.corespeechd_system
	com.apple.dasd
	com.apple.diagnosticd
	com.apple.ecosystemanalyticsd
	com.apple.eligibilityd
	com.apple.EmbeddedOSInstallService
	com.apple.familycontrols
	com.apple.findmy.findmybeaconingd
	com.apple.findmymacd
	com.apple.findmymacmessenger
	com.apple.followupd
	com.apple.FollowUpUI
	# com.apple.ftp-proxy
	# com.apple.ftpd
	com.apple.GameController.gamecontrollerd
	com.apple.icloud.findmydeviced
	com.apple.icloud.fmfd
	com.apple.icloud.searchpartyd
	com.apple.itunescloudd
	# com.apple.locationd
	com.apple.logd
	com.apple.logd_helper
	com.apple.ManagedClient.cloudconfigurationd
	com.apple.mobile.obliteration
	com.apple.mobile.softwareupdated
	com.apple.modelmanagerd
	com.apple.ospredictiond
	com.apple.protectedcloudstorage.protectedcloudkeysyncing
	com.apple.rapportd
	com.apple.ReportCrash.Root
	com.apple.rtcreportingd
	# com.apple.screensharing
	com.apple.security.cloudkeychainproxy3
	# com.apple.security.syspolicy (Needed by OCLP)
	com.apple.siri.morphunassetsupdaterd
	com.apple.siriinferenced
	com.apple.softwareupdated
	com.apple.syslogd
	com.apple.touchbarserver
	com.apple.triald.system
	com.apple.wifianalyticsd
	com.apple.XProtect.daemon.scan
	com.apple.XProtect.daemon.scan.startup
	com.apple.XprotectFramework.PluginService
)
echo "Disabling system services ..."
for service in "${system_services[@]}"; do
	echo -e "\t-> system/$service"
	sudo launchctl disable "system/$service"
done
