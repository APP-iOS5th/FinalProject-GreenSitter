//
//  ChatTableViewCell.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/8/24.
//

import UIKit
import Kingfisher

class ChatTableViewCell: UITableViewCell {
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // 프로필 이미지
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 4, width: 52, height: 52)
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // 스택뷰 1
    private lazy var leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // 닉네임
    private lazy var userNicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // 위치
    private lazy var userLocationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .labelsSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // 알림 여부
    private lazy var notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .labelsSecondary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // 마지막 메세지 내용
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .labelsSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // 스택뷰 2
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // 마지막 메세지 시간
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .labelsSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // 안 읽은 메세지 수
    private lazy var unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        view.layer.cornerRadius = view.bounds.height/2
        view.layer.masksToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Cell 구성
    func configure(userId: String) {
        // 프로필 이미지 설정
        guard let profileImage = chatRoom?.userId == userId ? chatRoom?.postUserProfileImage : chatRoom?.userProfileImage else {
            return
        }
        guard let profileImageUrl = URL(string: profileImage) else {
            return
        }
        
        // 이미지 다운로드 실패 시 기본 이미지로 설정
        let placeholderImage = UIImage(named: "profileIcon")
        
        //        chatViewModel?.downloadImage(from: profileImageUrl, to: profileImageView, placeholderImage: placeholderImage)
        // Kingfisher를 사용하여 이미지 다운로드 및 설정
        profileImageView.kf.setImage(with: profileImageUrl, placeholder: placeholderImage)
        
        // 닉네임
        let nickname = chatRoom?.userId == userId ? chatRoom?.postUserNickname: chatRoom?.userNickname
        userNicknameLabel.text = nickname
        
        // 위치
        //        let location = chatRoom.userId == userId ? chatRoom.postUserLocation : chatRoom.userLocation
        //        // TODO: - 지번 주소로 변경
        //        userLocationLabel.text = location
        
        // 임시 위치 데이터
        //        userLocationLabel.text = "상도동"
        
        // 알림 여부
        guard let notification = chatRoom?.userId == userId ? chatRoom?.userNotification : chatRoom?.postUserNotification else {
            return
        }
        notificationImageView.image = notification ? UIImage(systemName: "bell.fill") : UIImage(systemName: "bell.slash.fill")
        
        // 마지막 메세지 내용
        guard let lastMessage = chatViewModel?.lastMessages[chatRoom!.id]?.last else {
            lastMessageLabel.text = ""
            dateLabel.text = ""
            circleView.backgroundColor = .clear
            unreadCountLabel.text = ""
            return
        }
        
        switch lastMessage.messageType {
        case .text:
            lastMessageLabel.text = lastMessage.text
        case .image:
            lastMessageLabel.text = "사진"
        case .plan:
            lastMessageLabel.text = "약속이 정해졌습니다."
        case .review:
            lastMessageLabel.text = "거래가 완료되었습니다."
        }
        
        // 마지막 메세지 시간
        let timeAgoString = timeAgo(from: lastMessage.updateDate)
        
        dateLabel.text = timeAgoString

        
        // 안 읽은 메세지 수
        /// read = false인 메세지 수
        guard let unreadCount = chatViewModel?.unreadMessages[chatRoom!.id]?.count else {
            return
        }
        
        if unreadCount > 0 {
            circleView.backgroundColor = .dominent
            unreadCountLabel.text = "\(unreadCount)"
        // 안 읽은 메세지 수가 0일 때 초기화
        } else if unreadCount == 0 {
            circleView.backgroundColor = .clear
            unreadCountLabel.text = ""
        }
    }
    
    // MARK: - 메세지 시간 포맷 설정
    // 현재 시간과 메세지가 온 시간 차이를 구하는 함수
    private func timeAgo(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .month, .year], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)개월 전"
        } else if let week = components.second, week / (60 * 60 * 24 * 7) > 0 {
            return "\(week)주 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else if let second = components.second, second > 0 {
            return "\(second)초 전"
        } else {
            return "지금"
        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        leftStackView.addSubview(userNicknameLabel)
        leftStackView.addSubview(lastMessageLabel)
        leftStackView.addSubview(userLocationLabel)
        leftStackView.addSubview(notificationImageView)
        
        circleView.addSubview(unreadCountLabel)
        
        rightStackView.addSubview(dateLabel)
        rightStackView.addSubview(circleView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(leftStackView)
        contentView.addSubview(rightStackView)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 52),
            profileImageView.heightAnchor.constraint(equalToConstant: 52),
            
            leftStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            leftStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftStackView.widthAnchor.constraint(equalToConstant: 200),
            
            userNicknameLabel.topAnchor.constraint(equalTo: leftStackView.topAnchor, constant: 20),
            userNicknameLabel.leadingAnchor.constraint(equalTo: leftStackView.leadingAnchor),
            
//            userLocationLabel.leadingAnchor.constraint(equalTo: userNicknameLabel.trailingAnchor, constant: 10),
//            userLocationLabel.centerYAnchor.constraint(equalTo: userNicknameLabel.centerYAnchor),
            
//            notificationImageView.leadingAnchor.constraint(equalTo: userLocationLabel.trailingAnchor, constant: 10),
            notificationImageView.leadingAnchor.constraint(equalTo: userNicknameLabel.trailingAnchor, constant: 10),
            notificationImageView.centerYAnchor.constraint(equalTo: userNicknameLabel.centerYAnchor),
            notificationImageView.widthAnchor.constraint(equalToConstant: 15),
            notificationImageView.heightAnchor.constraint(equalToConstant: 15),
            
            lastMessageLabel.topAnchor.constraint(equalTo: userNicknameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.bottomAnchor.constraint(equalTo: leftStackView.bottomAnchor, constant: -20),
            lastMessageLabel.leadingAnchor.constraint(equalTo: leftStackView.leadingAnchor),
            lastMessageLabel.trailingAnchor.constraint(equalTo: leftStackView.trailingAnchor),

            rightStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rightStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightStackView.widthAnchor.constraint(equalToConstant: 60),
            
            dateLabel.topAnchor.constraint(equalTo: rightStackView.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: rightStackView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: rightStackView.trailingAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: rightStackView.centerXAnchor),
            
            circleView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            circleView.centerXAnchor.constraint(equalTo: rightStackView.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 20),
            circleView.heightAnchor.constraint(equalToConstant: 20),
            
            unreadCountLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            unreadCountLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            unreadCountLabel.widthAnchor.constraint(equalToConstant: 20),
            unreadCountLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

}
