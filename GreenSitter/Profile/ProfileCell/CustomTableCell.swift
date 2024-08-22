//
//  CareInfoTableCell.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit

class CustomTableCell: UITableViewCell {
    
    lazy var iconImage: UIImageView = {
        let image = UIImageView()
        image.tintColor = UIColor(named: "DominentColor")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var textsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the state of the cell here
        iconImage.image = nil
        textsLabel.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconImage)
        contentView.addSubview(textsLabel)
        NSLayoutConstraint.activate([
            iconImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 24),
            iconImage.heightAnchor.constraint(equalToConstant: 24),
            
            // 텍스트 레이블 제약 조건
            textsLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 16),
            textsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
