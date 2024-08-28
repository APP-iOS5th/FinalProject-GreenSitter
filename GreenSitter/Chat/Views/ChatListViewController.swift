//
//  ChatListViewController.swift
//  GreenSitter
//
//  Created by Jihye Park on 8/7/24.
//

import UIKit

class ChatListViewController: UIViewController {
    private var chatViewModel = ChatViewModel()
    private var chatRoom: ChatRoom?
    private var lastMessageListeners: [Task<Void, Never>] = []
    private var unreadMessageListeners: [Task<Void, Never>] = []
    
    // container
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // 아이콘
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ChatIcon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // 홈 이동 버튼
    private lazy var goToHomeButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        // 버튼 타이틀
        var attributedTitle = AttributedString("새싹 돌봄이/보호자\n찾아보기")
        attributedTitle.font = UIFont.preferredFont(forTextStyle: .title3)
        configuration.attributedTitle = attributedTitle
        // 버튼 색상
        configuration.baseBackgroundColor = .dominent
        configuration.baseForegroundColor = .white
        // padding
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let button = UIButton(configuration: configuration)
        // 버튼 타이틀 여러 줄 표시
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // 기본 텍스트
    private lazy var guideLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 참여 중인 채팅이 없습니다."
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // 테이블 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .bgSecondary
        
        // 로그인 이벤트 수신
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: NSNotification.Name("UserDidLoginNotification"), object: nil)
    }
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if chatViewModel.isLoggedIn {
            Task {
                guard let updatedChatRooms = try? await chatViewModel.loadChatRooms() else {
                    return
                }
                
                for chatRoom in updatedChatRooms {
                    // 채팅방의 마지막 메시지 실시간 업데이트 리스너 설정
                    let lastMessageListener = Task {
                        for await messages in await chatViewModel.loadLastMessages(chatRoomId: chatRoom.id) {
                            self.chatViewModel.lastMessages[chatRoom.id] = messages
                        }
                    }
                    lastMessageListeners.append(lastMessageListener)
                    
                    // 읽지 않은 메시지 리스너 설정
                    let unreadMessageListener = Task {
                        for await messages in await chatViewModel.loadUnreadMessages(chatRoomId: chatRoom.id) {
                            self.chatViewModel.unreadMessages[chatRoom.id] = messages
                        }
                    }
                    unreadMessageListeners.append(unreadMessageListener)
                }
                
                // UI 업데이트
                await MainActor.run {
                    // MARK: - 로그인/채팅방 있음
                    if self.chatViewModel.hasChats {
                        self.chatViewModel.updateUI = { [weak self] in
                            self?.setupChatListUI()
                            self?.tableView.reloadData()
                        }
                    } else {
                        // MARK: - 로그인/채팅방 없음
                        self.chatViewModel.updateUI = { [weak self] in
                            self?.setupEmptyChatListUI()
                            
                            // 버튼 클릭 시 홈 화면으로 이동
                            self?.goToHomeButton.addAction(UIAction { [weak self] _ in
                                self?.navigateToHome()
                            }, for: .touchUpInside)
                        }
                    }
                    
                    chatViewModel.updateUI?()
                }
                
            }
        } else {
            // MARK: - 비로그인
            presentLoginViewController()
        }
    }
    
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // 메세지 리스너 해제
        for listener in lastMessageListeners {
            listener.cancel()
        }

        for listener in unreadMessageListeners {
            listener.cancel()
        }

        lastMessageListeners.removeAll()
        unreadMessageListeners.removeAll()
    }
    
    // MARK: - Setup ChatList UI
    func setupChatListUI() {
        self.title = "나의 채팅"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        
        self.view.addSubview(tableView)
        
        tableView.backgroundColor = .bgSecondary
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    // MARK: - 로그인/채팅 목록 있음 Methods
    // TODO: - Edit 버튼 액션
    @objc private func editButtonTapped() {
        
    }
    
    // MARK: - Setup Empty ChatList UI
    func setupEmptyChatListUI() {
        self.title = "나의 채팅"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        // Edit 버튼 비활성화
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        container.addSubview(iconImageView)
        container.addSubview(goToHomeButton)
        container.addSubview(guideLabel)
        
        self.view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 150),
            iconImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 121),
            iconImageView.heightAnchor.constraint(equalToConstant: 121),
            
            goToHomeButton.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            goToHomeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 60),
            goToHomeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -60),
            goToHomeButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            goToHomeButton.widthAnchor.constraint(equalToConstant: 231),
            goToHomeButton.heightAnchor.constraint(equalToConstant: 70),
            
            guideLabel.topAnchor.constraint(equalTo: goToHomeButton.bottomAnchor, constant: 20),
            guideLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            guideLabel.widthAnchor.constraint(equalTo: container.widthAnchor)
        ])
    }
    
    // MARK: - 로그인/채팅 목록 없음 Methods
    // goToHomeButton 눌렀을 때
    private func navigateToHome() {
        let homeViewController = MainPostListViewController()
        
        // 현재 탭 바 컨트롤러 가져오기
        if let tabBarController = self.tabBarController,
           let navigationController = tabBarController.viewControllers?[0] as? UINavigationController {

            navigationController.pushViewController(homeViewController, animated: true)

            // 홈 탭으로 전환
            tabBarController.selectedIndex = 0
        }
    }
    
    // MARK: - 비로그인 Methods
    // 비로그인 시 로그인 화면 보여주기
    private func presentLoginViewController() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 3
        }
        
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true)
    }
    
    // 비로그인이었다가 로그인했을 때
    @objc private func userDidLogin() {
        chatViewModel.isLoggedIn = true
        chatViewModel.hasChats = true
        viewDidLoad()
    }
    
    // MARK: - deinit
    deinit {
        // 옵저버 해제
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidLoginNotification"), object: nil)
    }
    
}

// MARK: - UITableViewDataSource
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        
        chatRoom = chatViewModel.chatRooms[indexPath.row]
        cell.chatRoom = chatRoom!
        cell.chatViewModel = self.chatViewModel
        cell.configure(userId: self.chatViewModel.userId!)
        cell.setupUI()
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatListViewController: UITableViewDelegate {
    // 채팅방 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Task {
                do {
                    // 상대방이 채팅방을 나갔다는 메시지 표시
                    let chatMessageViewController = ChatMessageViewController(chatRoom: chatRoom!)
                    chatMessageViewController.showExitMessage()
                    
                    // 메세지 입력 창 비활성화
                    let messageInputViewController = MessageInputViewController(chatRoom: chatRoom!)
                    messageInputViewController.messageInputField.isEnabled = false
                    
                    try await chatViewModel.deleteChatRoom(at: indexPath.row)
                    // 채팅 목록이 비어 있는지 확인하여 UI 업데이트
                    if chatViewModel.chatRooms.isEmpty {
                        self.setupEmptyChatListUI()
                    } else {
                        self.tableView.reloadData()
                    }
                    
                    print("delete")
                } catch {
                    print("Error deleting chat room: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 채팅 디테일로 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChatRoom = chatViewModel.chatRooms[indexPath.row]
        
        let chatViewController = ChatViewController(chatRoom: selectedChatRoom)
        chatViewController.chatViewModel = chatViewModel
        chatViewController.index = indexPath.row
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
}
