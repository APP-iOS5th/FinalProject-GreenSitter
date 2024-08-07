//
//  AlbumTestViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/7/24.
//

import UIKit

class ChatAdditionalButtonsViewController: UIViewController {
    
    private lazy var albumButton: ChatAdditionalButton = {
        let albumButton = ChatAdditionalButton(imageName: "photo.on.rectangle", titleText: "앨범", buttonAction: albumButtonAction)
        albumButton.translatesAutoresizingMaskIntoConstraints = false
        return albumButton
    }()
    
    private let albumButtonAction = UIAction { _ in
        print("ButtonTapped")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(albumButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            albumButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            albumButton.heightAnchor.constraint(equalToConstant: 50),
            albumButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            albumButton.widthAnchor.constraint(equalToConstant: 108)
        ])
    }
    
}

//MARK: Chat Additional Button
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
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: imageName)?.withTintColor(.black, renderingMode: .alwaysOriginal))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(imageView)
        
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [backgroundView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 50),
            backgroundView.heightAnchor.constraint(equalToConstant: 50),
            imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 35),
            imageView.heightAnchor.constraint(equalToConstant: 35),
        ])
        
        addAction(buttonAction, for: .touchUpInside)
    }
}
