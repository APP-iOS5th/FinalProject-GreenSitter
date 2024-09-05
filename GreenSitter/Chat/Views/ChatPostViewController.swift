//
//  ChatPostViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit
import Kingfisher

class ChatPostViewController: UIViewController {
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 게시물 이미지
    lazy var postThumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // 스택뷰
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // 제목
    lazy var postTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // 게시물 상태
    lazy var postStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .dominent
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // 삭제된 게시물을 위한 회색 뷰
    lazy var grayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var deletePostLabel: UILabel = {
        let label = UILabel()
        label.text = "삭제된 게시글입니다."
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chatRoom.postEnabled {
            setupUI()
            
            chatViewModel?.delegate = self
            
            // 게시물 디테일로 이동하기 위한 Tap Gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            self.view.addGestureRecognizer(tapGesture)
        } else {
            self.grayView.isHidden = false
            self.deletePostLabel.isHidden = false
            setupUI()
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // 이미지 다운로드 실패 시 기본 이미지로 설정
        let placeholderImage = UIImage(named: "chatIcon")
        
        if let firstImageUrlString = chatRoom.postImage,
           let postThumbnailUrl = URL(string: firstImageUrlString) {
//            chatViewModel?.downloadImage(from: postThumbnailUrl, to: postThumbnailView, placeholderImage: placeholderImage)
            // Kingfisher를 사용하여 이미지 다운로드 및 설정
            postThumbnailView.kf.setImage(with: postThumbnailUrl, placeholder: placeholderImage)
        } else {
            // postImage가 nil일 경우 기본 이미지로 설정
            postThumbnailView.image = placeholderImage
        }
        
        postTitleLabel.text = chatRoom.postTitle
        postStatusLabel.text = chatRoom.postStatus.rawValue
        
        self.view.backgroundColor = .bgPrimary
        
        stackView.addSubview(postTitleLabel)
        stackView.addSubview(postStatusLabel)
        
        self.view.addSubview(postThumbnailView)
        self.view.addSubview(stackView)
        
        grayView.addSubview(deletePostLabel)
        self.view.addSubview(grayView)
        
        NSLayoutConstraint.activate([
            grayView.topAnchor.constraint(equalTo: self.view.topAnchor),
            grayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            grayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            grayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            deletePostLabel.bottomAnchor.constraint(equalTo: grayView.bottomAnchor, constant: -20),
            deletePostLabel.trailingAnchor.constraint(equalTo: grayView.trailingAnchor, constant: -20),
            
            postThumbnailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            postThumbnailView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            postThumbnailView.widthAnchor.constraint(equalToConstant: 80),
            postThumbnailView.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.topAnchor.constraint(equalTo: postThumbnailView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: postThumbnailView.bottomAnchor, constant: -10),
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: postThumbnailView.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            postTitleLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
            postTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            postTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            postStatusLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 5),
            postStatusLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            postStatusLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -5),
            postStatusLabel.widthAnchor.constraint(equalToConstant: 49),
            postStatusLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - UITapGestureRecognizer action
    @objc private func handleTap() {
        // 특정 게시물로 이동
        let postDetailViewController = PostDetailViewController(postId: chatRoom.postId)
        
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }

}

extension ChatPostViewController: ChatViewModelDelegate {
    func updatePostStatusLabelAfterMakePlan() {
        chatRoom.postStatus = .inTrade
        postStatusLabel.text = chatRoom.postStatus.rawValue
    }
    func updatePostStatusLabelAfterCancelPlan() {
        chatRoom.postStatus = .beforeTrade
        postStatusLabel.text = chatRoom.postStatus.rawValue
    }
    func updatePostStatusLabelAfterCompleteTrade() {
        chatRoom.postStatus = .completedTrade
        postStatusLabel.text = chatRoom.postStatus.rawValue
    }
}
