//
//  PostDetailViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/10/24.
//

import UIKit
import MapKit
import FirebaseAuth
import Kingfisher

class PostDetailViewController: UIViewController {
    private var postDetailViewModel = PostDetailViewModel()
    private var imageUrls: [String] = []
    private let postId: String
    private var overlayPostMapping: [MKCircle: Post] = [:]
    private var postBodyTextViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializer
    
    init(postId: String) {
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
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
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userLevelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .labelsSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .labelsSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dividerLine3: UIView = {
        let line = UIView()
        line.backgroundColor = .separatorsNonOpaque
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
        label.font = .systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .labelsPrimary
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
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = .labelsPrimary
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
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
        label.textColor = .labelsSecondary
        label.font = .systemFont(ofSize: 15)
        label.text = "거래 희망 장소"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mapPlaceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .labelsPrimary
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .labelsSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "이 위치는 500m 반경 이내의 지역이 표시됩니다."
        return label
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPrimary
        mapView.delegate = self
        postBodyTextView.delegate = self
        postDetailViewModel.delegate = self

        // postId 를 가지고 파이어베이스에서 해당 post 불러오기
        loadPost(with: postId)
    }
    
    // MARK: - Helpful Functions
    
    private func loadPost(with postId: String) {
        postDetailViewModel.fetchPostById(postId: postId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let post):
                DispatchQueue.main.async {
                    self.configureUI(with: post)
                    self.configureMapView(with: post)
                }
            case .failure(let error):
                print("Failed to fetch post with id: \(postId), error: \(error.localizedDescription)")
            }
        }
    }


    private func configureUI(with post: Post) {
        setupUI()
        
        if let imageUrls = post.postImages, !imageUrls.isEmpty {
            setupConstraintsWithImages()
        } else {
            setupConstraints()
        }

        configure(with: post)
        
        if Auth.auth().currentUser != nil {
            if LoginViewModel.shared.user?.id == post.userId {
                setupNavigationBarWithEdit(post: post)
                contactButton.isHidden = true
                // TODO: 채팅도 표시하지 않아야함
            } else {
                contactButton.isHidden = false
                // 그게 아니면 차단 기능있는 네비게이션 바 표시
                setupNavigationBarWithBlock(post: post)
                
                // 로그인을 한 유저 중, 다른 사람의 게시물을 보고 있는 경우에만 chat button 보이게
                configureChatButton(with: post)
            }
        }
        
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
    
    private func setupNavigationBarWithEdit(post: Post) {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { [weak self] _ in
                guard let self = self else {
                    return
                }
                let editPostViewController = EditPostViewController(post: post, viewModel: EditPostViewModel(selectedPost: post))
                let navigationController = UINavigationController(rootViewController: editPostViewController)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true)
            },
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash")) { [weak self] _ in
                guard let self = self else { return }
                self.postDetailViewModel.deletePost(postId: post.id) { [weak self] success in
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
    
    private func setupNavigationBarWithBlock(post: Post) {
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
    
    // MARK: - 채팅 버튼
    
    private func configureChatButton(with post: Post) {
        // post.id 로 접근하시면 됩니다
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
    
    // MARK: - CONFIGURE (WITH POST)
    private func configure(with post: Post) {
        userNameLabel.text = post.nickname
        postTitleLabel.text = post.postTitle
        postTimeLabel.text = timeAgoSinceDate(post.updateDate)
        configurePostBodyTextView(with: post.postBody)

        statusLabel.text = post.postStatus.rawValue
        userLevelLabel.text = post.userLevel.rawValue
        
        let address = post.location?.address
        let placeName = post.location?.placeName
        
        if let address = address, !address.isEmpty, let placeName = placeName, !placeName.isEmpty {
            mapPlaceLabel.text = "\(address) (\(placeName))" // 주소와 장소 이름을 함께 표시
        } else if let address = address, !address.isEmpty {
            mapPlaceLabel.text = address // 주소만 표시
        } else if let placeName = placeName, !placeName.isEmpty {
            mapPlaceLabel.text = placeName // 장소 이름만 표시
        } else {
            mapPlaceLabel.text = "주소 정보 없음" // 둘 다 없는 경우
        }
        
        profileImageView.image = UIImage(named: post.profileImage)
        
        imagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        imageUrls.removeAll()
        
        // profile button
        userProfileButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let aboutMeVC = AboutMeViewController(userId: post.userId)
            self.navigationController?.pushViewController(aboutMeVC, animated: true)
        }, for: .touchUpInside)
        
        
        // image
        if let imageUrls = post.postImages, !imageUrls.isEmpty {
            self.imageUrls = imageUrls //이게원인
            for (index, imageUrl) in imageUrls.enumerated() {
                print("ImageURL: \(index), \(imageUrl)")
                
                // Create a new UIImageView for each image
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFill
                imageView.layer.masksToBounds = true
                imageView.layer.cornerRadius = 4
                imageView.tag = index
                
                let processor = DownsamplingImageProcessor(size: CGSize(width: 190, height: 200))
                               |> RoundCornerImageProcessor(cornerRadius: 4)
                imageView.kf.setImage(
                    with: URL(string: imageUrl),
                    placeholder: UIImage(named: "PlaceholderAvatar"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(0.25)),
                        .cacheOriginalImage
                    ],
                    completionHandler: { result in
                        switch result {
                        case .success(let value):
                            print("Image successfully loaded.")
                            self.addTapGestureToImages()
                        case .failure(let error):
                            print("Failed to load image: \(error.localizedDescription)")
                        }
                    }
                )
                self.imagesStackView.addArrangedSubview(imageView)
                print("IMAGESTACKVIEWSUBVIEWS: \(self.imagesStackView.arrangedSubviews)")
            }  // for
            
        } else {
            self.imagesScrollView.isHidden = true
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
        contentView.addSubview(dividerLine3)
        contentView.addSubview(contactButton)
        contentView.addSubview(mapLabel)
        contentView.addSubview(mapPlaceLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(descriptionLabel)
    }

    private func setupConstraintsWithImages() {
        imagesScrollView.isHidden = false
        
        // 기본값은 안보이게
        contactButton.isHidden = false /// true로 수정
        
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
            
            userProfileButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            userProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userProfileButton.trailingAnchor.constraint(equalTo: contactButton.leadingAnchor),
            userProfileButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            
            contactButton.centerYAnchor.constraint(equalTo: userProfileButton.centerYAnchor),
            contactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactButton.widthAnchor.constraint(equalToConstant: 100),
            contactButton.heightAnchor.constraint(equalToConstant: 40),
            
            profileImageView.leadingAnchor.constraint(equalTo: userProfileButton.leadingAnchor),
            profileImageView.topAnchor.constraint(equalTo: userProfileButton.topAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            userNameLabel.heightAnchor.constraint(equalToConstant: userNameLabel.font.pointSize),
            
            userLevelLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            userLevelLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5),
            userLevelLabel.heightAnchor.constraint(equalToConstant: userLevelLabel.font.pointSize),
            
            postTimeLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            postTimeLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 10),
            
            statusLabel.topAnchor.constraint(equalTo: userProfileButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.widthAnchor.constraint(equalToConstant: 50),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            postTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postTitleLabel.heightAnchor.constraint(equalToConstant: postTitleLabel.font.pointSize),
            

            imagesScrollView.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 20),
            imagesScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imagesScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imagesScrollView.heightAnchor.constraint(equalToConstant: 200),
            
            imagesStackView.topAnchor.constraint(equalTo: imagesScrollView.topAnchor),
            imagesStackView.bottomAnchor.constraint(equalTo: imagesScrollView.bottomAnchor),
            imagesStackView.leadingAnchor.constraint(equalTo: imagesScrollView.leadingAnchor),
            imagesStackView.trailingAnchor.constraint(equalTo: imagesScrollView.trailingAnchor),
            imagesStackView.heightAnchor.constraint(equalTo: imagesScrollView.heightAnchor),
            
            postBodyTextView.topAnchor.constraint(equalTo: imagesStackView.bottomAnchor, constant: 20),
            postBodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postBodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postBodyTextView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            
            dividerLine3.topAnchor.constraint(equalTo: postBodyTextView.bottomAnchor, constant: 10),
            dividerLine3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine3.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 8),
            mapLabel.heightAnchor.constraint(equalToConstant: mapLabel.font.pointSize),
            
            mapPlaceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapPlaceLabel.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 8),
            mapPlaceLabel.heightAnchor.constraint(equalToConstant: mapPlaceLabel.font.pointSize),
            
            mapView.topAnchor.constraint(equalTo: mapPlaceLabel.bottomAnchor, constant: 12),
            mapView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            mapView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupConstraints() {
        imagesScrollView.isHidden = false
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
            
            userProfileButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            userProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userProfileButton.trailingAnchor.constraint(equalTo: contactButton.leadingAnchor),
            userProfileButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            
            contactButton.centerYAnchor.constraint(equalTo: userProfileButton.centerYAnchor),
            contactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactButton.widthAnchor.constraint(equalToConstant: 100),
            contactButton.heightAnchor.constraint(equalToConstant: 40),
            
            profileImageView.leadingAnchor.constraint(equalTo: userProfileButton.leadingAnchor),
            profileImageView.topAnchor.constraint(equalTo: userProfileButton.topAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            userNameLabel.heightAnchor.constraint(equalToConstant: userNameLabel.font.pointSize),
            
            userLevelLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            userLevelLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5),
            userLevelLabel.heightAnchor.constraint(equalToConstant: userLevelLabel.font.pointSize),
            
            postTimeLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            postTimeLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 10),
            
            statusLabel.topAnchor.constraint(equalTo: userProfileButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusLabel.widthAnchor.constraint(equalToConstant: 50),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            postTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postTitleLabel.heightAnchor.constraint(equalToConstant: postTitleLabel.font.pointSize),

            postBodyTextView.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 20),
            postBodyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postBodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postBodyTextView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            
            dividerLine3.topAnchor.constraint(equalTo: postBodyTextView.bottomAnchor, constant: 10),
            dividerLine3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerLine3.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 8),
            mapLabel.heightAnchor.constraint(equalToConstant: mapLabel.font.pointSize),
            
            mapPlaceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapPlaceLabel.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 8),
            mapPlaceLabel.heightAnchor.constraint(equalToConstant: mapPlaceLabel.font.pointSize),
            
            mapView.topAnchor.constraint(equalTo: mapPlaceLabel.bottomAnchor, constant: 12),
            mapView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            mapView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func timeAgoSinceDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)개월 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
    
    private func navigateToChatDetail(chatRoom: ChatRoom) {
        let chatViewModel = ChatViewModel()
        let chatDetailViewController = ChatViewController(chatRoom: chatRoom)
        chatDetailViewController.chatViewModel = chatViewModel
        
        // 현재 탭 바 컨트롤러 가져오기
        if let tabBarController = self.tabBarController,
           let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {

            navigationController.pushViewController(chatDetailViewController, animated: true)

            // 채팅 탭으로 전환
            tabBarController.selectedIndex = 2
        }
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

extension PostDetailViewController: UITextViewDelegate {
    // 텍스트뷰 높이를 자동으로 조정하는 메서드
    private func adjustTextViewHeight() {
        let size = postBodyTextView.sizeThatFits(CGSize(width: postBodyTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        // 텍스트뷰의 최소 높이를 200으로 설정
        let newHeight = max(size.height, 200)
        
        if postBodyTextViewHeightConstraint == nil {
            postBodyTextViewHeightConstraint = postBodyTextView.heightAnchor.constraint(equalToConstant: newHeight)
            postBodyTextViewHeightConstraint?.isActive = true
        } else {
            postBodyTextViewHeightConstraint?.constant = newHeight
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    // 텍스트가 변경될 때 호출되는 델리게이트 메서드
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }
    
    private func configurePostBodyTextView(with text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.labelsPrimary
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        postBodyTextView.attributedText = attributedString
    }
}

extension PostDetailViewController: MKMapViewDelegate {
    
    private func configureMapView(with post: Post) {
        print("Post Detail Map with Post: \(post)")
//        mapView.removeAnnotations(mapView.annotations)
//        mapView.removeOverlays(mapView.overlays)
//        overlayPostMapping.removeAll()
        guard let latitude = post.location?.latitude,
              let longitude = post.location?.longitude else { return }
        
        let circleCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // make random Center
        let randomOffset = generateRandomOffset(for: circleCenter, radius: 500)
        let randomCenter = CLLocationCoordinate2D (
            latitude: circleCenter.latitude + randomOffset.latitudeDelta,
            longitude: circleCenter.longitude + randomOffset.longitudeDelta
        )
        
        let circle = MKCircle(center: randomCenter, radius: 500)
        
        // setRegion
        DispatchQueue.main.async {
            let region = MKCoordinateRegion(center: randomCenter, latitudinalMeters: 1500, longitudinalMeters: 1500)
            self.mapView.setRegion(region, animated: false)
        }
        
        // 맵 뷰에 오버레이 추가하기 전에, post 값을 circle 키에 넣기
        overlayPostMapping[circle] = post
        mapView.addOverlay(circle)  // MKOverlayRenderer 메소드 호출
        
        let annotation = CustomAnnotation(postType: post.postType, coordinate: randomCenter)
        mapView.addAnnotation(annotation)  // MKAnnotationView

    }

    // 실제 위치(center) 기준으로 반경 내의 무작위 좌표를 새로운 중심점으로 설정
    func generateRandomOffset(for center: CLLocationCoordinate2D, radius: Double) -> (latitudeDelta: Double, longitudeDelta: Double) {
        let earthRadius: Double = 6378137 // meters
        let dLat = (radius / earthRadius) * (180 / .pi)
        let dLong = dLat / cos(center.latitude * .pi / 180)
        
        let randomLatDelta = Double.random(in: -dLat...dLat)
        let randomLongDelta = Double.random(in: -dLong...dLong)
        
        return (latitudeDelta: randomLatDelta, longitudeDelta: randomLongDelta)
    }
    
    // MKAnnotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }
           
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation
        }
        
        // postType 따라서 어노테이션에 이미지 다르게 적용
        let sesacImage: UIImage!
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        
        switch annotation.postType {
        case .lookingForSitter:
            sesacImage = UIImage(named: "lookingForSitterIcon")
        case .offeringToSitter:
            sesacImage = UIImage(named: "offeringToSitterIcon")
        default:
            sesacImage = UIImage(systemName: "mappin.circle.fill")
        }
        
        sesacImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage
        
        return annotationView
    }
    
    
    // MKOverlayRenderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
//            print("rendererFor methods: dict: \(overlayPostMapping)")
            
            // 딕셔너리로부터 해당 circleOverlay에 저장된 Post 가져오기
            if let post = overlayPostMapping[circleOverlay] {
                // 오버레이 색 적용
                switch post.postType {
                case .lookingForSitter:
                    circleRenderer.fillColor = UIColor.complementary.withAlphaComponent(0.5)
                case .offeringToSitter:
                    circleRenderer.fillColor = UIColor.dominent.withAlphaComponent(0.5)
                }
            } else {
                print("post is nil")
                circleRenderer.fillColor = UIColor.gray.withAlphaComponent(0.5) // Default color
            }

            circleRenderer.strokeColor = .separatorsNonOpaque
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
}

extension PostDetailViewController: PostDetailViewModelDelegate {
    func navigateToLoginViewController() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true)
    }
}
