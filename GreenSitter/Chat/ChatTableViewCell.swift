//
//  ChatTableViewCell.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/8/24.
//

//import FirebaseFirestore
import UIKit

class ChatTableViewCell: UITableViewCell {
    
    // 프로필 이미지
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 4, width: 52, height: 52)
        imageView.layer.cornerRadius = imageView.frame.height/2
        // 임시 색상 처리
//        imageView.layer.backgroundColor = UIColor(.dominent).cgColor
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
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Cell 구성
    func configure(chatRoom: ChatRoom, userId: UUID/*, db: Firestore*/) {
        // 프로필 이미지 설정
        let profileImage = chatRoom.ownerId == userId ? chatRoom.ownerProfileImage : chatRoom.sitterProfileImage
        self.fetchProfileImage(profileImageString: profileImage, userId: userId)
        
        // 닉네임
        let nickname = chatRoom.ownerId == userId ? chatRoom.ownerNickname : chatRoom.sitterNickname
        userNicknameLabel.text = nickname
        
        // 위치
//        if let location = chatRoom.partnerLocation {
//            // TODO: - 지번 주소로 변경
//            userLocationLabel.text = location
//            
//        }
        userLocationLabel.text = "상도동"
        
        // 알림 여부
        notificationImageView.image = chatRoom.notification ? UIImage(systemName: "bell.fill") : UIImage(systemName: "bell.slash.fill")
        
        // 마지막 메세지 내용
        if let text = chatRoom.messages.last?.text {
            lastMessageLabel.text = text
        } else if (chatRoom.messages.last?.image) != nil {
            lastMessageLabel.text = "사진"
        } else if (chatRoom.messages.last?.plan) != nil {
            lastMessageLabel.text = "약속"
        }
        
        // 마지막 메세지 시간
        guard let updateDate = chatRoom.messages.last?.updateDate else {
            return
        }
        let timeAgoString = timeAgo(from: updateDate)
        print(timeAgoString)
        
        dateLabel.text = timeAgoString
        
        // 안 읽은 메세지 수
        /// read = false인 메세지 수
        let unreadCount = chatRoom.messages.filter { !$0.read }.count
        if unreadCount > 0 {
            circleView.backgroundColor = .dominent
            unreadCountLabel.text = "\(unreadCount)"
        }
    }
    
    // MARK: - 프로필 이미지 가져오기
    private func fetchProfileImage(profileImageString: String, userId: UUID) {
        // Firestore에서 프로필 이미지 가져오기
//        let db = Firestore.firestore()
//        let userId = userId
//
//        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
//            guard let self = self, let document = document, document.exists,
//                  let data = document.data(),
//                  let profileImageUrl = data["profileImage"] as? String,
//                  let url = URL(string: profileImageString) else {
//                return
//            }
//
//            self.downloadImage(from: url)
//        }
        
        // 임시 데이터
        guard let profileImageUrl = URL(string: profileImageString) else {
            return
        }
        self.downloadImage(from: profileImageUrl)
    }
    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Failed to download image: \(error?.localizedDescription ?? "")")
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.profileImageView.image = image
                } else {
                    print("Failed to convert data to image")
                }
            }
        }.resume()
    }
    
    // MARK: - 메세지 시간 포맷 설정
    // 현재 시간과 메세지가 온 시간 차이를 구하는 함수
    // TODO: - 테스트 필요
    private func timeAgo(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second, .minute, .hour, .day], from: date, to: now)
        
        if let second = components.second, second == 0 {
            return "지금"
        } else if let second = components.second, second > 0 && second < 60 {
            return "\(second)초 전"
        } else if let minute = components.minute, minute < 60 {
            return "\(minute)분 전"
        } else if let hour = components.hour, hour < 24 {
            return "\(hour)시간 전"
        } else if let day =  components.day, day < 7 {
            return "\(day)일 전"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
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
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 52),
            profileImageView.heightAnchor.constraint(equalToConstant: 52),
            
            leftStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            leftStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftStackView.widthAnchor.constraint(equalToConstant: 200),
            leftStackView.heightAnchor.constraint(equalToConstant: 60),
            
            userNicknameLabel.topAnchor.constraint(equalTo: leftStackView.topAnchor, constant: 10),
            userNicknameLabel.leadingAnchor.constraint(equalTo: leftStackView.leadingAnchor),
            
            userLocationLabel.leadingAnchor.constraint(equalTo: userNicknameLabel.trailingAnchor, constant: 10),
            userLocationLabel.centerYAnchor.constraint(equalTo: userNicknameLabel.centerYAnchor),
            
            notificationImageView.leadingAnchor.constraint(equalTo: userLocationLabel.trailingAnchor, constant: 10),
            notificationImageView.centerYAnchor.constraint(equalTo: userNicknameLabel.centerYAnchor),
            notificationImageView.widthAnchor.constraint(equalToConstant: 15),
            notificationImageView.heightAnchor.constraint(equalToConstant: 15),
            
            lastMessageLabel.topAnchor.constraint(equalTo: userNicknameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.bottomAnchor.constraint(equalTo: leftStackView.bottomAnchor, constant: -10),
            lastMessageLabel.leadingAnchor.constraint(equalTo: leftStackView.leadingAnchor),
            lastMessageLabel.trailingAnchor.constraint(equalTo: leftStackView.trailingAnchor),

            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rightStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightStackView.widthAnchor.constraint(equalToConstant: 45),
            rightStackView.heightAnchor.constraint(equalToConstant: 60),
            
            dateLabel.topAnchor.constraint(equalTo: rightStackView.topAnchor, constant: 10),
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

#Preview {
    let cell = ChatTableViewCell()
    return cell
}


