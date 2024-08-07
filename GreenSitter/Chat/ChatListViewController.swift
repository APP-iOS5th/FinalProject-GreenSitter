//
//  ChatListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class ChatListViewController: UIViewController {
    
    // container
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // 아이콘
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ChatIcon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // 홈 이동 버튼
    private let goToHomeButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        // 버튼 타이틀
        var attributedTitle = AttributedString("새싹 돌봄이/보호자\n찾아보기")
        attributedTitle.font = UIFont.preferredFont(forTextStyle: .title3)
        configuration.attributedTitle = attributedTitle
        // 버튼 색상
        configuration.baseBackgroundColor = UIColor(red: 128/255, green: 188/255, blue: 86/255, alpha: 1.0)
        configuration.baseForegroundColor = .white
        // padding
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let button = UIButton(configuration: configuration)
        // 버튼 타이틀 여러 줄 표시
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping

        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // 기본 텍스트
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 참여 중인 채팅이 없습니다."
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // TODO: - 비로그인 시
        
        
        // MARK: - 로그인 시
        
    }
    
    // MARK: - Setup UI
    func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        self.title = "나의 채팅"
        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: <#T##Any?#>, action: <#T##Selector?#>)
        
        container.addSubview(iconImageView)
        container.addSubview(goToHomeButton)
        container.addSubview(guideLabel)
        
        self.view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 333),
            container.heightAnchor.constraint(equalToConstant: 281),
            
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 121),
            iconImageView.heightAnchor.constraint(equalToConstant: 121),
            
            goToHomeButton.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            goToHomeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 60),
            goToHomeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -60),
            goToHomeButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            goToHomeButton.widthAnchor.constraint(equalToConstant: 231),
            goToHomeButton.heightAnchor.constraint(equalToConstant: 70),
            
            guideLabel.topAnchor.constraint(equalTo: goToHomeButton.bottomAnchor, constant: 20),
            guideLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            guideLabel.widthAnchor.constraint(equalTo: container.widthAnchor)
        ])
    }

}
