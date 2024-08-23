//
//  ChatMessageTableViewCell.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/18/24.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {
    var isIncoming: Bool = false {
        didSet {
            bubbleView.backgroundColor = isIncoming ? .fillTertiary : .dominent
            messageLabel.textColor = isIncoming ? .labelsPrimary : .white
            
            setupUI()
        }
    }
    
    var isRead: Bool? {
        didSet {
            isReadLabel.text = isRead! ? "" : "읽지 않음"
        }
    }
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .fillTertiary
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
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
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(bubbleView)
        contentView.addSubview(timeLabel)
        
        // 제약조건 재설정을 위한 기존 제약조건 제거
        NSLayoutConstraint.deactivate(contentView.constraints)
        // profileImageView와 isReadLabel 제거
        profileImageView.removeFromSuperview()
        isReadLabel.removeFromSuperview()
        
        if isIncoming {
            contentView.addSubview(profileImageView)
            
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
                messageLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                profileImageView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 52),
                profileImageView.heightAnchor.constraint(equalToConstant: 52),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 5),
                timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100)
            ])
        } else {
            contentView.addSubview(isReadLabel)
            
            NSLayoutConstraint.activate([
                isReadLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                isReadLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 100),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: isReadLabel.trailingAnchor, constant: 5),
                
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
                messageLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5),
                bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            ])
        }
    }

}
