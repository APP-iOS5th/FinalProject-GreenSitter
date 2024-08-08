//
//  PostListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDataSource {
    
    private let categoryStackView = UIStackView()
    private let tableView = UITableView()
    private var posts: [String] = ["화분 관리해드려요"]
    private var filteredPosts: [String] = []
    private var selectedButton: UIButton?
    
    private let addPostButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus.circle")
        button.setImage(image, for: .normal)
        button.tintColor = .systemGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchPostButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass")
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCategoryButtons()
        setupTableView()
        setupAddPostButton()
        setupSearchPostButton()
        
        filterPosts(for: "새싹 돌봐드립니다.")
    }
    
//    func setupNavigationBar() {
//        // 네비게이션 바 배경 색상 설정
//        navigationController?.navigationBar.barTintColor = .white
//        
//        // 네비게이션 바 타이틀 텍스트 색상 설정
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
//        
//        // 상태 바 스타일 설정
//        navigationController?.navigationBar.barStyle = .default
//        
//        // 플러스 버튼을 네비게이션 바에 추가
//        let addPostButton = UIBarButtonItem(customView: addPostButton)
//        navigationItem.rightBarButtonItem = addPostButton
//        
//        // 플러스 버튼의 타겟 설정
//        setupAddPostButton()
//    }
    
    
    func setupCategoryButtons() {
        let careProviderButton = UIButton()
        careProviderButton.setTitle("새싹 돌봐드립니다.", for: .normal)
        careProviderButton.setTitleColor(.black, for: .normal)
        careProviderButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        let careSeekerButton = UIButton()
        careSeekerButton.setTitle("새싹돌봄이를 찾습니다.", for: .normal)
        careSeekerButton.setTitleColor(.black, for: .normal)
        careSeekerButton.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        categoryButtonTapped(careProviderButton)
        
        categoryStackView.axis = .horizontal
        categoryStackView.distribution = .fillEqually
        categoryStackView.addArrangedSubview(careProviderButton)
        categoryStackView.addArrangedSubview(careSeekerButton)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(categoryStackView)
        
        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    func setupSearchPostButton() {
        view.addSubview(searchPostButton)
        searchPostButton.addTarget(self, action: #selector(searchPostButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            searchPostButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            searchPostButton.widthAnchor.constraint(equalToConstant: 40),
            searchPostButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupAddPostButton() {
        view.addSubview(addPostButton)
        addPostButton.addTarget(self, action: #selector(addPostButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            addPostButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addPostButton.widthAnchor.constraint(equalToConstant: 40),
            addPostButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        selectedButton?.setTitleColor(.black, for: .normal)
        sender.setTitleColor(.systemGreen, for: .normal)
        selectedButton = sender
        
        guard let category = sender.titleLabel?.text else { return }
        filterPosts(for: category)
    }
    
    @objc func addPostButtonTapped() {
        print("Plus button tapped")
    }
    
    @objc func searchPostButtonTapped() {
        print("Search button tapped")
    }
    
    func filterPosts(for category: String) {
        if category == "새싹 돌봐드립니다." {
            filteredPosts = posts.filter { $0.contains("주기적으로") || $0.contains("관리해드려요") }
        } else {
            filteredPosts = posts.filter { !$0.contains("주기적으로") && !$0.contains("관리해드려요") }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = filteredPosts[indexPath.row]
        return cell
    }
    
    
}

#Preview {
    return UINavigationController(rootViewController: PostListViewController())
}

