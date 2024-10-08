//
//  ChatMessageTableViewCell.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/18/24.
//

import UIKit
import Kingfisher

class ChatMessageTableViewCell: UITableViewCell {
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom?
    
    var isIncoming: Bool? {
        didSet {
            bubbleView.backgroundColor = isIncoming! ? .fillPrimary : .dominent
            messageLabel.textColor = isIncoming! ? .labelsPrimary : .white
            
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
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 4, width: 52, height: 52)
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        if isIncoming ?? true {
            contentView.addSubview(profileImageView)
            
            // timeLabel이 충분한 공간을 차지하도록 우선순위 설정
            timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            // messageLabel은 공간이 남을 때 확장되도록 설정
            messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
                
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                profileImageView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 52),
                profileImageView.heightAnchor.constraint(equalToConstant: 52),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 5),
                timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100)
            ])
        } else {
            contentView.addSubview(isReadLabel)
            
            // isReadLabel과 timeLabel이 충분한 공간을 차지하도록 우선순위 설정
            isReadLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            isReadLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            // messageLabel은 공간이 남을 때 확장되도록 설정
            messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            NSLayoutConstraint.activate([
                isReadLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                isReadLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 100),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: isReadLabel.trailingAnchor, constant: 5),
                
                messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
                messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
                messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5),
                bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
            ])
        }
    }
    
    // MARK: - Cell 구성
    func configure(date: Date) {
        // 프로필 이미지 설정
        let profileImage: String?
        if chatRoom?.userId == chatViewModel?.user?.id {
            profileImage = chatRoom?.postUserProfileImage
        } else {
            profileImage = chatRoom?.userProfileImage
        }
        
        guard let profileImageUrl = URL(string: profileImage!) else {
            return
        }
        
        // 이미지 다운로드 실패 시 기본 이미지로 설정
        let placeholderImage = UIImage(named: "profileIcon")
        
//        chatViewModel?.downloadImage(from: profileImageUrl, to: profileImageView, placeholderImage: placeholderImage)
        // Kingfisher를 사용하여 이미지 다운로드 및 설정
        profileImageView.kf.setImage(with: profileImageUrl, placeholder: placeholderImage)
        
        // 메세지 시간 설정
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "a h:mm" // ex) 오전 9시 05분
        let timeString = formatter.string(from: date)
        
        timeLabel.text = timeString
        
        // 메세지가 여러 줄이 될 경우 변경된 레이아웃으로 즉시 반영되도록 조치
        layoutIfNeeded()
    }

}
