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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ChatManager.shared.currentChatRoomId = chatRoom.id
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ChatManager.shared.currentChatRoomId = nil
    }
    // MARK: - Setup UI
    private func setupUI() {
        
        if chatViewModel?.user?.id == chatRoom.userId {
            self.title = chatRoom.postUserNickname
        } else if chatViewModel?.user?.id == chatRoom.postUserId {
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
    private func notificationToggleAction() -> UIAction {
        let notificationStatus = chatViewModel?.user?.id == chatRoom.userId ? chatRoom.userNotification : chatRoom.postUserNotification
        return UIAction(
            title: notificationStatus ? "알림 끄기" : "알림 켜기",
            image: notificationStatus ? UIImage(systemName: "bell.slash.fill") : UIImage(systemName: "bell.fill")) { [weak self] _ in
            guard let self = self else { return }
            let newNotificationStatus = !notificationStatus
            Task {
                do {
                    if self.chatViewModel?.user?.id == self.chatRoom.userId {
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
                    if self.chatViewModel?.user?.id == self.chatRoom.userId {
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
        let notificationToggleAction = notificationToggleAction()
        
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
        
        let completeTradeAction = UIAction(
            title: "거래 완료하기",
            image: UIImage(systemName: "checkmark.circle")
        ) { [weak self] _ in
            guard let self = self else { return }
            Task {
                let postStatus = await self.chatViewModel?.fetchChatPostStatus(chatRoomId: self.chatRoom.id)
                let hasLeavePlan = await self.chatViewModel?.fetchChatHasLeavePlan(chatRoomId: self.chatRoom.id) ?? false
                let hasGetBackPlan = await self.chatViewModel?.fetchChatHasGetBackPlan(chatRoomId: self.chatRoom.id) ?? false
                let authorityToCommit = await self.chatViewModel?.checkAuthorityToCommit(postId: self.chatRoom.postId) ?? false
                if postStatus == .completedTrade {
                    self.dismiss(animated: true) {
                        let alert = UIAlertController(title: "거래 완료", message: "이미 거래가 완료된 게시물입니다.", preferredStyle: .alert)
                        
                        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                        }
                        alert.addAction(confirmAction)
                
                        self.present(alert, animated: true, completion: nil)
                    }
                } else if !(hasLeavePlan && hasGetBackPlan) {
                    // 거래 완료 상태가 아니고
                    // 약속이 없다면
                    self.dismiss(animated: true) {
                        let alert = UIAlertController(title: "거래 완료 불가", message: "아직 위탁 혹은 회수 약속이 없습니다. 먼저 약속을 만들어주세요.", preferredStyle: .alert)
                        
                        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                        }
                        alert.addAction(confirmAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                } else if !authorityToCommit {
                    // 거래 완료 상태가 아니고
                    // 약속이 있고
                    // 거래 완료 권한이 없다면
                    self.dismiss(animated: true) {
                        let alert = UIAlertController(title: "거래 완료 불가", message: "다른 사용자와 약속이 있습니다. 거래 완료 권한이 없습니다.", preferredStyle: .alert)
                        
                        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                        }
                        alert.addAction(confirmAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    // 거래 완료 상태가 아니고
                    // 약속이 있고
                    // 거래 완료 권한이 있다면
                    await self.chatViewModel?.completeTrade(chatRoomId: self.chatRoom.id, postId: self.chatRoom.postId, recipientId: self.chatRoom.userId)
                        self.chatViewModel?.sendReviewMessage(chatRoom: self.chatRoom)
                    self.chatRoom.postStatus = .completedTrade
                }
            }
        }
        
        let menuItems = [notificationToggleAction, completeTradeAction, leaveChatRoomAction]
        let menu = UIMenu(children: menuItems)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), menu: menu)
    }
    
    // 키보드 숨기기 메서드
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
