//
//  AppOpenAdManager.swift
//  Controllers
//
//  유료 기능을 쓰지 않는 사용자가 백그라운드에서 앱으로 돌아오면 앱 오프닝 광고를 띄운다.
//  AdMob 정책상 앱을 열거나 돌아오는 시점에는 전면 광고를 쓸 수 없어 이 형식을 쓴다.
//

import UIKit
import GoogleMobileAds

final class AppOpenAdManager: NSObject {

    static let shared = AppOpenAdManager()

    /// 마지막으로 광고를 띄운 뒤 이 시간이 지나야 다시 띄운다.
    static let minimumInterval: TimeInterval = 15 * 60

    /// 불러온 광고는 4시간이 지나면 띄워도 수익이 나지 않는다. (Google 권장)
    private static let adLifetime: TimeInterval = 4 * 60 * 60

    #if DEBUG
    /// Google 테스트 앱 오프닝 광고 단위. 개발 중에는 실제 광고 단위를 쓰지 않는다.
    private let adUnitID = "ca-app-pub-3940256099942544/5575463023"
    #else
    /// AdMob '아차 충전 !' 앱의 app_open_foreground 광고 단위
    private let adUnitID = "ca-app-pub-7469152743628808/3611967519"
    #endif

    private var appOpenAd: AppOpenAd?
    private var loadDate: Date?
    private var isLoading = false
    private var skipsNextAd = false

    /// 광고가 화면을 덮고 있는 동안 true
    private(set) var isShowingAd = false

    private override init() {
        super.init()
    }
}

extension AppOpenAdManager {
    /// 마지막 광고 노출 시각. 앱을 다시 켜도 간격을 지키도록 저장한다.
    private static var lastShownDate: Date? {
        get { UserDefaults.standard.object(forKey: StringKey.LAST_APP_OPEN_AD_DATE) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: StringKey.LAST_APP_OPEN_AD_DATE) }
    }

    private var isAdFresh: Bool {
        guard let loadDate = loadDate else { return false }
        return Date().timeIntervalSince(loadDate) < Self.adLifetime
    }

    /// 다음 한 번의 복귀에는 광고를 띄우지 않는다.
    /// 약관 링크, 광고 클릭처럼 앱이 사용자를 밖으로 보냈을 때 부른다. 돌아오자마자 광고가 뜨지 않게 한다.
    @MainActor
    func skipNextAd() {
        skipsNextAd = true
    }

    /// 다음 복귀 때 바로 띄울 수 있게 광고를 미리 불러 둔다.
    @MainActor
    func loadAdIfNeeded() async {
        guard !PremiumAccess.isActive, !isLoading, !isShowingAd,
              appOpenAd == nil || !isAdFresh,
              AdConsentManager.shared.canRequestAds else { return }

        isLoading = true
        defer { isLoading = false }
        await AdConsentManager.shared.startMobileAdsIfNeeded()
        do {
            appOpenAd = try await AppOpenAd.load(with: adUnitID, request: Request())
            loadDate = Date()
        } catch {
            appOpenAd = nil
            NSLog("앱 오프닝 광고 로드 실패: \(error.localizedDescription)")
        }
    }

    /// 백그라운드에서 돌아왔을 때 부른다. 조건이 맞을 때만 광고를 띄운다.
    @MainActor
    func showAdIfAvailable() {
        guard !skipsNextAd else {
            skipsNextAd = false
            return
        }
        guard !PremiumAccess.isActive,
              !isShowingAd,
              !RewardedPassManager.shared.isShowingAd else { return }
        if let lastShownDate = Self.lastShownDate,
           Date().timeIntervalSince(lastShownDate) < Self.minimumInterval {
            return
        }
        guard let ad = appOpenAd, isAdFresh else {
            // 이번에는 건너뛰고 다음 복귀 때 쓸 광고를 불러 둔다.
            Task { await loadAdIfNeeded() }
            return
        }
        // 다른 팝업이 떠 있으면 그 위를 덮지 않는다.
        guard let topViewController = UIApplication.topViewController(),
              !(topViewController is UIAlertController) else { return }

        isShowingAd = true
        ad.fullScreenContentDelegate = self
        ad.present(from: topViewController)
    }

    @MainActor
    private func finishPresentation() {
        isShowingAd = false
        appOpenAd = nil
        loadDate = nil
        Task { await loadAdIfNeeded() }
        ProPromotionManager.shared.presentIfNeeded()
    }
}

// MARK: - FullScreenContentDelegate
extension AppOpenAdManager: FullScreenContentDelegate {
    @MainActor
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        Self.lastShownDate = Date()
    }

    @MainActor
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        finishPresentation()
    }

    @MainActor
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        NSLog("앱 오프닝 광고 표시 실패: \(error.localizedDescription)")
        finishPresentation()
    }
}
