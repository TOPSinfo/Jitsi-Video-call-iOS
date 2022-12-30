//
//  SceneDelegate.swift
//  SampleCodeiOS
//
//  Created by Tops on 01/10/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        // MARK: setting window object
        AppDelegate.standard.window = window
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        Singleton.sharedSingleton.doOnlineOffline(isOnline: false)
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        Singleton.sharedSingleton.doOnlineOffline(isOnline: true)
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        Singleton.sharedSingleton.doOnlineOffline(isOnline: false)
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
