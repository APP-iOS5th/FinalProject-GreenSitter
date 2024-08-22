//
//  ChatViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/12/24.
//

import UIKit

class ChatViewController: UIViewController {
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        if chatViewModel?.userId == chatRoom.userId {
            self.title = chatRoom.postUserNickname
        } else if chatViewModel?.userId == chatRoom.postUserId {
            self.title = chatRoom.userNickname
        }
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        // 햄버거 버튼
        if chatViewModel?.userId == chatRoom.userId {
            let notification = chatRoom.userNotification
            let menuItems = [
                UIAction(title: notification ? "알림 끄기" : "알림 켜기",
                         image: notification ? UIImage(systemName: "bell.slash.fill") : UIImage(systemName: "bell.fill"), handler: { _ in
                    print("알림")
                }),
                UIAction(title: "채팅방 나가기", image: UIImage(systemName: "door.left.hand.open"), attributes: .destructive, handler: { _ in
                    print("나가기")
                })
            ]
            let menu = UIMenu(title: "", children:  menuItems)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), menu: menu)
        } else {
            let notification = chatRoom.postUserNotification
            let menuItems = [
                UIAction(title: notification ? "알림 끄기" : "알림 켜기",
                         image: notification ? UIImage(systemName: "bell.slash.fill") : UIImage(systemName: "bell.fill"), handler: { _ in
                    print("알림")
                }),
                UIAction(title: "채팅방 나가기", image: UIImage(systemName: "door.left.hand.open"), attributes: .destructive, handler: { _ in
                    print("나가기")
                })
            ]
            let menu = UIMenu(title: "", children:  menuItems)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), menu: menu)
        }

        let chatPostViewController = ChatPostViewController(chatRoom: chatRoom)
        let chatMessageViewController = ChatMessageViewController(chatRoom: chatRoom)
        let messageInputViewController = MessageInputViewController(chatRoom: chatRoom)
        
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
            
            messageInputViewController.view.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor, constant: -10),
            messageInputViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            messageInputViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            messageInputViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])

    }
    
    @objc private func listButtonTapped() {
        print("list button")
    }

}
