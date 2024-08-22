//
//  AnnotationDetailViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/12/24.
//

import UIKit


protocol AnnotationDetailViewControllerDelegate: AnyObject {
    func annotationDetailViewControllerDidDismiss(_ controller: AnnotationDetailViewController)
}

class AnnotationDetailViewController: UIViewController {
    var post: Post?
    weak var delegate: AnnotationDetailViewControllerDelegate?
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        ])
    }
    
    @objc private func didTapCloseButton() {
        delegate?.annotationDetailViewControllerDidDismiss(self)
    }
    
    func updatePost(_ post: Post) {
        self.post = post
        // TODO: View 업데이트
    }
}
