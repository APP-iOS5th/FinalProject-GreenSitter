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
    var index: Int?
    
    private var currentNotification: Bool {
        chatViewModel?.userId == chatRoom.userId ? chatRoom.userNotification : chatRoom.postUserNotification
    }
    
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
        
        // 키보드 숨기기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        
        if chatViewModel?.userId == chatRoom.userId {
            self.title = chatRoom.postUserNickname
        } else if chatViewModel?.userId == chatRoom.postUserId {
            self.title = chatRoom.userNickname
        }
        
        self.view.backgroundColor = .bgSecondary
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        self.updateMenu()
        
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
            chatPostViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatPostViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatPostViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            chatPostViewController.view.heightAnchor.constraint(equalToConstant: 100),
            
            chatMessageViewController.view.topAnchor.constraint(equalTo: chatPostViewController.view.bottomAnchor),
            chatMessageViewController.view.bottomAnchor.constraint(equalTo: messageInputViewController.view.topAnchor),
            chatMessageViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatMessageViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatMessageViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            messageInputViewController.view.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor),
            messageInputViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            messageInputViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            messageInputViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    // MARK: - UIMenu Action Methods
    private func createNotificationToggleAction() -> UIAction {
        let notificationStatus = currentNotification
        return UIAction(
            title: notificationStatus ? "알림 끄기" : "알림 켜기",
            image: notificationStatus ? UIImage(systemName: "bell.slash.fill") : UIImage(systemName: "bell.fill")) { [weak self] _ in
            guard let self = self else { return }
            let newNotificationStatus = !notificationStatus
            Task {
                do {
                    if self.chatViewModel?.userId == self.chatRoom.userId {
                        try await self.chatViewModel?.updateNotification(
                            chatRoomId: self.chatRoom.id,
                            userNotification: newNotificationStatus,
                            postUserNotification: self.chatRoom.postUserNotification
                        )
                    } else {
                        try await self.chatViewModel?.updateNotification(
                            chatRoomId: self.chatRoom.id,
                            userNotification: self.chatRoom.userNotification,
                            postUserNotification: newNotificationStatus
                        )
                    }
                    
                    // 상태 업데이트
                    if self.chatViewModel?.userId == self.chatRoom.userId {
                        self.chatRoom.userNotification = newNotificationStatus
                    } else {
                        self.chatRoom.postUserNotification = newNotificationStatus
                    }
                    
                    // UI 업데이트
                    self.updateMenu()
                    
                } catch {
                    print("Failed to update notification: \(error)")
                }
            }
        }
    }

    // 메뉴를 업데이트하는 메서드
    private func updateMenu() {
        let notificationToggleAction = createNotificationToggleAction()
        
        let leaveChatRoomAction = UIAction(
            title: "채팅방 나가기",
            image: UIImage(systemName: "door.left.hand.open"),
            attributes: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            Task {
                if let index = self.index {
                    do {
                        try await self.chatViewModel?.deleteChatRoom(at: index)
                        self.navigationController?.popViewController(animated: true)
                    } catch {
                        print("Failed to delete chat room: \(error)")
                    }
                }
            }
        }
        
        let menuItems = [notificationToggleAction, leaveChatRoomAction]
        let menu = UIMenu(children: menuItems)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), menu: menu)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
