//
//  ChatViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/12/24.
//

import UIKit

class ChatViewController: UIViewController {
    var chatViewModel: ChatViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        if chatViewModel?.userId == chatViewModel?.chatRoom?.userId {
            self.title = chatViewModel?.chatRoom?.userNickname
        } else if chatViewModel?.userId == chatViewModel?.chatRoom?.postUserId {
            self.title = chatViewModel?.chatRoom?.postUserNickname
        }
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(listButtonTapped))
        
        let chatPostViewController = ChatPostViewController()
        let chatMessageViewController = ChatMessageViewController()
        let messageInputViewController = MessageInputViewController()
        
        chatPostViewController.chatViewModel = chatViewModel
        chatMessageViewController.chatViewModel = chatViewModel
        messageInputViewController.chatViewModel = chatViewModel
        
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
            chatMessageViewController.view.bottomAnchor.constraint(equalTo: messageInputViewController.view.topAnchor, constant: -10),
            chatMessageViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatMessageViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatMessageViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            messageInputViewController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            messageInputViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            messageInputViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            messageInputViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])

    }
    
    @objc private func listButtonTapped() {
        print("list button")
    }

}
