//
//  PostListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class PostListViewController: UIViewController {
//    private var firestoreManager = FirestoreManager()
    
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
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // 버튼 클릭 시 호출될 메서드
    @objc func buttonTapped() {
        print("버튼이 클릭되었습니다!")
    }
}
