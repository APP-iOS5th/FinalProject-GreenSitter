//
//  ChatMessageTableViewCell.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/18/24.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {
    // TODO: - 사용자의 Id와 Message의 SenderId를 비교
    var isIncoming: Bool = false {
        didSet {
            bubbleView.backgroundColor = isIncoming ? .fillTertiary : .dominent
            messageLabel.textColor = isIncoming ? .labelsPrimary : .white
            
            setupUI()
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
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo7")
        
        return imageView
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
        
        // 제약조건 재설정을 위한 기존 제약조건 제거
        NSLayoutConstraint.deactivate(contentView.constraints)
        
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
                bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100)
            ])
        } else {
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
                messageLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 100),
                bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            ])
        }
    }

}
