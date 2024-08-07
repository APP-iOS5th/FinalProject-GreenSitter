//
//  ChatListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class ChatListViewController: UIViewController {
    // 로그인 여부를 나타내는 변수
    private var isLoggedIn = true
    private var hasChats = false
    
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
        
        self.view.backgroundColor = .systemBackground
        
        // 로그인 이벤트 수신
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: NSNotification.Name("UserDidLoginNotification"), object: nil)

        if isLoggedIn {
            // MARK: - 로그인/채팅방 있음
            if hasChats {
                setupChatListUI()
                
            } else {
                // MARK: - 로그인/채팅방 없음
                setupEmptyChatListUI()
                
                // 버튼 클릭 시 홈 화면으로 이동
                goToHomeButton.addAction(UIAction { [weak self] _ in
                    self?.navigateToHome()}, for: .touchUpInside)
            }
        } else {
            // MARK: - 비로그인
            presentLoginViewController()
        }
    }
    
    // MARK: - Setup ChatList UI
    func setupChatListUI() {
        self.title = "나의 채팅"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
    }
    
    // MARK: - 로그인/채팅 목록 있음 Methods
    @objc private func editButtonTapped() {

    }
    
    // MARK: - Setup Empty ChatList UI
    func setupEmptyChatListUI() {
        self.title = "나의 채팅"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        // Edit 버튼 비활성화
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
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
    
    // MARK: - 로그인/채팅 목록 없음 Methods
    // goToHomeButton 눌렀을 때
    private func navigateToHome() {
        let homeViewController = PostListViewController()
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    // MARK: - 비로그인 Methods
    // 비로그인 시 로그인 화면 보여주기
    private func presentLoginViewController() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true, completion: nil)
    }
    
    // 비로그인이었다가 로그인했을 때
    @objc private func userDidLogin() {
        isLoggedIn = true
        hasChats = true
        viewDidLoad()
    }

}
