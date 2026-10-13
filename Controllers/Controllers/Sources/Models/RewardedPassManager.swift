//
//  RewardedPassManager.swift
//  Controllers
//
//  보상형 광고를 끝까지 보면 일정 시간 동안 프리미엄 기능(백그라운드 충전 알림, Live Activity, 광고 제거)을 열어 준다.
//  광고를 요청하기 전의 동의·ATT는 AdConsentManager가 맡는다.
//

import UIKit
import GoogleMobileAds

/// 유료 기능을 쓸 수 있는지. 구독 중이거나 광고 이용권이 남아 있으면 true
enum PremiumAccess {
    static var isActive: Bool {
        StoreKitManager.shared.isSubscribed || RewardedPassManager.isPassActive
    }
}

extension Notification.Name {
    /// 광고 이용권을 받아 유료 기능이 새로 열렸을 때
    static let proPassGranted = Notification.Name("proPassGranted")
}

final class RewardedPassManager: NSObject {

    enum Outcome {
        /// 광고를 끝까지 봐서 이용권을 받음
        case rewarded
        /// 보상 전에 광고를 닫음
        case dismissedEarly
        /// 동의 거부, 광고 없음(no fill), 네트워크 오류 등으로 광고를 보여 주지 못함
        case unavailable
    }

    static let shared = RewardedPassManager()

    /// 광고 1회 시청으로 주는 이용 시간
    static let passDuration: TimeInterval = 3 * 60 * 60

    #if DEBUG
    /// Google 테스트 보상형 광고 단위. 개발 중에는 실제 광고 단위를 쓰지 않는다.
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    /// AdMob '아차 충전 !' 앱의 pro_pass_rewarded 광고 단위
    private let adUnitID = "ca-app-pub-7469152743628808/7469653173"
    #endif

    private var presentedAd: RewardedAd?
    private var didEarnReward = false
    private var dismissContinuation: CheckedContinuation<Outcome, Never>?

    /// 광고를 불러오거나 보여 주는 동안 true. 이때는 앱 오프닝 광고·Pro 팝업을 띄우지 않는다.
    private(set) var isShowingAd = false

    private override init() {
        super.init()
    }
}

// MARK: - Pass
extension RewardedPassManager {
    /// 이용권 만료 시각. 이용권을 받은 적이 없으면 nil
    static var passExpirationDate: Date? {
        UserDefaults.standard.object(forKey: StringKey.PRO_PASS_EXPIRATION) as? Date
    }

    static var isPassActive: Bool {
        guard let expiration = passExpirationDate else { return false }
        return expiration > Date()
    }

    /// 예: "3시간", "3 hours", "3時間"
    static var passDurationText: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: passDuration) ?? ""
    }

    private func grantPass() {
        let expiration = Date().addingTimeInterval(Self.passDuration)
        UserDefaults.standard.set(expiration, forKey: StringKey.PRO_PASS_EXPIRATION)
        NotificationCenter.default.post(name: .proPassGranted, object: nil)
    }
}

// MARK: - Rewarded Ad
extension RewardedPassManager {
    /// 동의·ATT를 거쳐 광고를 불러와 보여 준다. 끝까지 보면 이용권을 저장한다.
    @MainActor
    func showRewardedAd(from viewController: UIViewController) async -> Outcome {
        isShowingAd = true
        defer { isShowingAd = false }
        guard await AdConsentManager.shared.prepare(from: viewController) else { return .unavailable }

        let ad: RewardedAd
        do {
            ad = try await RewardedAd.load(with: adUnitID, request: Request())
        } catch {
            NSLog("보상형 광고 로드 실패: \(error.localizedDescription)")
            return .unavailable
        }

        let outcome = await present(ad, from: viewController)
        if outcome == .rewarded {
            grantPass()
        }
        return outcome
    }

    @MainActor
    private func present(_ ad: RewardedAd, from viewController: UIViewController) async -> Outcome {
        await withCheckedContinuation { continuation in
            dismissContinuation = continuation
            didEarnReward = false
            presentedAd = ad
            ad.fullScreenContentDelegate = self
            ad.present(from: viewController) { [weak self] in
                self?.didEarnReward = true
            }
        }
    }

    @MainActor
    private func finishPresentation(_ outcome: Outcome) {
        presentedAd = nil
        dismissContinuation?.resume(returning: outcome)
        dismissContinuation = nil
    }
}

// MARK: - FullScreenContentDelegate
extension RewardedPassManager: FullScreenContentDelegate {
    @MainActor
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        // 광고를 눌러 App Store 등에 갔다 돌아올 때 앱 오프닝 광고가 바로 뜨지 않게 한다.
        AppOpenAdManager.shared.skipNextAd()
    }

    @MainActor
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        finishPresentation(didEarnReward ? .rewarded : .dismissedEarly)
    }

    @MainActor
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        NSLog("보상형 광고 표시 실패: \(error.localizedDescription)")
        finishPresentation(.unavailable)
    }
}

extension RewardedPassManager.Outcome {
    /// 결과를 사용자에게 알리는 문구
    var message: String {
        switch self {
        case .rewarded:
            return "Pro Pass Granted %@".localized(with: [RewardedPassManager.passDurationText])
        case .dismissedEarly:
            return "Ad Not Completed".localized
        case .unavailable:
            return "Ad Not Available".localized
        }
    }
}
