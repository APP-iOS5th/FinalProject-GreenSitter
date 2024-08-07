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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCategoryButtons()
        setupTableView()
        
        filterPosts(for: "새싹 돌봐드립니다.")
    }
    
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
            categoryStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryStackView.heightAnchor.constraint(equalToConstant: 50)
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
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        selectedButton?.setTitleColor(.black, for: .normal)
        sender.setTitleColor(.systemGreen, for: .normal)
        selectedButton = sender
        
        guard let category = sender.titleLabel?.text else { return }
        filterPosts(for: category)
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

