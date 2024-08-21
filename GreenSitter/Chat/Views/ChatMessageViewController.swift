//
//  ChatMessageViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit

class ChatMessageViewController: UIViewController {
    var chatViewModel: ChatViewModel?
    
    // 임시 데이터
//    var messages: [String] = ["Hello!", "How are you?", "I'm fine, thanks!", "What about you?", "I'm good too!", "어디까지 나오는지 테스트해보자아아아아아아아아아아아아아아아앙아아아아아", "읽었어?"]
//    var isIncoming: [Bool] = [false, true, false, false, true, true, false]
//    var isRead: [Bool] = [true, true, true, true, true, true, false]
    
    // 메세지 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .bgSecondary
        // 셀 구분선 제거
        tableView.separatorStyle = .none
        // 셀 선택 불가능하게 설정
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatViewModel?.loadMessages { [weak self] in
            guard let self = self else { return }
            
            self.chatViewModel?.updateUI = { [weak self] in
                self?.setupUI()
            }
            
            self.chatViewModel?.updateUI?()
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.view.backgroundColor = .bgSecondary
        
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.register(ChatMessageTableViewImageCell.self, forCellReuseIdentifier: "ChatMessageImageCell")
        
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

extension ChatMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel?.messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: 메세지 유형에 따라 cell 다르게 하기, 이미지의 경우 UIImage로 변환해서 cell에 전달
        switch chatViewModel?.messages?[indexPath.row].messageType {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
            cell.backgroundColor = .clear
            cell.messageLabel.text = chatViewModel?.messages?[indexPath.row].text
            
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            
            return cell
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageImageCell", for: indexPath) as! ChatMessageTableViewImageCell
            cell.backgroundColor = .clear
            
            let imageCounts: Int = chatViewModel?.messages?[indexPath.row].image?.count ?? 0
            cell.images = []
            
            for _ in 0..<imageCounts {
                if let photoImage = UIImage(systemName: "photo") {
                    cell.images.append(photoImage)
                }
            }
            
            if let imagePaths = chatViewModel?.messages?[indexPath.row].image {
                Task {
                    let images = await chatViewModel?.loadChatImages(imagePaths: imagePaths)
                    print("images : \(String(describing: images))")
                    DispatchQueue.main.async {
                        cell.images = images ?? []
                    }
                }
            }
            
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            return cell
            //TODO: plan
        case .plan:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageImageCell", for: indexPath) as! ChatMessageTableViewImageCell
            cell.backgroundColor = .clear
            
            cell.images = [UIImage(systemName: "xmark")!.withRenderingMode(.alwaysTemplate), UIImage(systemName: "square.and.arrow.up.fill")!.withRenderingMode(.alwaysTemplate)]
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            return cell
        case .none:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageTableViewCell
            cell.backgroundColor = .clear
            cell.messageLabel.text = chatViewModel?.messages?[indexPath.row].text
            
            if chatViewModel?.userId == chatViewModel?.messages?[indexPath.row].senderUserId {
                cell.isIncoming = false
            } else {
                cell.isIncoming = true
            }
            
            cell.isRead = ((chatViewModel?.messages?[indexPath.row].isRead) != nil)
            
            return cell
        }
    }
}

extension ChatMessageViewController: UITableViewDelegate {
    
}
