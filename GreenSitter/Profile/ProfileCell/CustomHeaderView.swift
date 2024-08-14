//
//  CustomHeaderView.swift
//  GreenSitter
//
//  Created by 차지용 on 8/14/24.
//

import UIKit

import UIKit

class CustomHeaderView: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    let editButton = UIButton(type: .system)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        editButton.setTitle("수정하기", for: .normal)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            editButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
