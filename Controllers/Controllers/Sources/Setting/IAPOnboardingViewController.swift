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
        label.text = "Upgrade to Pro"
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 40)
        
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Notifications can also be sent to the controller's battery information during game play".localized
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 26)
        
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
        
        return button
    }()
    
    private lazy var privacyPolicyButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedTerms(_:)), for: .touchUpInside)
        button.setTitle("privacy Policy".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setUnderline()
        
        return button
    }()
    
    private lazy var premiumContentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startPremiumButton)
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
        label.font = .systemFont(ofSize: 25)
        
        return label
    }()
    
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
        [titleLabel, infoLabel, monthlyButton, weeklyButton, yearlyButton, termOfUseButton, privacyPolicyButton].forEach { scrollContentsView.addSubview($0) }
    }
    
    private func addConstraints() {
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
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollContentsView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentsView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentsView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            premiumContentsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            premiumContentsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            premiumContentsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            premiumContentsView.heightAnchor.constraint(equalToConstant: 100),
            
            startPremiumButton.topAnchor.constraint(equalTo: premiumContentsView.safeAreaLayoutGuide.topAnchor, constant: 15),
            startPremiumButton.leadingAnchor.constraint(equalTo: premiumContentsView.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            startPremiumButton.trailingAnchor.constraint(equalTo: premiumContentsView.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            startPremiumButton.bottomAnchor.constraint(equalTo: premiumContentsView.safeAreaLayoutGuide.bottomAnchor, constant: -15),
        ])
        
        let contentViewHeight = scrollContentsView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: scrollContentsView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: scrollContentsView.trailingAnchor, constant: -20),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            infoLabel.leadingAnchor.constraint(equalTo: scrollContentsView.leadingAnchor, constant: 15),
            infoLabel.trailingAnchor.constraint(equalTo: scrollContentsView.trailingAnchor, constant: -15),
            
            weeklyButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 50),
            weeklyButton.heightAnchor.constraint(equalToConstant: view.frame.height / 10),
            weeklyButton.leadingAnchor.constraint(equalTo: scrollContentsView.leadingAnchor, constant: 15),
            weeklyButton.trailingAnchor.constraint(equalTo: scrollContentsView.trailingAnchor, constant: -15),
            weeklyButton.bottomAnchor.constraint(equalTo: monthlyButton.topAnchor, constant: -15),
            
            monthlyButton.heightAnchor.constraint(equalToConstant: view.frame.height / 10),
            monthlyButton.leadingAnchor.constraint(equalTo: scrollContentsView.leadingAnchor, constant: 15),
            monthlyButton.trailingAnchor.constraint(equalTo: scrollContentsView.trailingAnchor, constant: -15),
            monthlyButton.bottomAnchor.constraint(equalTo: yearlyButton.topAnchor, constant: -15),
            
            yearlyButton.heightAnchor.constraint(equalToConstant: view.frame.height / 10),
            yearlyButton.leadingAnchor.constraint(equalTo: scrollContentsView.leadingAnchor, constant: 15),
            yearlyButton.trailingAnchor.constraint(equalTo: scrollContentsView.trailingAnchor, constant: -15),
            yearlyButton.bottomAnchor.constraint(equalTo: termOfUseButton.safeAreaLayoutGuide.topAnchor, constant: -15),
            
            termOfUseButton.heightAnchor.constraint(equalTo: yearlyButton.heightAnchor, multiplier: 0.5),
            termOfUseButton.trailingAnchor.constraint(equalTo: yearlyButton.centerXAnchor, constant: -15),
            termOfUseButton.bottomAnchor.constraint(equalTo: scrollContentsView.safeAreaLayoutGuide.bottomAnchor, constant: -(premiumContentsView.frame.height + 150)),
            
            privacyPolicyButton.heightAnchor.constraint(equalTo: yearlyButton.heightAnchor, multiplier: 0.5),
            privacyPolicyButton.leadingAnchor.constraint(equalTo: yearlyButton.centerXAnchor, constant: 15),
            privacyPolicyButton.bottomAnchor.constraint(equalTo: scrollContentsView.safeAreaLayoutGuide.bottomAnchor, constant: -(premiumContentsView.frame.height + 150)),
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
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
        if button == termOfUseButton {
            let urlString = "https://voracious-pigment-aaf.notion.site/Terms-edb94eab4fd74b6ca85c3aac0b17b7d1?pvs=4"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } else if button == privacyPolicyButton {
            let urlString = "https://voracious-pigment-aaf.notion.site/30f23504cad7456e9472ac959c3e95b8?pvs=4"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
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
