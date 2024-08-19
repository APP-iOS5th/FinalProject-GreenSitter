//
//  TestViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/18/24.
//

import UIKit

class TestViewController: UIViewController {
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setTitle("plusButton", for: .normal)
        plusButton.backgroundColor = .systemBlue
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addAction(UIAction { [weak self] _ in
            self?.presentChatAdditionalButtonsViewController()
        }, for: .touchUpInside)
        return plusButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(plusButton)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            plusButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -100),
            plusButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 100),
            plusButton.widthAnchor.constraint(equalToConstant: 200),
            plusButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func presentChatAdditionalButtonsViewController() {
        let chatAdditionalButtonsViewController = ChatAdditionalButtonsViewController()
        chatAdditionalButtonsViewController.modalPresentationStyle = .overCurrentContext
        self.present(chatAdditionalButtonsViewController, animated: true, completion: nil)
    }
}
