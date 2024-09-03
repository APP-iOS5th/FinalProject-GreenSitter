//
//  ChatMessageTableViewReviewCell.swift
//  GreenSitter
//
//  Created by 김영훈 on 9/3/24.
//

import UIKit

class ChatMessageTableViewReviewCell: UITableViewCell {
    var makeReviewButtonAction: (() -> Void)?
    
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom?
    
    private lazy var currentId: String? = {
        chatViewModel?.userId
    }()
    
    lazy var recipientName: String = {
        let recipientName = ""
        return recipientName
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(recipientName)님과의\n돌봄 거래는 어떠셨나요?\n\n후기는 다른 고객분들께\n큰 도움이 됩니다!"
        return label
    }()
    
    lazy var makeReviewButton: UIButton = {
        let makeReviewButton = UIButton()
        makeReviewButton.setTitle("후기 작성하기", for: .normal)
        makeReviewButton.backgroundColor = .dominent
        makeReviewButton.layer.cornerRadius = 7
        makeReviewButton.translatesAutoresizingMaskIntoConstraints = false
        makeReviewButton.addTarget(self, action: #selector(makeReviewButtonTapped), for: .touchUpInside)
        return makeReviewButton
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BGPrimary")
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // TODO: - 오전 12시에 날짜 출력
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .fillTertiary
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
        label.text = "2024년 8월 19일"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(makeReviewButton)
        contentView.addSubview(bubbleView)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            messageLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            
            makeReviewButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            makeReviewButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            makeReviewButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            makeReviewButton.widthAnchor.constraint(equalToConstant: 130),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    func updateRecipientName() {
        recipientName = {
            let recipientName: String
            if currentId == chatRoom?.postUserId {
                recipientName = chatRoom?.userNickname ?? ""
            } else {
                recipientName = chatRoom?.postUserNickname ?? ""
            }
            return recipientName
        }()
        DispatchQueue.main.async {
            self.messageLabel.text = "\(self.recipientName)님과의\n돌봄 거래는 어떠셨나요?\n\n후기는 다른 고객분들께\n큰 도움이 됩니다!"
        }
    }
    
    @objc
    private func makeReviewButtonTapped() {
        makeReviewButtonAction?()
    }
}

