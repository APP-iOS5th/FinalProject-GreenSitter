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
    private var post: Post
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: AnnotationDetailViewControllerDelegate?
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .labelsTertiary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let postStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .dominent
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.labelsPrimary
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let postButton: UIButton = {
        let button = UIButton()
        button.setTitle("자세히 보기", for: .normal)
        button.backgroundColor = .complementary
        button.layer.cornerRadius = 4
        button.tintColor = .white
        return button
    }()
    
    private let postBodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.labelsSecondary
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .labelsSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4  // 일관된 간격 설정
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPrimary
        setupUI()
        updateUI()
    }

    private func setupUI() {
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        view.addSubview(closeButton)
        view.addSubview(postStatusLabel)
        view.addSubview(verticalStackView)
        view.addSubview(postImageView)
        view.addSubview(descriptionLabel)
        
        verticalStackView.addArrangedSubview(postTitleLabel)
        verticalStackView.addArrangedSubview(postBodyLabel)
        verticalStackView.addArrangedSubview(postButton)
        
        // 전체 뷰 높이 제약 조건 설정
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        NSLayoutConstraint.activate([
            // Close button constraints
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            // postStatusLabel constraints
            postStatusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            postStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            postStatusLabel.widthAnchor.constraint(equalToConstant: 60),
            postStatusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // verticalStackView constraints
            verticalStackView.topAnchor.constraint(equalTo: postStatusLabel.bottomAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: postImageView.leadingAnchor, constant: -16),
            
            // postImageView constraints
            postImageView.topAnchor.constraint(equalTo: verticalStackView.topAnchor, constant: 0),
            postImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            postImageView.widthAnchor.constraint(equalToConstant: 80),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),
            
            // descriptionLabel constraints
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    @objc private func didTapCloseButton() {
        delegate?.annotationDetailViewControllerDidDismiss(self)
    }

    @objc private func didTapPostButton() {
        let postDetailViewController = PostDetailViewController(postId: post.id)
        navigationController?.pushViewController(postDetailViewController, animated: true)
        delegate?.annotationDetailViewControllerDidDismiss(self)
    }
    
    func updatePost(_ post: Post) {
        self.post = post
        updateUI()
    }

    private func updateUI() {
        // Update UI with post data
        postStatusLabel.text = post.postStatus.rawValue
        postTitleLabel.text = post.postTitle
        postBodyLabel.text = post.postBody
        
        if let imageUrlString = post.postImages?.first, let imageUrl = URL(string: imageUrlString) {
            print("Post Image is: \(imageUrlString)")
            loadImage(from: imageUrl)
        } else {
            print("Post Image is nil")
            postImageView.image = UIImage(systemName: "photo")
        }
        
        descriptionLabel.text = "이 위치는 500m 반경 이내의 지역이 표시됩니다."
    }
    
    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.postImageView.image = nil
                }
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.postImageView.image = image
            }
        }
        task.resume()
    }
}


#Preview {
    AnnotationDetailViewController(post: Post.samplePosts.first!)
}
