//
//  ChatViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/12/24.
//

import UIKit

class ChatViewController: UIViewController {
    var chatListViewModel: ChatListViewModel?
    var postThumbnail: String?
    var postTitle: String?
    var postStatus: PostStatus?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(listButtonTapped))
        
        let chatPostViewController = ChatPostViewController()
        guard let chatPostView = chatPostViewController.view else {
            return
        }
        
        guard let postThumbnailUrl = URL(string: postThumbnail!) else {
            return
        }
        chatListViewModel?.downloadImage(from: postThumbnailUrl, to: chatPostViewController.postThumbnailView)
        chatPostViewController.postTitleLabel.text = postTitle
        chatPostViewController.postStatusLabel.text = postStatus?.rawValue
        
        self.view.addSubview(chatPostView)
        
        NSLayoutConstraint.activate([
            chatPostView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            chatPostView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatPostView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatPostView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            chatPostView.widthAnchor.constraint(equalToConstant: self.view.bounds.width),
            chatPostView.heightAnchor.constraint(equalToConstant: 100)
        ])

    }
    
    @objc func listButtonTapped() {
        print("list button")
    }

}
