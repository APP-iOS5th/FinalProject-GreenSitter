//
//  PostDetailViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/10/24.
//

import UIKit
import MapKit
import FirebaseAuth

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
        let scrollView =  UIScrollView()
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
        button.backgroundColor = .clear // 투명하게 만들어 배경이 보이지 않게
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
        label.text = LoginViewModel.shared.user?.levelPoint.rawValue
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
    
    private let dividerLine1: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let dividerLine2: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let dividerLine3: UIImageView = {
        let line = UIImageView()
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
        let image = UIImageView()
        image.backgroundColor = .lightGray
        image.tintColor = .gray
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let postBodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // TODO: 채팅방 연결
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
        
        if Auth.auth().currentUser != nil {
            // 해당 post 가 자신이 올린 Post 라면, 삭제/편집 기능 있는 네비게이션 바로 표시
            if LoginViewModel.shared.user?.docId == post.userId {
                setupNavigationBarWithEdit()
            } else {
                // 그게 아니면 차단 기능있는 네비게이션 바 표시
                setupNavigationBarWithBlock()
            }
        }
        
        setupUI()
        configure(with: post)
        
        contactButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.postDetailViewModel.chatButtonTapped()
            }
        }, for: .touchUpInside)
        
        // ChatDetailView로 이동
        postDetailViewModel.onChatButtonTapped = { [weak self] chatRoom in
            self?.navigateToChatDetail(chatRoom: chatRoom)
        }
    }
    
    private func setupNavigationBarWithEdit() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { [weak self] _ in
                guard let self = self else {
                    return
                }
                let editPostViewController = EditPostViewController(post: post)
                editPostViewController.modalPresentationStyle = .fullScreen
                self.present(editPostViewController, animated: true)
            },
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash")) { [weak self] _ in
                guard let self = self else { return }
                self.postDetailViewModel.deletePost(postId: self.post.id) { [weak self] success in
                    DispatchQueue.main.async {
                        if success {
                            let alert = UIAlertController(title: "성공", message: "삭제가 완료되었습니다.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                                self?.navigationController?.popViewController(animated: true)
                            })
                            self?.present(alert, animated: true)
                        } else {
                            let alert = UIAlertController(title: "실패", message: "삭제에 실패했습니다. 다시 시도해 주세요.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default))
                            self?.present(alert, animated: true)
                        }
                    }
                }
            }
        ])

        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        menuButton.tintColor = .labelsPrimary
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = menuBarButtonItem
    }
    
    private func setupNavigationBarWithBlock() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "신고하기", image: UIImage(systemName: "light.beacon.max.fill")) { _ in
                
            },
            UIAction(title: "차단하기", image: UIImage(systemName: "person.slash.fill")) { _ in
                
            }
        ])
        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        menuButton.tintColor = .labelsPrimary
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = menuBarButtonItem
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
        contentView.addSubview(postBodyLabel)
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
            
            dividerLine3.topAnchor.constraint(equalTo: postBodyLabel.bottomAnchor, constant: 10), // -5에서 10으로 조정
            dividerLine3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine3.widthAnchor.constraint(equalToConstant: 360),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            postImagesView.widthAnchor.constraint(equalToConstant: 190),
            postImagesView.heightAnchor.constraint(equalToConstant: 250),
            postImagesView.topAnchor.constraint(equalTo: dividerLine1.bottomAnchor, constant: 20),
            postImagesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            postBodyLabel.topAnchor.constraint(equalTo: dividerLine2.bottomAnchor, constant: 10),
            postBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postBodyLabel.widthAnchor.constraint(equalToConstant: 200),
            postBodyLabel.heightAnchor.constraint(equalToConstant: 200),
            
            contactButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            contactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactButton.widthAnchor.constraint(equalToConstant: 100),
            contactButton.heightAnchor.constraint(equalToConstant: 40),
            
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 8), // 10에서 8로 조정
            
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 8), // 5에서 8로 조정
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16) // -10에서 -16으로 조정
        ])
        
    }
    
    private func configure(with post: Post) {
        userNameLabel.text = post.nickname
        postTitleLabel.text = post.postTitle
        postBodyLabel.text = post.postBody
        statusLabel.text = post.postStatus.rawValue
        
        profileImageView.image = UIImage(named: post.profileImage)
        
        // 이미지뷰를 horizontal scrollview 로 바꾸고, 여러 개의 이미지 표시하기
        if let imageUrlString = post.postImages?.first, let imageUrl = URL(string: imageUrlString) {
            print("Post Image is: \(imageUrlString)")
            loadImage(from: imageUrl)
        } else {
            print("Post Image is nil")
            postImagesView.image = nil
        }
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.postImagesView.image = nil
                }
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.postImagesView.image = image
            }
        }
        task.resume()
    }

    
    @objc private func userProfileButtonTapped() {
        let aboutMeVC = AboutMeViewController(userId: post.userId)
        navigationController?.pushViewController(aboutMeVC, animated: true)
    }
    
    // 채팅창으로 이동
    private func navigateToChatDetail(chatRoom: ChatRoom) {
        let chatViewModel = ChatViewModel()
        let chatDetailViewController = ChatViewController(chatRoom: chatRoom)
        chatDetailViewController.chatViewModel = chatViewModel
        self.navigationController?.pushViewController(chatDetailViewController, animated: true)
    }
}


#Preview {
    return UINavigationController(rootViewController: PostDetailViewController(post: Post.samplePosts.first!))
}
