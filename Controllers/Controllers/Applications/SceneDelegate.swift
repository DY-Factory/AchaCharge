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
    private var launchTask: Task<Void, Never>?

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
        // 제어 센터·알림 센터를 내렸다 올린 경우는 백그라운드를 거치지 않아 false다.
        let isReturningFromBackground = isBackground
        isBackground = false
        if launchTask == nil {
            launchTask = Task { await runLaunchFlow() }
        }
        Task {
            await StoreKitManager.shared.refreshSubscriptionStatus()
            // 구독이 끝났거나 광고 이용권이 만료됐으면 남아 있는 Live Activity 를 닫는다.
            if !PremiumAccess.isActive {
                LiveActivityManager.shared.end()
            }
            if isReturningFromBackground {
                AppOpenAdManager.shared.showAdIfAvailable()
            }
            ProPromotionManager.shared.presentIfNeeded()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        print(#function, "isPremiumActive:", PremiumAccess.isActive)
        if PremiumAccess.isActive {
            let appDeleagate = UIApplication.shared.delegate as! AppDelegate
            appDeleagate.scheduleAppRefresh()
        }
        isBackground = true
        print(#function)
    }
}

// MARK: - Launch Flow
extension SceneDelegate {
    /// 앱을 켤 때 한 번만 실행한다. 시스템 팝업이 겹치지 않게 차례로 묻는다.
    /// 알림 권한 → (구독자가 아니면) 광고 동의·ATT → 앱 오프닝 광고 미리 불러오기 → Pro 팝업 허용
    private func runLaunchFlow() async {
        // 알림 권한 팝업에 답할 때까지 기다린다. 팝업이 끝내 뜨지 않을 때를 대비해 최대 10초만 기다린다.
        // 더 늦게 답해도 괜찮다. AdConsentManager.prepare()가 팝업이 닫혀 앱이 다시 활성화될 때까지 기다린다.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        var waitCount = 0
        while appDelegate?.isNotificationAuthorizationAnswered == false, waitCount < 20 {
            try? await Task.sleep(nanoseconds: 500_000_000)
            waitCount += 1
        }

        await StoreKitManager.shared.refreshSubscriptionStatus()
        if !StoreKitManager.shared.isSubscribed,
           let rootViewController = window?.rootViewController,
           await AdConsentManager.shared.prepare(from: rootViewController) {
            Task { await AppOpenAdManager.shared.loadAdIfNeeded() }
        }
        ProPromotionManager.shared.isLaunchFlowFinished = true
    }
}

