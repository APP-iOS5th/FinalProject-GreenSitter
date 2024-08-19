//
//  IntroductionTableCell.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit

class IntroductionTableCell: UITableViewCell {
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "자기소개"
        label.numberOfLines = 0 // 여러 줄로 설정
        label.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈 설정
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "SeparatorsOpaque")
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bodyLabel)
        
        
        NSLayoutConstraint.activate([
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            bodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
