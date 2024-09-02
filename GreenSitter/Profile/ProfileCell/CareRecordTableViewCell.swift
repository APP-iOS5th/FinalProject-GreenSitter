//
//  CareRecordTableViewCell.swift
//  GreenSitter
//
//  Created by 차지용 on 8/19/24.
//

import UIKit

class CareRecordTableViewCell: UITableViewCell {
    lazy var statusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "DominentColor")
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(named: "SeparatorsOpaque")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "SeparatorsOpaque")
        return label
    }()
    
    lazy var plantImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "로고7")
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(statusView)
        statusView.addSubview(statusLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(plantImage)
        
        NSLayoutConstraint.activate([
            // statusView 제약 조건
            statusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            statusView.widthAnchor.constraint(equalToConstant: 100),
            statusView.heightAnchor.constraint(equalToConstant: 30),
            
            // statusLabel이 statusView 중앙에 위치하도록 설정
            statusLabel.centerXAnchor.constraint(equalTo: statusView.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
            
            // titleLabel이 statusView 아래에 배치되도록 설정
            titleLabel.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: plantImage.leadingAnchor, constant: -10),
            
            // bodyLabel 제약 조건
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // timeLabel 제약 조건
            timeLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // plantImage 제약 조건
            plantImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            plantImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plantImage.widthAnchor.constraint(equalToConstant: 50),
            plantImage.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
