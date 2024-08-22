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
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatViewModel?.updateUI = { [weak self] in
            self?.setupUI()
        }
        
        self.chatViewModel?.updateUI?()
        
//        chatViewModel?.loadMessages(chatRoomId: chatRoom.id) { [weak self] in
//            guard let self = self else { return }
//            
//            self.tableView.reloadData()
//            
//        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.view.backgroundColor = .bgSecondary
        
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: "ChatMessageCell")
        
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
        guard let messages = chatViewModel?.messages[chatRoom.id] else {
            return 0
        }
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
