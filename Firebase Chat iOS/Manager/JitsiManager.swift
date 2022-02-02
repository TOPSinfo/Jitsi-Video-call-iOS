//
//  JitsiManager.swift
//  SampleCodeiOS
//
//  Created by Mohak Parmar on 14/10/21.
//

import UIKit
import JitsiMeetSDK
import Firebase

class JitsiManager: NSObject {

    fileprivate var jitsiMeetView: JitsiMeetView?
    var viewController : UIViewController?
    
    override init() {
        let defaultOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            // for JaaS replace url with https://8x8.vc
//            builder.serverURL = URL(string: "https://jitsi.topsdemo.in")
            builder.serverURL = URL(string: "https://meet.jit.si")
            
            // for JaaS use the obtained Jitsi JWT
            // builder.token = "SampleJWT"
            builder.welcomePageEnabled = false
            
            // Set different feature flags
            builder.setFeatureFlag("toolbox.enabled", withBoolean: true)
            builder.setFeatureFlag("filmstrip.enabled", withBoolean: true)
            builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: true)
//            builder.setFeatureFlag("ios.recording.enabled", withBoolean: true)
        }
        JitsiMeet.sharedInstance().defaultConferenceOptions = defaultOptions
    }
        
    func openJetsiViewWithUser(roomid : String, isHost : Bool = false) {

        // create and configure jitsimeet view
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            // for JaaS use <tenant>/<roomName> format
            builder.room = roomid // "TOPS" + arr[0] + arr[1]
            // Settings for audio and video
            // builder.audioMuted = true;
//             builder.videoMuted = true;
            builder.welcomePageEnabled = false
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
        let vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.view = jitsiMeetView
        
        // join room and display jitsi-call
        jitsiMeetView.join(options)
        AppDelegate.standard.currentCallId = roomid
        viewController?.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func cleanUp() {
        if(jitsiMeetView != nil) {
            viewController?.dismiss(animated: true, completion: nil)
            jitsiMeetView = nil
        }
    }
}

extension JitsiManager: JitsiMeetViewDelegate {
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        FirebaseViewModel().firebaseCloudFirestoreManager.changeCallStatus(AppDelegate.standard.currentCallId, isActive: false)
        AppDelegate.standard.currentCallId = ""
        cleanUp()
    }
    
    func conferenceJoined(_ data: [AnyHashable : Any]!) {
        print("joined")
        FirebaseViewModel().firebaseCloudFirestoreManager.changeCallStatus(AppDelegate.standard.currentCallId, isActive: true)
    }
    

}

