#!/usr/bin/env bash
# shellcheck disable=SC2155

# README
# This script is specially targeted at native macOS hosts. It disables a set of
# macOS services that are not fundamentally required, therefore freeing up RAM
# and CPU resources.
# Notice that this only works if SIP is disabled.

set -Eeuo pipefail

readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
verbose=0

log () { printf '[%s] %s\n' "${0##*/}" "$*" >&2; }
err () { printf '[%s] ERROR: %s\n' "${0##*/}" "$*" >&2; }

# Wrapper to run commands while controlling log verbosity and output redirection.
run () {
	[[ $verbose -gt 0 ]] && printf "\t%s\n" "$*" >&2

	local status=0
	if [[ $verbose == 2 ]]; then
		if [[ -v stdo && $stdo == 1 ]]; then
			"$@" 2>"$TMP_LOG_FILE"
		else
			"$@" &>"$TMP_LOG_FILE"
		fi
		status=$?
		sed 's/^/\t\t/' "$TMP_LOG_FILE"
	else
		if [[ -v stdo && $stdo == 1 ]]; then
			"$@" 2>/dev/null
		else
			"$@" &>/dev/null
		fi
		status=$?
	fi

	return $status
}

cleanup () {
	local err_code=$?
    local trap_signal="$1"
    [[ $trap_signal == "ERR" ]] && err "Command failed with exit code $err_code."
	rm -rf "$TMP_LOG_FILE"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v)
			verbose=1
			shift;;
		-vv)
			verbose=2
			shift;;
		*)
			shift;;
esac; done
}

disable_user_services () {
	local user_services=(
		com.apple.accessibility.axassetsd
		com.apple.accessibility.heard
		com.apple.accessibility.MotionTrackingAgent
		# com.apple.AddressBook.ContactsAccountsService
		# com.apple.AddressBook.ContactsAccountsService
		com.apple.AMPArtworkAgent
		# com.apple.AMPDeviceDiscoveryAgent
		# com.apple.AMPDevicesAgent
		com.apple.AMPLibraryAgent
		# com.apple.AMPSystemPlayerAgent
		# com.apple.amsengagementd
		com.apple.ap.adprivacyd
		com.apple.ap.adservicesd
		com.apple.ap.promotedcontentd
		com.apple.appstoreagent
		com.apple.appstorecomponentsd
		com.apple.assistant_cdmd
		com.apple.assistant_service
		com.apple.assistantd
		# com.apple.avconferenced
		com.apple.betaenrollmentd
		com.apple.BiomeAgent
		com.apple.biomesyncd
		# com.apple.BTServer.cloudpairing
		# com.apple.calaccessd
		# com.apple.CalendarAgent
		# com.apple.CallHistoryPluginHelper
		# com.apple.cloudd
		# com.apple.cloudpaird
		# com.apple.cloudphotod
		# com.apple.CloudPhotosConfiguration
		# com.apple.CloudSettingsSyncAgent
		# com.apple.cmio.ContinuityCaptureAgent
		# com.apple.CommCenter-osx
		# com.apple.commerce
		# com.apple.ContactsAgent
		com.apple.ContextStoreAgent
		# com.apple.CoreLocationAgent
		com.apple.corespeechd
		# com.apple.dataaccess.dataaccessd
		com.apple.diagnosticextensionsd
		com.apple.diagnostics_agent
		com.apple.DiagnosticsReporter
		com.apple.email.maild
		# com.apple.ensemble
		com.apple.familycircled
		com.apple.familycontrols.useragent
		com.apple.familynotificationd
		com.apple.financed
		# com.apple.findmy.findmylocateagent
		# com.apple.findmymacmessenger
		# com.apple.followupd
		com.apple.GameController.gamecontrolleragentd
		com.apple.gamed
		com.apple.generativeexperiencesd
		com.apple.geoanalyticsd
		# com.apple.geod
		# com.apple.geodMachServiceBridge
		com.apple.helpd
		com.apple.homed
		# com.apple.icloud.fmfd
		# com.apple.icloud.findmydeviced.findmydevice-user-agent
		# com.apple.icloud.searchpartyuseragent
		com.apple.icloudmailagent
		# com.apple.iCloudNotificationAgent
		# com.apple.iCloudUserNotifications
		# com.apple.imagent
		# com.apple.imautomatichistorydeletionagent
		# com.apple.imtransferagent
		com.apple.inputanalyticsd
		com.apple.intelligencecontextd
		com.apple.intelligenceflowd
		com.apple.intelligenceplatformd
		com.apple.itunescloudd
		com.apple.knowledge-agent
		com.apple.knowledgeconstructiond
		com.apple.macos.studentd
		# com.apple.ManagedClient.cloudconfigurationd
		com.apple.ManagedClientAgent.enrollagent
		# com.apple.maps.destinationd
		# com.apple.Maps.mapspushd
		# com.apple.Maps.pushdaemon
		# com.apple.mediaanalysisd
		# com.apple.mediastream.mstreamd
		com.apple.naturallanguaged
		# com.apple.navd
		com.apple.newsd
		com.apple.parsec-fbf
		com.apple.parsecd
		com.apple.passd
		# com.apple.photoanalysisd
		# com.apple.photolibraryd
		# com.apple.progressd
		# com.apple.protectedcloudstorage.protectedcloudkeysyncing
		# com.apple.quicklook
		# com.apple.quicklook.ThumbnailsAgent
		# com.apple.quicklook.ui.helper
		# com.apple.rapportd
		# com.apple.rapportd-user
		# com.apple.remindd
		com.apple.replicatord
		com.apple.ReportCrash
		# com.apple.routined
		# com.apple.Safari.History
		# com.apple.Safari.PasswordBreachAgent
		com.apple.Safari.SafeBrowsing.Service
		# com.apple.SafariBookmarksSyncAgent
		# com.apple.SafariCloudHistoryPushAgent
		# com.apple.SafariHistoryServiceAgent
		# com.apple.SafariLaunchAgent
		com.apple.SafariNotificationAgent
		# com.apple.screensharing.agent
		# com.apple.screensharing.menuextra
		# com.apple.screensharing.MessagesAgent
		com.apple.ScreenTimeAgent
		# com.apple.security.cloudkeychainproxy3
		# com.apple.security.keychain-circle-notification
		# com.apple.sharingd
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
		# com.apple.StatusKitAgent
		# com.apple.storedownloadd
		com.apple.studentd
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

	log "Disabling user services ..."
	local uid=$(id -u)
	for service in "${user_services[@]}"; do
			run launchctl disable "gui/$uid/$service"
	done

}

disable_system_services () {
	local system_services=(
		com.apple.analyticsd
		com.apple.appstored
		com.apple.AppStoreDaemon.StorePrivilegedODRService
		com.apple.AppStoreDaemon.StorePrivilegedTaskService
		com.apple.audioanalyticsd
		com.apple.backupd
		com.apple.backupd-helper
		com.apple.biomed
		# com.apple.cloudd
		# com.apple.cloudpaird
		# com.apple.cloudphotod
		# com.apple.CloudPhotosConfiguration
		com.apple.coreduetd
		com.apple.corespeechd_system
		com.apple.dasd
		com.apple.diagnosticd
		com.apple.ecosystemanalyticsd
		com.apple.eligibilityd
		com.apple.EmbeddedOSInstallService
		com.apple.familycontrols
		# com.apple.findmy.findmybeaconingd
		# com.apple.findmymacd
		# com.apple.findmymacmessenger
		com.apple.followupd
		com.apple.FollowUpUI
		# com.apple.ftp-proxy
		# com.apple.ftpd
		com.apple.GameController.gamecontrollerd
		# com.apple.icloud.findmydeviced
		# com.apple.icloud.fmfd
		# com.apple.icloud.searchpartyd
		com.apple.itunescloudd
		# com.apple.locationd
		com.apple.logd
		com.apple.logd_helper
		# com.apple.ManagedClient.cloudconfigurationd
		# com.apple.mobile.obliteration
		com.apple.mobile.softwareupdated
		# com.apple.modelmanagerd
		com.apple.ospredictiond
		# com.apple.protectedcloudstorage.protectedcloudkeysyncing
		# com.apple.rapportd
		com.apple.ReportCrash.Root
		com.apple.rtcreportingd
		# com.apple.screensharing
		# com.apple.security.cloudkeychainproxy3
		com.apple.siri.morphunassetsupdaterd
		com.apple.siriinferenced
		com.apple.softwareupdated
		com.apple.syslogd
		# com.apple.touchbarserver
		com.apple.triald.system
		com.apple.wifianalyticsd
		com.apple.XProtect.daemon.scan
		com.apple.XProtect.daemon.scan.startup
		com.apple.XprotectFramework.PluginService
	)

	log "Disabling system services ..."
	macos_major_version="$(sw_vers -productVersion | grep -o '^\d*')"
	if [ $((macos_major_version)) -ne 26 ]; then
		# NOTE: Disabling the syspolicy service will save some RAM and specially CPU
		# time during login and app launch. However files like PDFs and pictures are
		# quarantined by default on macOS Tahoe when the service is not running,
		# forcing the user to clear the quarantine attribute recurrently to be able
		# to open them. Therefore this service is left enabled for macOS Tahoe.
		system_services+=(com.apple.security.syspolicy)
		log "Added com.apple.security.syspolicy because macOS version != 26"
	fi

	for service in "${system_services[@]}"; do
		run sudo launchctl disable "system/$service"
	done
}

trap 'cleanup ERR' ERR
trap 'cleanup EXIT' EXIT
parse_input_args "$@"
disable_user_services
disable_system_services
