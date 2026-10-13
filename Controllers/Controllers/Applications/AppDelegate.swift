//
//  AppDelegate.swift
//  Controllers
//
//  Created by 강동영 on 2023/05/29.
//

import UIKit
import UserNotifications
import BackgroundTasks
import ControllerKit
import SwiftyStoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var orientationLock = UIInterfaceOrientationMask.all
    /// 알림 권한 팝업에 답했는지. SceneDelegate의 앱 시작 흐름이 이 값을 보고 광고 동의·ATT를 묻는다.
    private(set) var isNotificationAuthorizationAnswered = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registBackgroundTask()
        StoreKitManager.shared.observeTransactionUpdates()
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    BGTaskScheduler.shared.cancelAllTaskRequests()
                @unknown default:
                    BGTaskScheduler.shared.cancelAllTaskRequests()
                }
            }
        }
        
        Task {
            await requestNotificationAuthorization()
            isNotificationAuthorizationAnswered = true
        }
        
        let isSubscribed = UserDefaults.standard.value(forKey: StringKey.IS_SUBSCRIBED) as? Bool
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        orientationLock
    }
}


// MARK: - Push Notifications Method
extension AppDelegate {
    /// 사용자가 답할 때까지 기다린다. 이미 답했으면 바로 끝난다.
    private func requestNotificationAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("Permission granted: \(granted)")
        } catch {
            print(error.localizedDescription)
        }
    }
}


// MARK: - BGTask Method
extension AppDelegate {
    private func registBackgroundTask() {
        // STEP1
        // Register for background app refresh task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: StringKey.BATTERY_IDENTIFIER, using: nil) { task in
            // Perform your background fetch here
            
            print(#function, "isPremiumActive:", PremiumAccess.isActive)
            if PremiumAccess.isActive {
                self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
            } else {
                // 광고 이용권이 끝났거나 구독이 만료됐다. 할 일 없이 바로 끝낸다.
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    private func handleAppRefreshTask(task: BGAppRefreshTask) {
        // STEP2
        // Perform background fetch here
            
        // Be sure to call the completion handler when the task is complete
//        scheduleAppRefresh()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = FetchGameControllerOperation(manager: GameControllerManager.shared)
        queue.addOperation(operation)
        
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }

        queue.waitUntilAllOperationsAreFinished()
    }
    
    // STEP3
    public func scheduleAppRefresh() {
        
        
        let request = BGAppRefreshTaskRequest(identifier: StringKey.BATTERY_IDENTIFIER)
        request.earliestBeginDate = nil
        
        // TEST: e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.controller.battery"]
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
