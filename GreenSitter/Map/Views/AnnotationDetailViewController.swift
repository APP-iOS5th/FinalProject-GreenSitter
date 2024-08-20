//
//  AnnotationDetailViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/12/24.
//

import UIKit

// MARK: - Delegate Protocol

protocol AnnotationDetailViewControllerDelegate: AnyObject {
    func annotationDetailViewControllerDidDismiss(_ controller: AnnotationDetailViewController)
}

class AnnotationDetailViewController: UIViewController {
    var post: Post?
    weak var delegate: AnnotationDetailViewControllerDelegate?

    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .bgPrimary
        setupUI()
        configure(with: post)
    }

    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func configure(with post: Post?) {
        guard let post = post else { return }
        titleLabel.text = post.postTitle
        bodyLabel.text = post.postBody
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.annotationDetailViewControllerDidDismiss(self)
    }
}
