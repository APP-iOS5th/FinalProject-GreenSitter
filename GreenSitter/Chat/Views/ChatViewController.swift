//
//  ChatViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/12/24.
//

import UIKit

class ChatViewController: UIViewController {
    var chatListViewModel: ChatListViewModel?
    var postId: String?
    var postThumbnail: String?
    var postTitle: String?
    var postStatus: PostStatus?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // 게시물 디테일로 이동하기 위한 Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
            
    }
    
    // MARK: - Setup UI
    func setupUI() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(listButtonTapped))
        
        let chatPostViewController = ChatPostViewController()
        
        guard let postThumbnailUrl = URL(string: postThumbnail!) else {
            return
        }
        chatListViewModel?.downloadImage(from: postThumbnailUrl, to: chatPostViewController.postThumbnailView)
        chatPostViewController.postTitleLabel.text = postTitle
        chatPostViewController.postStatusLabel.text = postStatus?.rawValue
        
        addChild(chatPostViewController)
        self.view.addSubview(chatPostViewController.view)
        chatPostViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            chatPostViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            chatPostViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatPostViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatPostViewController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            chatPostViewController.view.widthAnchor.constraint(equalToConstant: self.view.bounds.width),
            chatPostViewController.view.heightAnchor.constraint(equalToConstant: 100)
        ])

    }
    
    @objc private func listButtonTapped() {
        print("list button")
    }
    
    @objc private func handleTap() {
        let postDetailViewController = PostDetailViewController()
        
        // TODO: - 특정 게시물로 이동
//        postDetailViewController.postId = postId
        
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }

}
