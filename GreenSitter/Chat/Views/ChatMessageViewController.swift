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
    
    private let imageCache = NSCache<NSString, UIImage>()
    
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
        super.viewWillAppear(true)
        Task {
            // 메세지 읽음 처리
            try await chatViewModel?.updateUnread(chatRoomId: chatRoom.id)
            
            let messageListener = Task {
                // 옵셔널 언래핑
                if let messagesStream = await chatViewModel?.loadMessages(chatRoomId: chatRoom.id) {
                    for await messages in messagesStream {
                        self.chatViewModel?.messages[chatRoom.id] = messages
                        // await MainActor.run { self.tableView.reloadData() }
                    }
                } else {
                    print("Failed to load messages for chatRoomId: \(chatRoom.id)")
                }
            }
            messageListeners.append(messageListener)
            
            // UI 업데이트
            await MainActor.run {
                chatViewModel?.updateUI = { [weak self] in
                    self?.setupUI()
                    // 테이블 뷰를 리로드하여 최신 메시지를 표시
                    self?.tableView.reloadData()
                    
                    DispatchQueue.main.async {
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
        super.viewWillDisappear(true)
        
        // 메세지 리스너 해제
        for listener in messageListeners {
            listener.cancel()
        }

        messageListeners.removeAll()
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
            
            if chatViewModel?.userId == messages[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            cell.isRead = messages[indexPath.row].isRead

            cell.chatRoom = chatRoom
            cell.chatViewModel = self.chatViewModel
            cell.configure()
            
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
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        cell.imageURLs.append(imageURL)
                    }
                }
                
                cell.delegate = self
                
                if chatViewModel?.userId == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoImagesCell", for: indexPath) as! TwoImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                let imagePaths = messages[indexPath.row].image ?? []
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        cell.imageURLs.append(imageURL)
                    }
                }
                
                cell.delegate = self
                
                if chatViewModel?.userId == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ThreeImagesCell", for: indexPath) as! ThreeImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                let imagePaths = messages[indexPath.row].image ?? []
                
                for imagePath in imagePaths {
                    if let imageURL = URL(string: imagePath) {
                        cell.imageURLs.append(imageURL)
                    }
                }
                
                cell.delegate = self
                
                if chatViewModel?.userId == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FourImagesCell", for: indexPath) as! FourImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                cell.tag = indexPath.row

                
                var progressImages = [UIImage]()
                
                for _ in 0..<imageCounts {
                    if let photoImage = UIImage(systemName: "photo") {
                        
                        let targetSize = CGSize(width: 400, height: 400)
                        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
                        photoImage.draw(in: CGRect(origin: .zero, size: targetSize))
                        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        if let resizedImage = resizedImage {
                            progressImages.append(resizedImage)
                        }
                    }
                }
                cell.images = progressImages
                
                let imagePaths = messages[indexPath.row].image ?? []
                var cachedImages = [UIImage]()
                var imagesToLoad = [String]()
                
                for imagePath in imagePaths {
                    if let cachedImage = imageCache.object(forKey: NSString(string: imagePath)) {
                        cachedImages.append(cachedImage)
                    } else {
                        imagesToLoad.append(imagePath)
                    }
                }
                
//                if !imagesToLoad.isEmpty {
//                    Task {
//                        let loadedImages = await chatViewModel?.loadChatImages(imagePaths: imagesToLoad)
//                        DispatchQueue.main.async {
//                            if cell.tag == indexPath.row {
//                                if let loadedImages = loadedImages {
//                                    for (index, image) in loadedImages.enumerated() {
//                                        let path = imagesToLoad[index]
//                                        self.imageCache.setObject(image, forKey: NSString(string: path))
//                                        cachedImages.append(image)
//                                    }
//                                    cell.images = cachedImages
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    cell.images = cachedImages
//                }
                
                cell.delegate = self
                
                if chatViewModel?.userId == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MoreImagesCell", for: indexPath) as! MoreImagesTableViewCell
                
                cell.backgroundColor = .clear
                
                cell.tag = indexPath.row

                
                var progressImages = [UIImage]()
                
                for _ in 0..<imageCounts {
                    if let photoImage = UIImage(systemName: "photo") {
                        
                        let targetSize = CGSize(width: 400, height: 400)
                        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
                        photoImage.draw(in: CGRect(origin: .zero, size: targetSize))
                        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        if let resizedImage = resizedImage {
                            progressImages.append(resizedImage)
                        }
                    }
                }
                cell.images = progressImages
                
                let imagePaths = messages[indexPath.row].image ?? []
                var cachedImages = [UIImage]()
                var imagesToLoad = [String]()
                
                for imagePath in imagePaths {
                    if let cachedImage = imageCache.object(forKey: NSString(string: imagePath)) {
                        cachedImages.append(cachedImage)
                    } else {
                        imagesToLoad.append(imagePath)
                    }
                }
                
//                if !imagesToLoad.isEmpty {
//                    Task {
//                        let loadedImages = await chatViewModel?.loadChatImages(imagePaths: imagesToLoad)
//                        DispatchQueue.main.async {
//                            if cell.tag == indexPath.row {
//                                if let loadedImages = loadedImages {
//                                    for (index, image) in loadedImages.enumerated() {
//                                        let path = imagesToLoad[index]
//                                        self.imageCache.setObject(image, forKey: NSString(string: path))
//                                        cachedImages.append(image)
//                                    }
//                                    cell.images = cachedImages
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    cell.images = cachedImages
//                }
                
                cell.delegate = self
                
                if chatViewModel?.userId == messages[indexPath.row].senderUserId {
                    cell.isIncoming = false
                } else {
                    cell.isIncoming = true
                }
                cell.isRead = messages[indexPath.row].isRead
                
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
                let makePlanViewModel = MakePlanViewModel(date: plan.planDate, planPlace: plan.planPlace, ownerNotification: plan.ownerNotification, sitterNotification: plan.sitterNotification, progress: 3, isPlaceSelected: true, chatRoom: chatRoom)
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
            
            if chatViewModel?.userId == messages[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.isRead = messages[indexPath.row].isRead
            
            return cell
            
        case .none:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
            
            guard let messages = self.chatViewModel?.messages[chatRoom.id],
                  indexPath.row < messages.count else {
                fatalError("Unable to retrieve messages for the selected chat room")
            }
            
            cell.backgroundColor = .clear
            cell.messageLabel.text = messages[indexPath.row].text
            
            if chatViewModel?.userId == messages[indexPath.row].senderUserId {
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
