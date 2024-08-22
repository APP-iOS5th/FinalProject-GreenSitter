//
//  PostListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class PostListViewController: UIViewController {
    private var postViewModel = PostDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .bgSecondary
        
        // 채팅하기 버튼 눌렀을 때 채팅방 데이터 생성 및 저장
        let button = UIButton(type: .system)

        button.setTitle("채팅하기", for: .normal)
        button.backgroundColor = .dominent
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            Task {
                await self?.postViewModel.chatButtonTapped()
            }
        }, for: .touchUpInside)

        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // ChatDetailView로 이동
        postViewModel.onChatButtonTapped = { [weak self] chatRoom in
            self?.navigateToChatDetail(chatRoom: chatRoom)
        }
    }
    
    private func navigateToChatDetail(chatRoom: ChatRoom) {
        let chatViewModel = ChatViewModel()
        chatViewModel.chatRoom = chatRoom
        
        let chatDetailViewController = ChatViewController()
        chatDetailViewController.chatViewModel = chatViewModel
        self.navigationController?.pushViewController(chatDetailViewController, animated: true)
    }

}
