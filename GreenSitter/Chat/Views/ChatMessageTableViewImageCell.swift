//
//  ChatMessageTableViewImageCell.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/21/24.
//

import UIKit

class ChatMessageTableViewImageCell: UITableViewCell {
    var isIncoming: Bool = false {
        didSet {
            setupUI()
        }
    }
    
    var isRead: Bool = false {
        didSet {
            isReadLabel.text = isRead ? "" : "읽지 않음"
        }
    }
    
    var images: [UIImage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.updateImageStackView()
            }
        }
    }
    
    var imageViews = [UIImageView]()
    
    lazy var imageStackView: UIStackView = {
       let imageStackView = UIStackView(arrangedSubviews: imageViews)
        imageStackView.axis = .horizontal
        imageStackView.spacing = 7
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        return imageStackView
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo7")
        
        return imageView
    }()
    
    // TODO: - 오전 12시에 날짜 출력
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .fillTertiary
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
        label.text = "2024년 8월 19일"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "오후 1:43"
        label.textColor = .labelsSecondary
        label.font = UIFont.systemFont(ofSize: 11)
        
        return label
    }()
    
    lazy var isReadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .complementary
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        updateImageStackView()
        contentView.addSubview(imageStackView)
        contentView.addSubview(timeLabel)
        
        // 제약조건 재설정을 위한 기존 제약조건 제거
        NSLayoutConstraint.deactivate(contentView.constraints)
        
        if isIncoming {
            contentView.addSubview(profileImageView)
            
            NSLayoutConstraint.activate([
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                profileImageView.topAnchor.constraint(equalTo: imageStackView.topAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 52),
                profileImageView.heightAnchor.constraint(equalToConstant: 52),
                
                imageStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                imageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                imageStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
                
                timeLabel.bottomAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: imageStackView.trailingAnchor, constant: 5),
                timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100)
            ])
        } else {
            contentView.addSubview(isReadLabel)
            
            NSLayoutConstraint.activate([
                isReadLabel.bottomAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: -5),
                isReadLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 100),
                
                timeLabel.bottomAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: isReadLabel.trailingAnchor, constant: 5),
                
                imageStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                imageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                imageStackView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5),
                imageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            ])
        }
    }
    
    private func updateImageStackView() {
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        imageViews = images.map { image in
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = 4
            imageView.backgroundColor = .white
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            switch images.count {
            case 1: NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 150),
                imageView.heightAnchor.constraint(equalToConstant: 150),
            ])
            case 2: NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100),
            ])
            case 3: NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 70),
                imageView.heightAnchor.constraint(equalToConstant: 70),
            ])
            default: NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100),
            ])
            }
            
            return imageView
        }
        
        imageViews.forEach { imageStackView.addArrangedSubview($0) }

    }
}

