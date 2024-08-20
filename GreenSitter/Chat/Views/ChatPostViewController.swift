//
//  ChatPostViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit

class ChatPostViewController: UIViewController {
    var chatViewModel: ChatViewModel?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // 게시물 디테일로 이동하기 위한 Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        if let firstImageUrlString = chatViewModel?.chatRoom?.postImage,
           let postThumbnailUrl = URL(string: firstImageUrlString) {
            chatViewModel?.downloadImage(from: postThumbnailUrl, to: postThumbnailView)
        }
        
        postTitleLabel.text = chatViewModel?.chatRoom?.postTitle
        postStatusLabel.text = chatViewModel?.chatRoom?.postStatus.rawValue
        
        self.view.backgroundColor = .white
        
        stackView.addSubview(postTitleLabel)
        stackView.addSubview(postStatusLabel)
        
        self.view.addSubview(postThumbnailView)
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            postThumbnailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
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
        let postDetailViewController = PostDetailViewController()
        
        // TODO: - 특정 게시물로 이동
//        postDetailViewController.postId = postId
        
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }

}
