//
//  IAPOnboardingViewController.swift
//  Controllers
//
//  Created by 강동영 on 2023/10/11.
//

import UIKit
import SwiftyStoreKit

final class IAPOnboardingViewController: UIViewController {

    // MARK: - UI Properties
    private let dimmedView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = .white
        view.backgroundColor = .clear
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedCloseButton), for: .touchUpInside)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.imageView?.tintColor = .label
        
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let scrollContentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Upgrade to Pro".localized
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .label
        label.font = IAPOnboardingViewController.boldFont(.largeTitle)
        
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Notifications can also be sent to the controller's battery information during game play".localized
            + "\n\n" + "Pro No Ads".localized
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        
        return label
    }()
    
    private lazy var weeklyButton: ImageButton = {
        let button = ImageButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = SubscriptionType.week.rawValue
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        button.setTitle("Week Plan".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBackground
        button.isSelected = true
        return button
    }()
    
    private lazy var monthlyButton: ImageButton = {
        let button = ImageButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = SubscriptionType.month.rawValue
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        button.setTitle("Month Plan".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    private lazy var yearlyButton: ImageButton = {
        let button = ImageButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = SubscriptionType.yearly.rawValue
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        button.setTitle("Year Plan".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBackground
        
        return button
    }()
    
    private lazy var termOfUseButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedTerms(_:)), for: .touchUpInside)
        button.setTitle("termOfUse".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setUnderline()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        
        return button
    }()
    
    private lazy var privacyPolicyButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedTerms(_:)), for: .touchUpInside)
        button.setTitle("privacy Policy".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setUnderline()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        
        return button
    }()
    
    /// 광고를 끝까지 보면 일정 시간 Pro 기능을 쓸 수 있다.
    private lazy var rewardedPassButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.image = UIImage(systemName: "play.rectangle.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .systemPink
        configuration.baseForegroundColor = .systemPink
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedRewardedPassButton), for: .touchUpInside)
        
        return button
    }()
    
    /// EU·영국 등 광고 동의가 필요한 지역에서만 보인다.
    private lazy var adPrivacyButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedAdPrivacyButton), for: .touchUpInside)
        button.setTitle("Ad Privacy Settings".localized, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setUnderline()
        button.isHidden = true
        
        return button
    }()
    
    private lazy var premiumContentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startPremiumButton)
        view.addSubview(rewardedPassButton)
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var startPremiumButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedStartPreminumButton), for: .touchUpInside)
        button.setTitle("Start Premium".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tintColor = .label
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemPink
        
        return button
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = priceInfo
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        
        return label
    }()
    
    private static func boldFont(_ style: UIFont.TextStyle) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: style)
        let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) ?? base.fontDescriptor
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    // MARK: - Properties
    private let storKitManager: StoreKitManager = StoreKitManager.shared
    private var priceInfo: String = "" {
        didSet {
            priceLabel.text = priceInfo
        }
    }

    /// 상품 ID별 현지 통화 가격. App Store에서 받아온다.
    private var displayPrices: [String: String] = [:] {
        didSet { updatePriceInfo() }
    }

    private var subscriptionType: SubscriptionType = .week {
        didSet { updatePriceInfo() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
        updateRewardedPassButton()
        Task { displayPrices = await storKitManager.displayPrices() }
    }

    private func updatePriceInfo() {
        guard let price = displayPrices[subscriptionType.identifier] else {
            priceInfo = ""
            return
        }
        switch subscriptionType {
        case .week: priceInfo = price + " " + "/week".localized
        case .month: priceInfo = price + " " + "/month".localized
        case .yearly: priceInfo = price + " " + "/year".localized
        }
    }
}

extension IAPOnboardingViewController {
    private func initLayout() {
        view.backgroundColor = .systemBackground
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        [scrollView, premiumContentsView, priceLabel, closeButton, dimmedView].forEach { view.addSubview($0) }
        dimmedView.addSubview(indicatorView)
        scrollView.addSubview(scrollContentsView)
        [titleLabel, infoLabel, monthlyButton, weeklyButton, yearlyButton, termOfUseButton, privacyPolicyButton, adPrivacyButton].forEach { scrollContentsView.addSubview($0) }
    }
    
    private func addConstraints() {
        // iPad·가로 화면에서 콘텐츠가 너무 넓어지지 않게 가운데 최대 560pt 폭으로 제한한다.
        // (readableContentGuide 는 iPad 세로에서 거의 전체 폭이 돼서 따로 둔다)
        let readable = UILayoutGuide()
        view.addLayoutGuide(readable)
        let preferredWidth = readable.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -30)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            readable.topAnchor.constraint(equalTo: view.topAnchor),
            readable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            readable.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            readable.widthAnchor.constraint(lessThanOrEqualToConstant: 560),
            readable.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, constant: -30),
            preferredWidth,
        ])
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            indicatorView.centerYAnchor.constraint(equalTo: dimmedView.centerYAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: dimmedView.centerXAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 240),
            indicatorView.heightAnchor.constraint(equalToConstant: 240),
            
            closeButton.topAnchor.constraint(equalTo: scrollContentsView.safeAreaLayoutGuide.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: scrollContentsView.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 100),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            // 아래 고정 영역(가격 + 구매 버튼 + 광고 버튼) 위에서 끝나야 약관 링크가 가려지지 않는다.
            scrollView.bottomAnchor.constraint(equalTo: priceLabel.topAnchor, constant: -8),
            
            scrollContentsView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentsView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentsView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            premiumContentsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            premiumContentsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            premiumContentsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            premiumContentsView.heightAnchor.constraint(equalToConstant: 150),
            
            startPremiumButton.topAnchor.constraint(equalTo: premiumContentsView.safeAreaLayoutGuide.topAnchor, constant: 15),
            startPremiumButton.leadingAnchor.constraint(equalTo: readable.leadingAnchor),
            startPremiumButton.trailingAnchor.constraint(equalTo: readable.trailingAnchor),
            startPremiumButton.heightAnchor.constraint(equalToConstant: 70),
            
            rewardedPassButton.topAnchor.constraint(equalTo: startPremiumButton.bottomAnchor, constant: 10),
            rewardedPassButton.leadingAnchor.constraint(equalTo: startPremiumButton.leadingAnchor),
            rewardedPassButton.trailingAnchor.constraint(equalTo: startPremiumButton.trailingAnchor),
            rewardedPassButton.bottomAnchor.constraint(equalTo: premiumContentsView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        
        let contentViewHeight = scrollContentsView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: closeButton.centerYAnchor),
            // 오른쪽 위 닫기 버튼과 겹치지 않게 양쪽을 같은 만큼 띄워 가운데를 유지한다. (긴 언어는 두 줄로 내려간다)
            titleLabel.leadingAnchor.constraint(equalTo: readable.leadingAnchor, constant: 52),
            titleLabel.trailingAnchor.constraint(equalTo: readable.trailingAnchor, constant: -52),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            infoLabel.leadingAnchor.constraint(equalTo: readable.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: readable.trailingAnchor),
            
            weeklyButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 50),
            weeklyButton.heightAnchor.constraint(equalToConstant: view.frame.height / 10),
            weeklyButton.leadingAnchor.constraint(equalTo: readable.leadingAnchor),
            weeklyButton.trailingAnchor.constraint(equalTo: readable.trailingAnchor),
            weeklyButton.bottomAnchor.constraint(equalTo: monthlyButton.topAnchor, constant: -15),
            
            monthlyButton.heightAnchor.constraint(equalToConstant: view.frame.height / 10),
            monthlyButton.leadingAnchor.constraint(equalTo: readable.leadingAnchor),
            monthlyButton.trailingAnchor.constraint(equalTo: readable.trailingAnchor),
            monthlyButton.bottomAnchor.constraint(equalTo: yearlyButton.topAnchor, constant: -15),
            
            yearlyButton.heightAnchor.constraint(equalToConstant: view.frame.height / 10),
            yearlyButton.leadingAnchor.constraint(equalTo: readable.leadingAnchor),
            yearlyButton.trailingAnchor.constraint(equalTo: readable.trailingAnchor),
            yearlyButton.bottomAnchor.constraint(equalTo: termOfUseButton.safeAreaLayoutGuide.topAnchor, constant: -15),
            
            termOfUseButton.heightAnchor.constraint(equalTo: yearlyButton.heightAnchor, multiplier: 0.5),
            termOfUseButton.trailingAnchor.constraint(equalTo: yearlyButton.centerXAnchor, constant: -15),
            termOfUseButton.leadingAnchor.constraint(greaterThanOrEqualTo: readable.leadingAnchor),
            termOfUseButton.bottomAnchor.constraint(equalTo: adPrivacyButton.topAnchor, constant: -4),
            
            privacyPolicyButton.heightAnchor.constraint(equalTo: yearlyButton.heightAnchor, multiplier: 0.5),
            privacyPolicyButton.leadingAnchor.constraint(equalTo: yearlyButton.centerXAnchor, constant: 15),
            privacyPolicyButton.trailingAnchor.constraint(lessThanOrEqualTo: readable.trailingAnchor),
            privacyPolicyButton.bottomAnchor.constraint(equalTo: adPrivacyButton.topAnchor, constant: -4),
            
            adPrivacyButton.bottomAnchor.constraint(equalTo: scrollContentsView.bottomAnchor, constant: -16),
            adPrivacyButton.centerXAnchor.constraint(equalTo: scrollContentsView.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: readable.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: readable.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: startPremiumButton.safeAreaLayoutGuide.topAnchor, constant: -20),
        ])
    }
    
    private func donePurchases(completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Done".localized,
                                      message: "Purchase is completed".localized,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok!".localized, style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    private func startIndicator() {
        indicatorView.startAnimating()
        indicatorView.alpha = 0.6
        dimmedView.alpha = 0.6
    }
    
    private func stopIndicator() {
        indicatorView.stopAnimating()
        indicatorView.alpha = 0
        dimmedView.alpha = 0
    }
    
    /// 이용권이 남아 있으면 만료 시각을 보여 주고 버튼을 막는다.
    private func updateRewardedPassButton() {
        if RewardedPassManager.isPassActive, let expiration = RewardedPassManager.passExpirationDate {
            rewardedPassButton.configuration?.title = "Pro Pass Active %@".localized(with: [Self.expirationText(expiration)])
            rewardedPassButton.isEnabled = false
        } else {
            rewardedPassButton.configuration?.title = "Watch Ad Pro Pass %@".localized(with: [RewardedPassManager.passDurationText])
            rewardedPassButton.isEnabled = true
        }
        adPrivacyButton.isHidden = !AdConsentManager.shared.isPrivacyOptionsRequired
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok!".localized, style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    /// 예: "오늘 오후 9:30", "Today at 9:30 PM"
    private static func expirationText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }
}

// MARK: - User Interactions
extension IAPOnboardingViewController {
    @objc
    private func tappedCloseButton() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func tappedButton(button: UIButton) {
        print(#function)
        guard let type = SubscriptionType(rawValue: button.tag) else { return }
        
        subscriptionType = type
        [weeklyButton, monthlyButton, yearlyButton].forEach { $0.isSelected = false }
        
        button.isSelected.toggle()
    }
    
    @objc
    private func tappedTerms(_ button: UIButton) {
        // Safari에서 돌아올 때 앱 오프닝 광고를 띄우지 않는다.
        AppOpenAdManager.shared.skipNextAd()
        if button == termOfUseButton {
            let urlString = "https://dy-solution.kr/terms.html"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } else if button == privacyPolicyButton {
            let urlString = "https://dy-solution.kr/privacy.html#acha-charge"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @objc
    private func tappedRewardedPassButton() {
        startIndicator()
        Task { @MainActor in
            let outcome = await RewardedPassManager.shared.showRewardedAd(from: self)
            stopIndicator()
            updateRewardedPassButton()
            showAlert(message: outcome.message) { [weak self] in
                // 이용권을 받았으면 구매 화면을 닫는다.
                if outcome == .rewarded {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc
    private func tappedAdPrivacyButton() {
        Task { @MainActor in
            await AdConsentManager.shared.presentPrivacyOptions(from: self)
        }
    }
    
    @objc
    private func tappedStartPreminumButton() {
        print(#function, "subscriptionType: \(subscriptionType)")
//        storKitManager.requestSubscription(with: subscriptionType)
        startIndicator()
        SwiftyStoreKit.purchaseProduct(subscriptionType.identifier, quantity: 1, atomically: true) { result in
            self.stopIndicator()
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.setValue(true, forKey: StringKey.IS_SUBSCRIBED)
            case .error(let error):
                // 결제 실패·취소는 기존 구독 여부와 무관하다. 상태는 refreshSubscriptionStatus()가 판단한다.
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            case .deferred(purchase: let purchase):
                print("Purchase deferred: \(purchase.productId)")
            }
        }
    }
}
