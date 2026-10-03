//
//  SettingViewController.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/23.
//

import UIKit
import SwiftUI
import SwiftyStoreKit

final class SettingViewController: UIViewController {
    
    // MARK: - Section & TableView
    enum SectionType: Int {
        case premium = 0
        case csInfo = 1
    }
    
    enum PremiumSectionType: String {
        case premium
        case restorepurchase
        case chargeAlertThreshold = "chargealertthreshold"
    }
    
    enum CsInfoSectionType: String {
        case info
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(SettingItemCell.self, forCellReuseIdentifier: SettingItemCell.reuseIdentifier)
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = 50.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // MARK: - Property
    private var sectionType: [SectionType] = [.premium, .csInfo]
    private var settingItems: [SettingItemDTO] = []
    
    private var premiumItems: [SettingItemDTO] = []
    private var csInfoItems: [SettingItemDTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchJSON()
        initLayout()
        configureTableView()
        StoreObserver.shared.resotreDelegate = self
    }
}

extension SettingViewController {
    private func fetchJSON() {
        var settingItemsDataDecoder = CustomJSONDecoder<[SettingItemDTO]>()
        guard let decodedItems = settingItemsDataDecoder.decode(jsonFileName: "SettingItems") else { return }
        settingItems = decodedItems
        premiumItems = settingItems.filter { $0.sectionTypeCode == 0 }
        csInfoItems = settingItems.filter { $0.sectionTypeCode == 1 }
    }
    
    private func initLayout() {
        title = MainTabView.TabType.setting.title
        view.backgroundColor = .systemBackground
        addSubViews()
        addConstraints()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func addSubViews() {
        [tableView].forEach { view.addSubview($0) }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func donePurchases() {
        let alert = UIAlertController(title: "Done".localized,
                                      message: "Purchase is completed".localized,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok!".localized, style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate Method
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionType.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionType[section] {
        case .premium:
            return premiumItems.count
        case .csInfo:
            return csInfoItems.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingItemCell.reuseIdentifier, for: indexPath)
        guard let convertedCell = cell as? SettingItemCell else { return cell }
        
        switch sectionType[indexPath.section] {
        case .premium:
            guard let item = premiumItems[safe: indexPath.row] else { return cell }
            convertedCell.setData(item)
            if premiumType(of: item) == .chargeAlertThreshold {
                convertedCell.updateButtonTitle("\(UserDefaults.shared.batteryNotificationThreshold)%")
            }

            return convertedCell
            
        case .csInfo:
            guard let item = csInfoItems[safe: indexPath.row] else { return cell }
            convertedCell.setData(item)
            
            return convertedCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch sectionType[indexPath.section] {
        case .premium:

            guard let item = premiumItems[safe: indexPath.row],
                  let type = premiumType(of: item) else { return }
            switch type {
            case .premium:
                tappedPurchaseButton()
                print("premium tapped!")
            case .restorepurchase:
                tappedRestoreButton()
                print("restorepurchase")
            case .chargeAlertThreshold:
                presentThresholdPicker(at: indexPath)
                print("chargeAlertThreshold tapped!")
            }
            
        case .csInfo:
            guard let title = csInfoItems[safe: indexPath.row]?.title else { return }
            print("item.title: \(title)")
            let typeString = title.replacingOccurrences(of: " ", with: "").lowercased()
            
            guard let type = CsInfoSectionType(rawValue: typeString) else { return }
            
            switch type {
            case .info:
                let vc = UIHostingController(rootView: InfoView(
                    isPresented: { self.dismiss(animated: true)}
                ))
                vc.modalPresentationStyle = .pageSheet
                self.present(vc, animated: true)
            }
        }
    }
    
}

// MARK: - User Interaction
extension SettingViewController {
    @objc private func tappedPurchaseButton() {
        guard !StoreKitManager.shared.isSubscribed else {
            let alert = UIAlertController(title: nil, message: "Already Subscribing !".localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok!".localized, style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            
            return
        }
        let onboardingVC = IAPOnboardingViewController()
        onboardingVC.modalPresentationStyle = .overFullScreen
        
        self.present(onboardingVC, animated: true)
    }
    
    @objc
    private func tappedRestoreButton() {
        StoreObserver.shared.restorePurchases()
    }
}

// MARK: - Charge Alert Threshold
extension SettingViewController {
    /// 설정 행의 title 을 PremiumSectionType 으로 변환한다.
    private func premiumType(of item: SettingItemDTO) -> PremiumSectionType? {
        let typeString = item.title.replacingOccurrences(of: " ", with: "").lowercased()
        return PremiumSectionType(rawValue: typeString)
    }

    /// 충전 알림 임계값(10/20/30/50%)을 선택하는 액션시트를 띄운다.
    private func presentThresholdPicker(at indexPath: IndexPath) {
        let options = [10, 20, 30, 50]
        let current = UserDefaults.shared.batteryNotificationThreshold

        let alert = UIAlertController(title: "Charge Alert Threshold".localized,
                                      message: "Charge Alert Threshold Message".localized,
                                      preferredStyle: .actionSheet)

        options.forEach { option in
            let checkMark = option == current ? "  ✓" : ""
            let action = UIAlertAction(title: "\(option)%\(checkMark)", style: .default) { [weak self] _ in
                UserDefaults.shared.batteryNotificationThreshold = option
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))

        // iPad 대응: 액션시트는 popover 로 표시되므로 sourceView 지정 필요
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: indexPath)
        }

        present(alert, animated: true)
    }
}

// MARK: - DidRestoredDelegate Method
extension SettingViewController: DidResotreDelegate {
    func didRestored() {
        donePurchases()
    }
    
    
}


struct SettingViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    func makeUIViewController(context: Self.Context) -> UIViewController {
        return SettingViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Self.Context) {
        
    }
    
}
