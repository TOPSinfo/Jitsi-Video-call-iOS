//
//  JitsiManager.swift
//  SampleCodeiOS
//
//  Created by Mohak Parmar on 14/10/21.
//

import UIKit
import JitsiMeetSDK
import FirebaseAuth

class JitsiManager: NSObject {

    fileprivate var jitsiMeetView: JitsiMeetView?
    var viewController: UIViewController?

    override init() {
        let defaultOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            // for JaaS replace url with https://8x8.vc
            builder.serverURL = URL(string: "https://jitsi.topsdemo.in")
            // builder.serverURL = URL(string: "https://meet.jit.si")

            // Old Flags
            /*
            // for JaaS use the obtained Jitsi JWT
            // builder.token = "SampleJWT"
            builder.welcomePageEnabled = false

            // Set different feature flags
            builder.setFeatureFlag("toolbox.enabled", withBoolean: true)
            builder.setFeatureFlag("filmstrip.enabled", withBoolean: true)
            builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: true)
            builder.setFeatureFlag("resolution", withBoolean: true)
//            builder.setFeatureFlag("ios.recording.enabled", withBoolean: true)
             */
            
            // New Flags
            builder.serverURL = URL(string: "https://jitsi.topsdemo.in/")
            builder.setFeatureFlag("toolbox.enabled", withBoolean: true)
            builder.setFeatureFlag("filmstrip.enabled", withBoolean: false)
            builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: false)
            builder.setFeatureFlag("add-people.enabled", withBoolean: false)
            builder.setFeatureFlag("invite.enabled", withBoolean: false)
            builder.setFeatureFlag("chat.enabled", withBoolean: false)
            builder.setFeatureFlag("kick-out.enabled", withBoolean: false)
            builder.setFeatureFlag("live-streaming.enabled", withBoolean: false)
            builder.setFeatureFlag("meeting-password.enabled", withBoolean: false)
            builder.setFeatureFlag("calendar.enabled", withBoolean: false)
            builder.setFeatureFlag("lobby-mode.enabled", withBoolean: false)
            builder.setFeatureFlag("help-view.enabled", withBoolean: false)
            builder.setFeatureFlag("close-captions.enabled", withBoolean: false)
            builder.setFeatureFlag("call-integration.enabled", withBoolean: false)
            builder.setFeatureFlag("close-captions.enabled", withBoolean: false)
            builder.setFeatureFlag("toolbox.alwaysVisible", withBoolean: false)
            builder.setFeatureFlag("help.enabled", withBoolean: false)
            builder.setFeatureFlag("raise-hand.enabled", withBoolean: false)
            builder.setFeatureFlag("meeting-name.enabled", withBoolean: false)
            builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: false)
            builder.setFeatureFlag("prejoinpage.enabled", withBoolean: false)
            builder.setFeatureFlag("participants.enabled", withBoolean: false)
            // builder.setFeatureFlag("resolution", withBoolean: true)
            builder.setFeatureFlag("notifications.enabled", withBoolean: false)
            
            builder.setFeatureFlag("pip.enabled", withValue: false) // Enable PiP mode
            builder.setFeatureFlag("tile-view.enabled", withValue: true) // Ensure tile view is enabled
            // Ensure local video is visible
            builder.setFeatureFlag("filmstrip.enabled", withValue: true) // Show local video as PiP
            
            // Tool Box
            builder.setFeatureFlag("overflow-menu.enabled", withBoolean: false)
            builder.setFeatureFlag("car-mode.enabled", withValue: false) // Car mode in overflow menu
            builder.setFeatureFlag("tile-view.enabled", withValue: false) // Tile view in overflow menu
            // builder.setFeatureFlag("filmstrip.enabled", withValue: false)
            builder.setFeatureFlag("breakout-rooms.enabled", withValue: false) // Break-out in overflow menu
            builder.setFeatureFlag("low-bandwidth.enabled", withValue: false) // Low-bandwidth in overflow menu
            builder.setFeatureFlag("stats.enabled", withValue: false) // overflow menu
            builder.setFeatureFlag("settings.enabled", withValue: false) // Settings in overflow menu
            builder.setFeatureFlag("participants.enabled", withValue: false) // overlow menu
            builder.setFeatureFlag("video-share.enabled", withValue: false) // Video share in overflow menu
            builder.setFeatureFlag("security-options.enabled", withValue: false) // Security in overflow menu
            builder.setFeatureFlag("recording.enabled", withBoolean: false) // Recording in overflow menu
            builder.setFeatureFlag("ios.recording.enabled", withBoolean: false) // Recording in overflow menu
        }
        JitsiMeet.sharedInstance().defaultConferenceOptions = defaultOptions
    }

    func openJetsiViewWithUser(roomid: String, isHost: Bool = false) {

        // create and configure jitsimeet view
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            // for JaaS use <tenant>/<roomName> format
            builder.room = roomid // "TOPS" + arr[0] + arr[1]

            let userdata = AppDelegate.standard.objCurrentUser

            builder.userInfo = JitsiMeetUserInfo.init(displayName: userdata.fullName, andEmail: userdata.email,
                                                      andAvatar: URL(string: userdata.profileImage))
            // Settings for audio and video
            // builder.audioMuted = true
//             builder.videoMuted = true
            // builder.welcomePageEnabled = false
//            builder.setFeatureFlag("meeting-password.enabled", withBoolean: false)
//            builder.setFeatureFlag("add-people.enabled", withBoolean: false)
//            builder.setFeatureFlag("invite.enabled", withBoolean: false)
//            builder.setFeatureFlag("chat.enabled", withBoolean: false)
//            builder.setFeatureFlag("kick-out.enabled", withBoolean: false)
//            builder.setFeatureFlag("live-streaming.enabled", withBoolean: false)
//            builder.setFeatureFlag("meeting-password.enabled", withBoolean: false)
//            builder.setFeatureFlag("video-share.enabled", withBoolean: true)
//            builder.setFeatureFlag("calendar.enabled", withBoolean: false)
//            builder.setFeatureFlag("lobby-mode.enabled", withBoolean: false)
//            builder.setFeatureFlag("help-view.enabled", withBoolean: false)
//            builder.setFeatureFlag("close-captions.enabled", withBoolean: false)
//            builder.setFeatureFlag("call-integration.enabled", withBoolean: false)
//            builder.setFeatureFlag("recording.enabled", withBoolean: false)
//            builder.setFeatureFlag("close-captions.enabled", withBoolean: false)
//            builder.setFeatureFlag("toolbox.alwaysVisible", withBoolean: false)
//            builder.setFeatureFlag("help.enabled", withBoolean: false)
//            builder.setFeatureFlag("raise-hand.enabled", withBoolean: false)
//            builder.setFeatureFlag("overflow-menu.enabled", withBoolean: false)
//            builder.setFeatureFlag("meeting-name.enabled", withBoolean: false)

//            builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: true)
//            builder.setFeatureFlag("ios.recording.enabled", withBoolean: true)
            print(builder.room ?? "")

            if isHost {
            } else {
            }
        }

        // setup view controller
        let vcJM = UIViewController()
        vcJM.modalPresentationStyle = .fullScreen
        vcJM.view = jitsiMeetView

        // join room and display jitsi-call
        jitsiMeetView.join(options)
        AppDelegate.standard.currentCallId = roomid
        viewController?.present(vcJM, animated: true, completion: nil)
    }

    fileprivate func cleanUp() {
        if jitsiMeetView != nil {
            viewController?.dismiss(animated: true, completion: nil)
            jitsiMeetView = nil
        }
    }
}

extension JitsiManager: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable: Any]!) {
        let fcfm = FirebaseViewModel().firebaseCloudFirestoreManager
        fcfm.changeCallStatus(AppDelegate.standard.currentCallId, isActive: false)
        AppDelegate.standard.currentCallId = ""
        cleanUp()
    }

    func conferenceJoined(_ data: [AnyHashable: Any]!) {
        print("joined")
        let fcfm = FirebaseViewModel().firebaseCloudFirestoreManager
        fcfm.changeCallStatus(AppDelegate.standard.currentCallId, isActive: true)
    }
}
