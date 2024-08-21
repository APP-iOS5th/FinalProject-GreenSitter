//
//  PostListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

// MARK: - Custom Cell

class CustomTableViewCell: UITableViewCell {
    
    // Define custom labels
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.labelsPrimary
        return label
    }()
    
    private let postBodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.labelsSecondary
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add custom labels to the content view
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postBodyLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            postTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            postBodyLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 4),
            postBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postBodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure cell with post data
    func configure(with post: Post) {
        postTitleLabel.text = post.postTitle
        postBodyLabel.text = post.postBody
        imageView?.image = UIImage(named: post.profileImage)
    }
}

class MainPostListViewController: UIViewController, UITableViewDataSource {
    
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
//        setupAddPostButton()
//        setupSearchPostButton()
        setupTableView()
    }
    
    func setupNavigationBarButtons() {
        let searchBarButton = UIBarButtonItem(customView: searchPostButton)
        let addBarButton = UIBarButtonItem(customView: addPostButton)
        navigationItem.rightBarButtonItems = [addBarButton, searchBarButton]
        
        let addPostButtonAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            let addPostViewController = AddPostViewController()
            if let navigationController = self.navigationController {
                navigationController.pushViewController(addPostViewController, animated: true)
            } else {
                print("Navigation controller not found.")
            }
        }
        addPostButton.addAction(addPostButtonAction, for: .touchUpInside)
        
        let searchPostButtonAction = UIAction { [weak self] _ in
            // TODO: 검색버튼 액션 추가
            print("searchPostButton Tapped")
        }
        searchPostButton.addAction(searchPostButtonAction, for: .touchUpInside)
    }
    
    func setupCategoryButtons() {
        let careProviderButton = UIButton()
        careProviderButton.setTitle(PostType.offeringToSitter.rawValue, for: .normal)
        careProviderButton.setTitleColor(.labelsPrimary, for: .normal)
        careProviderButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        let careSeekerButton = UIButton()
        careSeekerButton.setTitle(PostType.lookingForSitter.rawValue, for: .normal)
        careSeekerButton.setTitleColor(.labelsPrimary, for: .normal)
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
    
//    func setupSearchPostButton() {
//        view.addSubview(searchPostButton)
//        
//        let searchPostButtonAction = UIAction { [weak self] _ in
//
//            print("searchPostButton Tapped")
//        }
//        
//        searchPostButton.addAction(searchPostButtonAction, for: .touchUpInside)
//        
//        NSLayoutConstraint.activate([
//            searchPostButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            searchPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//            searchPostButton.widthAnchor.constraint(equalToConstant: 40),
//            searchPostButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//    
//
//    
//    func setupAddPostButton() {
//        view.addSubview(addPostButton)
//        
//        let addPostButtonAction = UIAction { [weak self] _ in
//            guard let self = self else { return }
//            
//            let addPostViewController = AddPostViewController()
//            
//            if let navigationController = self.navigationController {
//                navigationController.pushViewController(addPostViewController, animated: true)
//            } else {
//                print("Navigation controller not found.")
//            }
//        }
//        
//        addPostButton.addAction(addPostButtonAction, for: .touchUpInside)
//        
//        NSLayoutConstraint.activate([
//            addPostButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            addPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            addPostButton.widthAnchor.constraint(equalToConstant: 40),
//            addPostButton.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
    
    
    func setupTableView() {
        tableView.dataSource = self
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
        selectedButton?.setTitleColor(.labelsPrimary, for: .normal)
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
        let imageView = UIImageView(image: UIImage(named: "postCategoryIcon")) // 여기에 이미지 이름을 넣으세요
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
            filteredPosts = []
            tableView.reloadData()
            return
        }
        
        filteredPosts = Post.samplePosts.filter { $0.postType == postType }
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        let post = filteredPosts[indexPath.row]
        
        cell.configure(with: post)
        
        return cell
    }
}



