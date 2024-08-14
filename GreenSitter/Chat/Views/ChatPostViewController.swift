//
//  ChatPostViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit

class ChatPostViewController: UIViewController {
    var chatListViewModel: ChatListViewModel?
    
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
    }
    
    // MARK: - Setup UI
    private func setupUI() {
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
            stackView.bottomAnchor.constraint(equalTo: postThumbnailView.topAnchor, constant: -10),
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: postThumbnailView.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 70),
            
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

}
