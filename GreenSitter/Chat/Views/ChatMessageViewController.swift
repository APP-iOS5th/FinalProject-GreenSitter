//
//  ChatMessageViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit

class ChatMessageViewController: UIViewController {
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom
    private var messageListeners: [Task<Void, Never>] = []
    private var unreadMessageListeners: [Task<Void, Never>] = []
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 메세지 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        // 셀 구분선 제거
        tableView.separatorStyle = .none
        // 셀 선택 불가능하게 설정
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            // 초기 메세지 읽음 처리
            try await chatViewModel?.updateUnread(chatRoomId: chatRoom.id)
            
            let messageListener = Task {
                // 옵셔널 언래핑
                if let messagesStream = await chatViewModel?.loadMessages(chatRoomId: chatRoom.id) {
                    for await messages in messagesStream {
                        self.chatViewModel?.messages[chatRoom.id] = messages
                    }
                } else {
                    print("Failed to load messages for chatRoomId: \(chatRoom.id)")
                }
            }
            messageListeners.append(messageListener)
            
            // 읽지 않은 메시지 리스너 설정
            let unreadMessageListener = Task {
                if let unreadMessagesStream = await chatViewModel?.loadUnreadMessages(chatRoomId: chatRoom.id) {
                    for await messages in unreadMessagesStream {
                        self.chatViewModel?.unreadMessages[chatRoom.id] = messages
                        do {
                            try await chatViewModel?.updateUnread(chatRoomId: chatRoom.id)
                        } catch {
                            print("Failed to update unread status: \(error)")
                        }
                    }
                } else {
                    print("Failed to load unread messages for chatRoomId: \(chatRoom.id)")
                }
            }
            unreadMessageListeners.append(unreadMessageListener)
            
            // UI 업데이트
            await MainActor.run {
                chatViewModel?.updateUI = { [weak self] in
                    self?.setupUI()
                    // 테이블 뷰를 리로드하여 최신 메시지를 표시
                    self?.tableView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        guard let numberOfSections = self?.tableView.numberOfSections,
                              let numberOfRows = self?.tableView.numberOfRows(inSection: numberOfSections - 1) else {
                            return
                        }
                        
                        if numberOfRows > 0 {
                            let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
                            self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                }
                
                chatViewModel?.updateUI?()
            }
        }
    }
    
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 메세지 리스너 해제
        for listener in messageListeners {
            listener.cancel()
        }
        
        for listener in unreadMessageListeners {
            listener.cancel()
        }

        messageListeners.removeAll()
        unreadMessageListeners.removeAll()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.register(OneImageTableViewCell.self, forCellReuseIdentifier: "OneImageCell")
        tableView.register(TwoImagesTableViewCell.self, forCellReuseIdentifier: "TwoImagesCell")
        tableView.register(ThreeImagesTableViewCell.self, forCellReuseIdentifier: "ThreeImagesCell")
        tableView.register(FourImagesTableViewCell.self, forCellReuseIdentifier: "FourImagesCell")
        tableView.register(MoreImagesTableViewCell.self, forCellReuseIdentifier: "MoreImagesCell")
        tableView.register(ChatMessageTableViewPlanCell.self, forCellReuseIdentifier: "ChatMessagePlanCell")
        tableView.register(ChatMessageTableViewReviewCell.self, forCellReuseIdentifier: "ChatMessageReviewCell")
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ChatMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let messages = chatViewModel?.messages[chatRoom.id] else {
            return 0
        }
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch chatViewModel?.messages[chatRoom.id]?[indexPath.row].messageType {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
            
            guard let messages = self.chatViewModel?.messages[chatRoom.id],
                  indexPath.row < messages.count else {
                fatalError("Unable to retrieve messages for the selected chat room")
            }
            
            cell.backgroundColor = .clear
            cell.messageLabel.text = messages[indexPath.row].text
            
            if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            cell.isRead = messages[indexPath.row].isRead

            cell.chatRoom = chatRoom
            cell.chatViewModel = self.chatViewModel
            
            let messageTime = messages[indexPath.row].createDate
            cell.configure(date: messageTime)
            
            return cell
            
        case .image:
            guard let messages = self.chatViewModel?.messages[chatRoom.id],
                  indexPath.row < messages.count else {
                fatalError("Unable to retrieve messages for the selected chat room")
            }
            let imageCounts: Int = messages[indexPath.row].image?.count ?? 0
            
            switch imageCounts {
            case 0:
                return UITableViewCell()
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OneImageCell", for: indexPath) as! OneImageTableViewCell
                
                cell.backgroundColor = .clear
                
                let imagePaths = messages[indexPath.row].image ?? []
                var imageURLs = [URL]()
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        imageURLs.append(imageURL)
                    }
                }
                cell.imageURLs = imageURLs
                
                cell.delegate = self
                
                if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                cell.chatRoom = chatRoom
                cell.chatViewModel = self.chatViewModel
                let messageTime = messages[indexPath.row].createDate
                cell.configure(date: messageTime)
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoImagesCell", for: indexPath) as! TwoImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                let imagePaths = messages[indexPath.row].image ?? []
                var imageURLs = [URL]()
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        imageURLs.append(imageURL)
                    }
                }
                cell.imageURLs = imageURLs
                
                cell.delegate = self
                
                if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                cell.chatRoom = chatRoom
                cell.chatViewModel = self.chatViewModel
                let messageTime = messages[indexPath.row].createDate
                cell.configure(date: messageTime)
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ThreeImagesCell", for: indexPath) as! ThreeImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                let imagePaths = messages[indexPath.row].image ?? []
                var imageURLs = [URL]()
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        imageURLs.append(imageURL)
                    }
                }
                cell.imageURLs = imageURLs
                
                cell.delegate = self
                
                if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                cell.chatRoom = chatRoom
                cell.chatViewModel = self.chatViewModel
                let messageTime = messages[indexPath.row].createDate
                cell.configure(date: messageTime)
                
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FourImagesCell", for: indexPath) as! FourImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                let imagePaths = messages[indexPath.row].image ?? []
                var imageURLs = [URL]()
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        imageURLs.append(imageURL)
                    }
                }
                cell.imageURLs = imageURLs
                
                cell.delegate = self
                
                if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                cell.chatRoom = chatRoom
                cell.chatViewModel = self.chatViewModel
                let messageTime = messages[indexPath.row].createDate
                cell.configure(date: messageTime)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MoreImagesCell", for: indexPath) as! MoreImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                let imagePaths = messages[indexPath.row].image ?? []
                var imageURLs = [URL]()
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        imageURLs.append(imageURL)
                    }
                }
                cell.imageURLs = imageURLs
                
                cell.delegate = self
                
                if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                cell.chatRoom = chatRoom
                cell.chatViewModel = self.chatViewModel
                let messageTime = messages[indexPath.row].createDate
                cell.configure(date: messageTime)
                
                return cell
            }
            
        case .plan:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessagePlanCell", for: indexPath) as! ChatMessageTableViewPlanCell
            cell.backgroundColor = .clear
            
            guard let messages = self.chatViewModel?.messages[chatRoom.id],
                  indexPath.row < messages.count else {
                fatalError("Unable to retrieve messages for the selected chat room")
            }
            
            let planDate = messages[indexPath.row].plan?.planDate
            if let planDate = planDate {
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateStyle = .medium
                let dateString = dateFormatter.string(from: planDate)
                
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                let timeString = dateFormatter.string(from: planDate)
                
                cell.planDateLabel.text = "날짜: \(dateString)"
                cell.planTimeLabel.text = "시간: \(timeString)"
            }
            
            let planPlace = messages[indexPath.row].plan?.planPlace?.placeName ?? ""
            cell.planPlaceLabel.text = "장소: \(planPlace)"
            
            if let plan = messages[indexPath.row].plan {
                let makePlanViewModel = MakePlanViewModel(planId: plan.planId, date: plan.planDate, planPlace: plan.planPlace, ownerNotification: plan.ownerNotification, sitterNotification: plan.sitterNotification, progress: 3, isPlaceSelected: true, planType: plan.planType, chatViewModel: chatViewModel, chatRoom: chatRoom, messageId: messages[indexPath.row].id)
                makePlanViewModel.chatMessageTableViewPlanCellDelegate = cell
                cell.detailButtonAction = {
                    self.present(MakePlanViewController(viewModel: makePlanViewModel), animated: true)
                }
            }
            
            if let planPlace = messages[indexPath.row].plan?.planPlace {
                cell.placeButtonAction = {
                    let navigationController = UINavigationController(rootViewController: PlanPlaceDetailViewController(location: planPlace))
                    self.present(navigationController, animated: true)
                }
            }
            
            if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.isRead = messages[indexPath.row].isRead
            
            cell.chatRoom = chatRoom
            cell.chatViewModel = self.chatViewModel
            cell.planEnabled = messages[indexPath.row].plan?.enabled ?? true
            let messageTime = messages[indexPath.row].createDate
            cell.configure(date: messageTime)
            
            return cell
        case .review:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageReviewCell", for: indexPath) as! ChatMessageTableViewReviewCell
            cell.backgroundColor = .clear
            
            guard let messages = self.chatViewModel?.messages[chatRoom.id],
                  indexPath.row < messages.count else {
                fatalError("Unable to retrieve messages for the selected chat room")
            }
            
            cell.makeReviewButtonAction = {
                if let userId = self.chatViewModel?.user?.id {
                    self.navigationController?.pushViewController(ReviewListViewController(userId: userId), animated: true)
                }
            }
            cell.chatRoom = chatRoom
            cell.chatViewModel = self.chatViewModel
            cell.setupUI()
            cell.updateRecipientName()
            
            return cell
        case .none:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
            
            guard let messages = self.chatViewModel?.messages[chatRoom.id],
                  indexPath.row < messages.count else {
                fatalError("Unable to retrieve messages for the selected chat room")
            }
            
            cell.backgroundColor = .clear
            cell.messageLabel.text = messages[indexPath.row].text
            
            if chatViewModel?.user?.id == messages[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            cell.isRead = messages[indexPath.row].isRead
            
            return cell
        }
    }
}

// MARK: - ChatMessageTableViewImageCellDelegate
extension ChatMessageViewController: ChatMessageTableViewImageCellDelegate {
    func imageViewTapped(images: [UIImage], index: Int) {
        let imageDetailCollectionView = ImageDetailCollectionViewController(images: images, index: index)
        self.present(imageDetailCollectionView, animated: true, completion: nil)
    }
}
