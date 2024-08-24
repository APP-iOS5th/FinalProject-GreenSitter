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
    private var imageUrls: [String] = []
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
        label.text = LoginViewModel.shared.user?.levelPoint.rawValue
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
    
    private let imagesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let imagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        addTapGestureToImages()
        
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
        
        contentView.addSubview(imagesScrollView)
        imagesScrollView.addSubview(imagesStackView)
        
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
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            userProfileButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            userProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userProfileButton.trailingAnchor.constraint(equalTo: contactButton.leadingAnchor),
            userProfileButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            userProfileButton.bottomAnchor.constraint(equalTo: postTimeLabel.bottomAnchor),
            
            contactButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            contactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactButton.widthAnchor.constraint(equalToConstant: 100),
            contactButton.heightAnchor.constraint(equalToConstant: 40),
            
            profileImageView.leadingAnchor.constraint(equalTo: userProfileButton.leadingAnchor),
            profileImageView.topAnchor.constraint(equalTo: userProfileButton.topAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: userNameLabel.font.pointSize),
            
            userLevelLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userLevelLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            userLevelLabel.heightAnchor.constraint(equalToConstant: userLevelLabel.font.pointSize),
            
            postTimeLabel.topAnchor.constraint(equalTo: userLevelLabel.bottomAnchor, constant: 4),
            postTimeLabel.leadingAnchor.constraint(equalTo: userLevelLabel.leadingAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: userProfileButton.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.widthAnchor.constraint(equalToConstant: 40),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            postTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postTitleLabel.heightAnchor.constraint(equalToConstant: postTitleLabel.font.pointSize),
            
            dividerLine1.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 10),
            dividerLine1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine1.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            dividerLine1.heightAnchor.constraint(equalToConstant: 1),
            
            
            imagesScrollView.topAnchor.constraint(equalTo: dividerLine1.bottomAnchor, constant: 20),
            imagesScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imagesScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imagesScrollView.heightAnchor.constraint(equalToConstant: 250),
            
            
            imagesStackView.topAnchor.constraint(equalTo: imagesScrollView.topAnchor),
            imagesStackView.bottomAnchor.constraint(equalTo: imagesScrollView.bottomAnchor),
            imagesStackView.leadingAnchor.constraint(equalTo: imagesScrollView.leadingAnchor),
            imagesStackView.trailingAnchor.constraint(equalTo: imagesScrollView.trailingAnchor),
            imagesStackView.heightAnchor.constraint(equalTo: imagesScrollView.heightAnchor),
            
            dividerLine2.topAnchor.constraint(equalTo: imagesStackView.bottomAnchor, constant: 20),
            dividerLine2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine2.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            dividerLine2.heightAnchor.constraint(equalToConstant: 1),
            
            postBodyTextView.topAnchor.constraint(equalTo: dividerLine2.bottomAnchor, constant: 10),
            postBodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postBodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postBodyTextView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            postBodyTextView.heightAnchor.constraint(greaterThanOrEqualTo: self.view.heightAnchor, multiplier: 0.2),
            
            dividerLine3.topAnchor.constraint(equalTo: postBodyTextView.bottomAnchor, constant: 10),
            dividerLine3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine3.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 8),
            mapLabel.heightAnchor.constraint(equalToConstant: mapLabel.font.pointSize),
            
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 8),
            mapView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            mapView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 150),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16), 
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
        userLevelLabel.text = LoginViewModel.shared.user?.levelPoint.rawValue
        
        profileImageView.image = UIImage(named: post.profileImage)
        
        imagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        imageUrls.removeAll()
        
        if let imageUrls = post.postImages, !imageUrls.isEmpty {
            self.imageUrls = imageUrls
            for (index, imageUrl) in imageUrls.enumerated() {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalToConstant: 190).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
                imageView.tag = index  // 여기에 태그를 추가합니다
                
                loadImageFromStorage(url: imageUrl) { image in
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
                imagesStackView.addArrangedSubview(imageView)
            }
        }
        
        addTapGestureToImages()
    }
    
    @objc private func userProfileButtonTapped() {
        let aboutMeVC = AboutMeViewController(userId: post.userId)
        navigationController?.pushViewController(aboutMeVC, animated: true)
    }
    
    private func navigateToChatDetail(chatRoom: ChatRoom) {
        let chatViewModel = ChatViewModel()
        let chatDetailViewController = ChatViewController(chatRoom: chatRoom)
        chatDetailViewController.chatViewModel = chatViewModel
        self.navigationController?.pushViewController(chatDetailViewController, animated: true)
    }
    
    private func addTapGestureToImages() {
        for case let imageView as UIImageView in imagesStackView.arrangedSubviews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func imageTapped(_ gesture: UITapGestureRecognizer) {
        guard !imageUrls.isEmpty,
              let tappedImageView = gesture.view as? UIImageView,
              let index = imagesStackView.arrangedSubviews.firstIndex(of: tappedImageView) else { return }
        
        let fullScreenPageVC = FullScreenPageViewController(imageUrls: imageUrls, initialIndex: index)
        fullScreenPageVC.modalPresentationStyle = .fullScreen
        present(fullScreenPageVC, animated: true, completion: nil)
    }
}
//
//#Preview {
//    return UINavigationController(rootViewController: PostDetailViewController(post: Post.samplePosts.first!))
//}
