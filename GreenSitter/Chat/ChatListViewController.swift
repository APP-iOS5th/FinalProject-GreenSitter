//
//  ChatListViewController.swift
//  GreenSitter
//
//  Created by Jihye Park on 8/7/24.
//

import UIKit

class ChatListViewController: UIViewController {
    // 로그인 여부를 나타내는 변수
    private var isLoggedIn = true
    private var hasChats = true
    
    // 샘플 채팅 데이터
    let sampleData = SampleChatData.chatRooms
    // 임시 유저 id
    let userId = "2-1"
    
    // container
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // 아이콘
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ChatIcon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // 홈 이동 버튼
    private lazy var goToHomeButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        // 버튼 타이틀
        var attributedTitle = AttributedString("새싹 돌봄이/보호자\n찾아보기")
        attributedTitle.font = UIFont.preferredFont(forTextStyle: .title3)
        configuration.attributedTitle = attributedTitle
        // 버튼 색상
        configuration.baseBackgroundColor = .appGreen
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
    private lazy var guideLabel: UILabel = {
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
        self.present(loginViewController, animated: true) {
                let image = UIImage(named: "profileIcon")
                let title = "로그인 권한이 필요한 기능입니다."
                let subtitle = "로그인 화면으로 이동합니다."
                if let image = image {
                    self.showToast(image: image, title: title, subtitle: subtitle, on: loginViewController)
            }
        }
    }
    
    // 비로그인 시 토스트 메세지 창
    private func showToast(image: UIImage, title: String, subtitle: String, on viewController: UIViewController) {
        let toastView = UIView()
        toastView.backgroundColor = .white
        toastView.layer.borderColor = UIColor.systemGray4.cgColor
        toastView.layer.borderWidth = 2.0
        toastView.layer.cornerRadius = 23
        toastView.clipsToBounds = true
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UIView()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .black
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        labelView.addSubview(titleLabel)
        labelView.addSubview(subtitleLabel)
        toastView.addSubview(imageView)
        toastView.addSubview(labelView)
        viewController.view.addSubview(toastView)
        
        NSLayoutConstraint.activate([
            toastView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toastView.centerXAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.centerXAnchor),
            toastView.widthAnchor.constraint(equalToConstant: 370),
            toastView.heightAnchor.constraint(equalToConstant: 88),

            imageView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: toastView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 52),
            imageView.heightAnchor.constraint(equalToConstant: 52),
            
            labelView.centerYAnchor.constraint(equalTo: toastView.centerYAnchor),
            labelView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            labelView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: labelView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: labelView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: labelView.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: labelView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: labelView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: labelView.bottomAnchor, constant: -10)
        ])
        
        // LoginView가 뜨고 0.8초 이후에 토스트 메세지가 4.0초 동안 떴다가 서서히 사라짐
        UIView.animate(withDuration: 4.0, delay: 0.8, options: .curveEaseOut, animations: {
            toastView.alpha = 0.0
        }) { _ in
            toastView.removeFromSuperview()
        }
    }
    
    // 비로그인이었다가 로그인했을 때
    @objc private func userDidLogin() {
        isLoggedIn = true
        hasChats = true
        viewDidLoad()
    }
    
    // MARK: - deinit
    deinit {
        // 옵저버 해제
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidLoginNotification"), object: nil)
    }
    
}
