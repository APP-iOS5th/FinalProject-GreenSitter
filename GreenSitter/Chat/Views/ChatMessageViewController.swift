//
//  ChatMessageViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit

class ChatMessageViewController: UIViewController {
    // 메세지 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // 메세지 입력 뷰
    private lazy var messageInputBar: UIView = {
        let inputView = UIView()
        inputView.translatesAutoresizingMaskIntoConstraints = false
        
        return inputView
    }()
    
    // 메세지 텍스트
    private lazy var messageTextField: UITextField = {
        let messageText = UITextField()
        messageText.placeholder = "메세지를 입력하세요."
        messageText.backgroundColor = .white
        messageText.layer.cornerRadius = 10
        messageText.layer.borderColor = UIColor.labelsSecondary.cgColor
        messageText.layer.borderWidth = 1
        messageText.translatesAutoresizingMaskIntoConstraints = false
        
        return messageText
    }()

    // 채팅 부가기능 버튼
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // 메세지 보내기 버튼
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .bgSecondary
        
        self.view.addSubview(tableView)
        self.view.addSubview(messageInputBar)
        self.view.addSubview(messageTextField)
        self.view.addSubview(plusButton)
        self.view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
        
        ])
    }

}

extension ChatMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

extension ChatMessageViewController: UITableViewDelegate {
    
}
