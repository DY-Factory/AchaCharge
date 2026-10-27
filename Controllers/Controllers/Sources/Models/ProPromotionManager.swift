//
//  ProPromotionManager.swift
//  Controllers
//
//  유료 기능을 쓰지 않는 사용자가 앱을 켠 뒤 처음 컨트롤러를 연결하면 Pro를 소개하는 팝업을 한 번 띄운다.
//  팝업에서 바로 광고 이용권을 받거나 구매 화면으로 갈 수 있다.
//

import UIKit

@MainActor
final class ProPromotionManager {

    static let shared = ProPromotionManager()

    /// 앱 시작 때 알림 권한·광고 동의·ATT를 묻는 동안은 팝업을 미룬다.
    var isLaunchFlowFinished = false {
        didSet { presentIfNeeded() }
    }

    /// 컨트롤러가 연결됐지만 아직 팝업을 띄우지 못했으면 true
    private var isPending = false
    /// 이번 실행에서 이미 처리했으면 true. 앱을 완전히 종료했다 켜면 다시 띄운다.
    private var isDone = false

    private init() {}

    func controllerDidConnect() {
        guard !isDone else { return }
        // 평가 요청은 버전당 한 번이라, 그 차례인 실행에서는 Pro 팝업을 건너뛴다.
        if ControllerModel.isReviewRequestDue {
            NSLog("Pro promo skipped for review request")
            finish()
            return
        }
        isPending = true
        presentIfNeeded()
    }

    /// 띄울 수 있는 상태면 팝업을 띄운다. 지금 못 띄우면 앱 활성화·광고 닫힘 때 다시 시도한다.
    func presentIfNeeded() {
        guard isPending, isLaunchFlowFinished,
              UIApplication.shared.applicationState == .active else { return }
        guard !PremiumAccess.isActive else {
            finish()
            return
        }
        guard !AppOpenAdManager.shared.isShowingAd,
              !RewardedPassManager.shared.isShowingAd,
              let topViewController = UIApplication.topViewController(),
              !(topViewController is UIAlertController) else { return }

        finish()
        // 이미 구매 화면을 보고 있으면 같은 내용을 또 띄우지 않는다.
        guard !(topViewController is IAPOnboardingViewController) else { return }
        presentAlert(from: topViewController)
    }

    private func finish() {
        isPending = false
        isDone = true
    }

    private func presentAlert(from viewController: UIViewController) {
        let threshold = "\(UserDefaults.shared.batteryNotificationThreshold)%"
        let alert = UIAlertController(title: "Pro Promo Title".localized,
                                      message: "Pro Promo Message %@".localized(with: [threshold]),
                                      preferredStyle: .alert)
        let watchAdAction = UIAlertAction(title: "Watch Ad Pro Pass %@".localized(with: [RewardedPassManager.passDurationText]),
                                          style: .default) { [weak self] _ in
            self?.showRewardedAd(from: viewController)
        }
        let plansAction = UIAlertAction(title: "See Pro Plans".localized, style: .default) { _ in
            let onboardingVC = IAPOnboardingViewController()
            onboardingVC.modalPresentationStyle = .overFullScreen
            viewController.present(onboardingVC, animated: true)
        }
        alert.addAction(watchAdAction)
        alert.addAction(plansAction)
        alert.addAction(UIAlertAction(title: "Not Now".localized, style: .cancel))
        viewController.present(alert, animated: true)
    }

    private func showRewardedAd(from viewController: UIViewController) {
        // 광고를 불러오는 1~2초 동안 화면을 막고 진행 중임을 보여 준다.
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .white
        indicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        if let window = viewController.view.window {
            indicatorView.frame = window.bounds
            indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(indicatorView)
        }
        indicatorView.startAnimating()

        Task {
            let outcome = await RewardedPassManager.shared.showRewardedAd(from: viewController)
            indicatorView.removeFromSuperview()
            let alert = UIAlertController(title: nil, message: outcome.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok!".localized, style: .default))
            viewController.present(alert, animated: true)
        }
    }
}
