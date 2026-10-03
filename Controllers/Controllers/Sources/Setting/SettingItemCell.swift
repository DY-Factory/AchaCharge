//
//  SettingItemCell.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/28.
//

import UIKit

final class SettingItemCell: UITableViewCell {

    static let reuseIdentifier: String = String(describing: SettingItemCell.self)
    
    private lazy var typeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("IAP Test", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setData(_ info: SettingItemDTO) {
        typeImageView.image = UIImage(systemName: info.typeImageName)
        titleLabel.text = info.title.localized
        if let buttonTitle = info.buttonTitle {
            // TODO: Button Title
            addButton()
            rightButton.setTitle(buttonTitle, for: .normal)
            rightButton.setTitleColor(UIColor.label, for: .normal)
        }
    }

    /// 우측 버튼의 타이틀을 갱신한다. (예: 충전 알림 기준의 현재 임계값 표시)
    public func updateButtonTitle(_ title: String) {
        rightButton.setTitle(title, for: .normal)
        rightButton.setTitleColor(UIColor.label, for: .normal)
    }
}

extension SettingItemCell {
    private func initLayout() {
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        [typeImageView,
            titleLabel,].forEach { addSubview($0) }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            typeImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            typeImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2),
            typeImageView.widthAnchor.constraint(equalTo: typeImageView.heightAnchor, multiplier: 1.0),
            typeImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: typeImageView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func addButton() {
        addSubview(rightButton)
        
        NSLayoutConstraint.activate([
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
