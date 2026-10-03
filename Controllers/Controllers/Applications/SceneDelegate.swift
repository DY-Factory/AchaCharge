//
//  SceneDelegate.swift
//  Controllers
//
//  Created by 강동영 on 2023/05/29.
//

import UIKit
import SwiftUI
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var isBackground = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        let rootView = UIHostingController(rootView: MainTabView())
        window?.rootViewController = rootView
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        isBackground = false
        Task { await StoreKitManager.shared.refreshSubscriptionStatus() }
    }

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        print(#function, "isSubscribed:", StoreKitManager.shared.isSubscribed)
        if StoreKitManager.shared.isSubscribed {
            let appDeleagate = UIApplication.shared.delegate as! AppDelegate
            appDeleagate.scheduleAppRefresh()
        }
        isBackground = true
        print(#function)
    }
}

