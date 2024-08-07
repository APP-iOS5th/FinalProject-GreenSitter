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
    
    private lazy var cameraButton: ChatAdditionalButton = {
        let cameraButton = ChatAdditionalButton(imageName: "camera.fill", titleText: "카메라", buttonAction: cameraButtonAction)
        return cameraButton
    }()
    
    private lazy var planButton: ChatAdditionalButton = {
        let planButton = ChatAdditionalButton(imageName: "calendar", titleText: "약속 정하기", buttonAction: planButtonAction)
        return planButton
    }()
    
    private lazy var additionalButtonStackView: UIStackView = {
       let additionalButtonStackView = UIStackView(arrangedSubviews: [planButton, cameraButton, albumButton])
        additionalButtonStackView.axis = .vertical
        additionalButtonStackView.spacing = 62
        additionalButtonStackView.alignment = .center
        additionalButtonStackView.translatesAutoresizingMaskIntoConstraints = false

        return additionalButtonStackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(additionalButtonStackView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            additionalButtonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -115),
            additionalButtonStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
        ])
    }
    
    //MARK: Button UIActions
    private let albumButtonAction = UIAction { _ in
        print("AlbumButton Tapped")
    }
    
    private let cameraButtonAction = UIAction { _ in
        print("CameraButton Tapped")
    }
    
    private let planButtonAction = UIAction { _ in
        print("planButton Tapped")
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
