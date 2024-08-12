//
//  ProfileTableViewCell.swift
//  GreenSitter
//
//  Created by 차지용 on 8/12/24.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "SeparatorsOpaque")
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "SeparatorsOpaque"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 추가: 아이콘 이미지 뷰의 width와 height 제약 조건을 별도로 저장
    var iconWidthConstraint: NSLayoutConstraint!
    var iconHeightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(actionButton)
        contentView.addSubview(iconImageView)
        
        iconWidthConstraint = iconImageView.widthAnchor.constraint(equalToConstant: 30)
        iconHeightConstraint = iconImageView.heightAnchor.constraint(equalToConstant: 30)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconWidthConstraint,
            iconHeightConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 아이콘을 숨기거나 보여줄 때 호출할 메서드
    func setIconHidden(_ hidden: Bool) {
        iconImageView.isHidden = hidden
        iconWidthConstraint.constant = hidden ? 0 : 30
        iconHeightConstraint.constant = hidden ? 0 : 30
    }
}
