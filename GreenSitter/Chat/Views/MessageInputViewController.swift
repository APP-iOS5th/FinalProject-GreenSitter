//
//  MessageInputViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/18/24.
//

import UIKit

class MessageInputViewController: UIViewController {
    // 메세지 패딩
    private lazy var messagePaddingView: UIView = {
        let paddingView = UIView()
        paddingView.backgroundColor = .white
        paddingView.layer.cornerRadius = 15
        paddingView.layer.borderColor = UIColor.labelsSecondary.cgColor
        paddingView.layer.borderWidth = 1
        paddingView.translatesAutoresizingMaskIntoConstraints = false

        return paddingView
    }()
    
    // 메세지 입력 필드
    private lazy var messageInputField: UITextField = {
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
        button.tintColor = .fillTertiary
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // 메세지 보내기 버튼
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.view.backgroundColor = .white
        
        messagePaddingView.addSubview(messageInputField)
        self.view.addSubview(plusButton)
        self.view.addSubview(messagePaddingView)
        self.view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: self.view.topAnchor),
            plusButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            plusButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            plusButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            
            messageInputField.topAnchor.constraint(equalTo: messagePaddingView.topAnchor, constant: 5),
            messageInputField.bottomAnchor.constraint(equalTo: messagePaddingView.bottomAnchor, constant: -5),
            messageInputField.leadingAnchor.constraint(equalTo: messagePaddingView.leadingAnchor, constant: 10),
            messageInputField.trailingAnchor.constraint(equalTo: messagePaddingView.trailingAnchor, constant: -10),
            messageInputField.centerXAnchor.constraint(equalTo: messagePaddingView.centerXAnchor),
            messageInputField.centerYAnchor.constraint(equalTo: messagePaddingView.centerYAnchor),
            
            messagePaddingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            messagePaddingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            messagePaddingView.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 5),
            messagePaddingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            sendButton.topAnchor.constraint(equalTo: self.view.topAnchor),
            sendButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            sendButton.leadingAnchor.constraint(equalTo: messagePaddingView.trailingAnchor, constant: 5),
            sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            sendButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 34),
            sendButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

}
