//
//  ChatAdditionalButton.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/7/24.
//

import UIKit

class ChatAdditionalButton: UIButton {
    private let imageName: String
    private let titleText: String
    private let buttonAction: UIAction
    
    init(imageName: String, titleText: String, buttonAction: UIAction) {
        self.imageName = imageName
        self.titleText = titleText
        self.buttonAction = buttonAction
        super.init(frame: .zero)
        setupChatAdditionalButtonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChatAdditionalButtonUI() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white.withAlphaComponent(0.85)
        backgroundView.layer.cornerRadius = 25
        backgroundView.layer.masksToBounds = true
        
        let imageView = UIImageView(image: UIImage(systemName: imageName)?.withTintColor(.black, renderingMode: .alwaysOriginal))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [backgroundView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 50),
            backgroundView.heightAnchor.constraint(equalToConstant: 50),
            imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        addAction(buttonAction, for: .touchUpInside)
    }
}
