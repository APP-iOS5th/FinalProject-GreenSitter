//
//  PostListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import FirebaseFirestore
import UIKit

// MARK: - Custom Cell

class CustomTableViewCell: UITableViewCell {

    // Define custom labels
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.labelsPrimary
        label.numberOfLines = 1
        return label
    }()
    
    private let postBodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.labelsSecondary
        label.numberOfLines = 2
        return label
    }()
    
    // TODO: date time 추가
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add views to content view
        contentView.addSubview(postStatusLabel)
        contentView.addSubview(verticalStackView)
        contentView.addSubview(postImageView)
        
        // Add labels to vertical stack view
        verticalStackView.addArrangedSubview(postTitleLabel)
        verticalStackView.addArrangedSubview(postBodyLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // postStatusLabel constraints
            postStatusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            postStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postStatusLabel.widthAnchor.constraint(equalToConstant: 60),
            postStatusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // verticalStackView constraints
            verticalStackView.topAnchor.constraint(equalTo: postStatusLabel.bottomAnchor, constant: 8),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: postImageView.leadingAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // postImageView constraints
            postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            postImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            postImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postImageView.widthAnchor.constraint(equalToConstant: 80),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure cell with post data
    func configure(with post: Post) {
        postStatusLabel.text = post.postStatus.rawValue
        postTitleLabel.text = post.postTitle
        postBodyLabel.text = post.postBody
        
        guard let postImages = post.postImages, !postImages.isEmpty else {
            postImageView.image = nil
            return
        }
        
        // Set image if available
        if let imageName = postImages.first {
            postImageView.image = UIImage(named: imageName)
        } else {
            postImageView.image = nil
        }
    }
}


class MainPostListViewController: UIViewController {
    
    private let categoryStackView = UIStackView()
    private var filteredPosts: [Post] = []
    private var selectedButton: UIButton?
    
    private let addPostButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus.circle")
        button.setImage(image, for: .normal)
        button.tintColor = .dominent
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchPostButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass")
        button.setImage(image, for: .normal)
        button.tintColor = .labelsPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .bgPrimary
        
        setupCategoryButtons()
        setupNavigationBarButtons()
        setupTableView()
    }
    
    func setupNavigationBarButtons() {
        // Create a menu with actions for each PostType
        let menu = UIMenu(title: "", children: [
            UIAction(title: PostType.offeringToSitter.rawValue, image: UIImage(systemName: "hand.raised.fill")) { [weak self] _ in
                self?.navigateToAddPostViewController(with: .offeringToSitter)
            },
            UIAction(title: PostType.lookingForSitter.rawValue, image: UIImage(systemName: "person.fill")) { [weak self] _ in
                self?.navigateToAddPostViewController(with: .lookingForSitter)
            },
        ])
        
        // Attach the menu to the addPostButton
        addPostButton.menu = menu
        addPostButton.showsMenuAsPrimaryAction = true
        
        // Add the search button as a UIBarButtonItem
        let searchBarButton = UIBarButtonItem(customView: searchPostButton)
        let addBarButton = UIBarButtonItem(customView: addPostButton)
        navigationItem.rightBarButtonItems = [addBarButton, searchBarButton]
        
        // Handle the search action
        let searchPostButtonAction = UIAction { [weak self] _ in
            // TODO: Add search functionality
            print("Search button tapped")
        }
        searchPostButton.addAction(searchPostButtonAction, for: .touchUpInside)
    }
    
    
    func setupCategoryButtons() {
        let careProviderButton = UIButton()
        careProviderButton.setTitle(PostType.offeringToSitter.rawValue, for: .normal)
        careProviderButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        careProviderButton.setTitleColor(.labelsSecondary, for: .normal)
        careProviderButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        let careSeekerButton = UIButton()
        careSeekerButton.setTitle(PostType.lookingForSitter.rawValue, for: .normal)
        careSeekerButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        careSeekerButton.setTitleColor(.labelsSecondary, for: .normal)
        careSeekerButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        categoryStackView.axis = .horizontal
        categoryStackView.distribution = .fillEqually
        categoryStackView.addArrangedSubview(careProviderButton)
        categoryStackView.addArrangedSubview(careSeekerButton)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(categoryStackView)
        
        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        categoryButtonTapped(careProviderButton)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        // 이전에 선택된 버튼의 텍스트 스타일 초기화
        selectedButton?.setTitleColor(.labelsSecondary, for: .normal)
        selectedButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        // 이전에 선택된 버튼에서 이미지 제거
        if let previousButton = selectedButton, let previousImageView = previousButton.viewWithTag(100) as? UIImageView {
            previousImageView.removeFromSuperview()
        }
        
        // 현재 선택된 버튼 텍스트 스타일 적용
        sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        sender.setTitleColor(.complementary, for: .normal)
        selectedButton = sender
        
        // 새로운 이미지 뷰 추가
        let imageView = UIImageView(image: UIImage(named: "postCategoryIcon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tag = 100 // 이미지 뷰를 나중에 제거하기 위해 태그를 지정
        
        // 이미지 뷰를 버튼에 추가
        sender.addSubview(imageView)
        
        // 이미지 뷰 레이아웃 설정 (좌측 상단에 위치)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: sender.leadingAnchor, constant: 15),
            imageView.topAnchor.constraint(equalTo: sender.topAnchor, constant: -25),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 선택된 카테고리로 필터링
        guard let category = sender.titleLabel?.text else { return }
        filterPosts(for: category)
    }
    
    func filterPosts(for category: String) {
        guard let postType = PostType(rawValue: category) else {
            self.filteredPosts = []
            self.tableView.reloadData()
            return
        }

        // Firestore에서 데이터를 가져오기 위한 참조 설정
        let db = Firestore.firestore()
        db.collection("posts")
            .whereField("postType", isEqualTo: postType.rawValue)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error getting documents: \(error)")
                    self.filteredPosts = []
                    self.tableView.reloadData()
                    return
                }

                // Firestore에서 가져온 데이터를 Post 배열로 변환
                self.filteredPosts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Post.self)
                } ?? []

                // 테이블 뷰 리로드
                self.tableView.reloadData()
            }
    }

    
    private func navigateToAddPostViewController(with postType: PostType) {
        let addPostViewController = AddPostViewController(postType: postType, viewModel: AddPostViewModel(postType: postType))
        if let navigationController = self.navigationController {
            navigationController.pushViewController(addPostViewController, animated: true)
        } else {
            print("Navigation controller not found.")
        }
    }
}
    
extension MainPostListViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITABLE VIEW DATA SOURCE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        let post = filteredPosts[indexPath.row]
        
        cell.configure(with: post)
        
        return cell
    }
    
    // MARK: - UITABLE VIEW DELEGATE
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = filteredPosts[indexPath.row]
        let postDetailViewController = PostDetailViewController(post: post)
        postDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(postDetailViewController, animated: true)
    }

}
