//
//  AlbumTestViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/7/24.
//

import UIKit

class ChatAdditionalButtonsViewController: UIViewController {
    
    private let viewModel = ChatAdditionalButtonsViewModel()
    
    private var buttonViews: [ChatAdditionalButton] {
        viewModel.buttonModels.map { model in
            let button = ChatAdditionalButton(imageName: model.imageName, titleText: model.titleText, buttonAction: UIAction { _ in model.buttonAction() })
            return button
        }
    }
    
    private lazy var additionalButtonStackView: UIStackView = {
       let additionalButtonStackView = UIStackView(arrangedSubviews: buttonViews)
        additionalButtonStackView.axis = .vertical
        additionalButtonStackView.spacing = 37
        additionalButtonStackView.alignment = .leading
        additionalButtonStackView.translatesAutoresizingMaskIntoConstraints = false

        return additionalButtonStackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        
        setupUI()
    }
    
    //MARK: Setup UI
    private func setupUI() {
        view.addSubview(additionalButtonStackView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            additionalButtonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -80),
            additionalButtonStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
        ])
    }
}
