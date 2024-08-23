//
//  PostDetailViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/10/24.
//

import UIKit
import MapKit
import FirebaseStorage
import FirebaseFirestore

class PostDetailViewController: UIViewController {
    private var postDetailViewModel = PostDetailViewModel()
    
    private let post: Post
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let userProfileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userLevelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2시간 전"
        return label
    }()
    
    private let dividerLine1: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let dividerLine2: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let dividerLine3: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .dominent
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImagesView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let postBodyTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = false
        textView.isSelectable = false
        textView.sizeToFit()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("채팅하기", for: .normal)
        button.backgroundColor = .complementary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = .labelsPrimary
        label.font = .systemFont(ofSize: 16)
        label.text = "거래 희망 장소"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPrimary
        setupUI()
        configure(with: post)
        
        contactButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.postDetailViewModel.chatButtonTapped()
            }
        }, for: .touchUpInside)
        
        postDetailViewModel.onChatButtonTapped = { [weak self] chatRoom in
            self?.navigateToChatDetail(chatRoom: chatRoom)
        }
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(userProfileButton)
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userLevelLabel)
        contentView.addSubview(postTimeLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postImagesView)
        contentView.addSubview(postBodyTextView)
        contentView.addSubview(dividerLine1)
        contentView.addSubview(dividerLine2)
        contentView.addSubview(dividerLine3)
        contentView.addSubview(contactButton)
        contentView.addSubview(mapLabel)
        contentView.addSubview(mapView)
        
        userProfileButton.addTarget(self, action: #selector(userProfileButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            userProfileButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            userProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userProfileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            profileImageView.leadingAnchor.constraint(equalTo: userProfileButton.leadingAnchor),
            profileImageView.topAnchor.constraint(equalTo: userProfileButton.topAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            
            userLevelLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userLevelLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            
            userProfileButton.bottomAnchor.constraint(equalTo: userLevelLabel.bottomAnchor),
            
            postTimeLabel.topAnchor.constraint(equalTo: userLevelLabel.bottomAnchor, constant: 4),
            postTimeLabel.leadingAnchor.constraint(equalTo: userLevelLabel.leadingAnchor),
            
            statusLabel.bottomAnchor.constraint(equalTo: userLevelLabel.bottomAnchor, constant: 50),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.widthAnchor.constraint(equalToConstant: 40),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            postTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 50),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dividerLine1.bottomAnchor.constraint(equalTo: postTitleLabel.topAnchor, constant: 35),
            dividerLine1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine1.widthAnchor.constraint(equalToConstant: 360),
            dividerLine1.heightAnchor.constraint(equalToConstant: 1),
            
            dividerLine2.bottomAnchor.constraint(equalTo: dividerLine1.topAnchor, constant: 300),
            dividerLine2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine2.widthAnchor.constraint(equalToConstant: 360),
            dividerLine2.heightAnchor.constraint(equalToConstant: 1),
            
            dividerLine3.topAnchor.constraint(equalTo: postBodyTextView.bottomAnchor, constant: 10),
            dividerLine3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine3.widthAnchor.constraint(equalToConstant: 360),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            postImagesView.widthAnchor.constraint(equalToConstant: 190),
            postImagesView.heightAnchor.constraint(equalToConstant: 250),
            postImagesView.topAnchor.constraint(equalTo: dividerLine1.bottomAnchor, constant: 20),
            postImagesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            postBodyTextView.topAnchor.constraint(equalTo: dividerLine2.bottomAnchor, constant: 10),
            postBodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postBodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postBodyTextView.widthAnchor.constraint(equalToConstant: 200),
            postBodyTextView.heightAnchor.constraint(equalToConstant: 200),
            
            contactButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            contactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactButton.widthAnchor.constraint(equalToConstant: 100),
            contactButton.heightAnchor.constraint(equalToConstant: 40),
            
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 8),
            
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func loadImageFromStorage(url: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: url)
        
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    private func configure(with post: Post) {
        userNameLabel.text = post.nickname
        postTitleLabel.text = post.postTitle
        postBodyTextView.text = post.postBody
        statusLabel.text = post.postStatus.rawValue
        userLevelLabel.text = LoginViewModel.shared.user?.levelPoint.rawValue // Assume level is set somewhere

        profileImageView.image = UIImage(named: post.profileImage)
        
        if let imageUrls = post.postImages, !imageUrls.isEmpty {
            let firstImageUrl = imageUrls.first
            if let url = firstImageUrl {
                loadImageFromStorage(url: url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.postImagesView.image = image
                    }
                }
            }
        } else {
            postImagesView.image = nil
        }
    }
    
    @objc private func userProfileButtonTapped() {
        let aboutMeVC = AboutMeViewController(userId: post.userId)
        navigationController?.pushViewController(aboutMeVC, animated: true)
    }
    
    private func navigateToChatDetail(chatRoom: ChatRoom) {
        let chatViewModel = ChatViewModel()
        let chatDetailViewController = ChatViewController(chatRoom: chatRoom)
        chatDetailViewController.chatViewModel = chatViewModel
        navigationController?.pushViewController(chatDetailViewController, animated: true)
    }
}


#Preview {
    return UINavigationController(rootViewController: PostDetailViewController(post: Post.samplePosts.first!))
}
