//
//  ChatViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/12/24.
//

import UIKit

class ChatViewController: UIViewController {
    private var chatViewModel = ChatViewModel()
    var chatRoom: ChatRoom?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
            
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(listButtonTapped))
        
        let chatPostViewController = ChatPostViewController()
        let chatMessageViewController = ChatMessageViewController()
        let messageInputViewController = MessageInputViewController()
        
        if let firstImageUrlString = chatRoom?.postImage,
           let postThumbnailUrl = URL(string: firstImageUrlString) {
            chatViewModel.downloadImage(from: postThumbnailUrl, to: chatPostViewController.postThumbnailView)
        }

        chatPostViewController.postTitleLabel.text = chatRoom?.postTitle
        chatPostViewController.postStatusLabel.text = chatRoom?.postStatus.rawValue
        
        chatPostViewController.view.translatesAutoresizingMaskIntoConstraints = false
        chatMessageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        messageInputViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(chatPostViewController.view)
        self.view.addSubview(chatMessageViewController.view)
        self.view.addSubview(messageInputViewController.view)
        
        addChild(chatPostViewController)
        chatPostViewController.didMove(toParent: self)
        addChild(chatMessageViewController)
        chatMessageViewController.didMove(toParent: self)
        addChild(messageInputViewController)
        messageInputViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            chatPostViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            chatPostViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            chatPostViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            chatPostViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            chatPostViewController.view.heightAnchor.constraint(equalToConstant: 100),
            
            chatMessageViewController.view.topAnchor.constraint(equalTo: chatPostViewController.view.bottomAnchor),
            chatMessageViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatMessageViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatMessageViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            messageInputViewController.view.topAnchor.constraint(equalTo: chatMessageViewController.view.bottomAnchor, constant: 10),
            messageInputViewController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            messageInputViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            messageInputViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            messageInputViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])

    }
    
    @objc private func listButtonTapped() {
        print("list button")
    }

}
