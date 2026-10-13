//
//  AdConsentManager.swift
//  Controllers
//
//  광고를 요청하기 전에 거치는 단계를 한곳에서 처리한다.
//  Google UMP 동의(EU·영국 등) → ATT 추적 허용 → Google Mobile Ads SDK 시작 순서다.
//  앱 시작 흐름(SceneDelegate)과 보상형 광고 버튼에서 부른다.
//

import UIKit
import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform

@MainActor
final class AdConsentManager {

    static let shared = AdConsentManager()

    private var isMobileAdsStarted = false

    private init() {}

    /// 광고를 요청해도 되는지. 이전 실행에서 받은 동의도 반영된다.
    var canRequestAds: Bool {
        ConsentInformation.shared.canRequestAds
    }

    /// EU·영국 등 동의가 필요한 지역이면 true. 이때는 광고 동의를 다시 고르는 진입점을 보여야 한다.
    var isPrivacyOptionsRequired: Bool {
        ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }

    /// 동의·ATT를 묻고 SDK를 시작한다. 광고를 요청할 수 있으면 true
    func prepare(from viewController: UIViewController) async -> Bool {
        // 알림 권한 같은 시스템 팝업이 떠 있는 동안은 앱이 비활성이라 동의 화면·ATT 팝업이 뜨지 않는다.
        await waitUntilActive()

        let consentInformation = ConsentInformation.shared
        do {
            try await consentInformation.requestConsentInfoUpdate(with: nil)
            try await ConsentForm.loadAndPresentIfRequired(from: viewController)
        } catch {
            // 갱신에 실패해도 이전 실행에서 받은 동의가 있으면 광고를 요청할 수 있다.
            NSLog("광고 동의 정보 갱신 실패: \(error.localizedDescription)")
        }
        guard consentInformation.canRequestAds else { return false }

        // 허용 여부와 관계없이 보상은 같다. 허용하면 맞춤 광고가 나간다.
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            await waitUntilActive()
            _ = await ATTrackingManager.requestTrackingAuthorization()
        }

        await startMobileAdsIfNeeded()
        return true
    }

    func startMobileAdsIfNeeded() async {
        guard !isMobileAdsStarted else { return }
        isMobileAdsStarted = true
        _ = await MobileAds.shared.start()
    }

    /// 사용자가 광고 동의를 다시 고르는 Google 화면
    func presentPrivacyOptions(from viewController: UIViewController) async {
        do {
            try await ConsentForm.presentPrivacyOptionsForm(from: viewController)
        } catch {
            NSLog("광고 동의 설정 화면 표시 실패: \(error.localizedDescription)")
        }
    }

    private func waitUntilActive() async {
        guard UIApplication.shared.applicationState != .active else { return }
        for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
            return
        }
    }
}
