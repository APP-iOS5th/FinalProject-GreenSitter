//
//  MessageInputViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/18/24.
//

import UIKit

class MessageInputViewController: UIViewController {
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 메세지 패딩
    private lazy var messagePaddingView: UIView = {
        let paddingView = UIView()
        paddingView.layer.cornerRadius = 15
        paddingView.layer.borderColor = UIColor.labelsSecondary.cgColor
        paddingView.layer.borderWidth = 1
        paddingView.translatesAutoresizingMaskIntoConstraints = false

        return paddingView
    }()
    
    // 메세지 입력 필드
    lazy var messageInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메세지를 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()

    // 채팅 부가기능 버튼
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let largeSymbolImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeSymbolImage, for: .normal)
        button.tintColor = .labelsTertiary
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.plusButtonTapped()
        }, for: .touchUpInside)
        
        return button
    }()
    
    // 메세지 보내기 버튼
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isEnabled = false
        button.addAction(UIAction { [weak self] _ in
            self?.sendMessage()
        }, for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        messageInputField.delegate = self
        
        // 메세지 입력하지 않았을 때 sendButton 비활성화
        messageInputField.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            self.textFieldDidChange(self.messageInputField)
        }, for: .editingChanged)

    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.view.backgroundColor = .bgPrimary
        plusButton.backgroundColor = .bgPrimary
        messagePaddingView.backgroundColor = .bgPrimary
        sendButton.backgroundColor = .bgPrimary
        
        messagePaddingView.addSubview(messageInputField)
        self.view.addSubview(plusButton)
        self.view.addSubview(messagePaddingView)
        self.view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            plusButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            plusButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            plusButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            
            messageInputField.topAnchor.constraint(equalTo: messagePaddingView.topAnchor, constant: 5),
            messageInputField.bottomAnchor.constraint(equalTo: messagePaddingView.bottomAnchor, constant: -5),
            messageInputField.leadingAnchor.constraint(equalTo: messagePaddingView.leadingAnchor, constant: 10),
            messageInputField.trailingAnchor.constraint(equalTo: messagePaddingView.trailingAnchor, constant: -10),
            messageInputField.centerXAnchor.constraint(equalTo: messagePaddingView.centerXAnchor),
            messageInputField.centerYAnchor.constraint(equalTo: messagePaddingView.centerYAnchor),
            
            messagePaddingView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            messagePaddingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            messagePaddingView.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 5),
            messagePaddingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            sendButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            sendButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            sendButton.leadingAnchor.constraint(equalTo: messagePaddingView.trailingAnchor, constant: 5),
            sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 34),
            sendButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - plus button
    func plusButtonTapped() {
        let chatAdditionalButtonsViewController = ChatAdditionalButtonsViewController(chatRoom: chatRoom)
        chatAdditionalButtonsViewController.modalPresentationStyle = .overFullScreen
        chatAdditionalButtonsViewController.chatViewModel = self.chatViewModel
        present(chatAdditionalButtonsViewController, animated: true)
    }
    
    // MARK: - MessageInputField
    func textFieldDidChange(_ textField: UITextField) {
        sendButton.isEnabled = !(textField.text?.isEmpty ?? true)
    }
    
    // MARK: - SendButton
    private func sendMessage() {
        guard let text = messageInputField.text, !text.isEmpty else { return }
        
        self.chatViewModel?.sendButtonTapped(text: text, chatRoom: chatRoom)
        messageInputField.text = ""
        sendButton.isEnabled = false
    }
}

// MARK: - UITextFieldDelegate
extension MessageInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        
        return true
    }
}
