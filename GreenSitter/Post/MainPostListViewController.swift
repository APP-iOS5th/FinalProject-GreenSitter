//
//  PostListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class MainPostListViewController: UIViewController, UITableViewDataSource {
    
    private let categoryStackView = UIStackView()
    private var filteredPosts: [String] = []
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
        setupAddPostButton()
        setupSearchPostButton()
        setupTableView()
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
            categoryStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        categoryButtonTapped(careProviderButton)
    }
    
    func setupSearchPostButton() {
        view.addSubview(searchPostButton)
        
        let searchPostButtonAction = UIAction {[weak self] _ in
            print("searchPostButton Tapped")
        }
        
        searchPostButton.addAction(searchPostButtonAction, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            searchPostButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            searchPostButton.widthAnchor.constraint(equalToConstant: 40),
            searchPostButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupAddPostButton() {
        view.addSubview(addPostButton)
        
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
        
        NSLayoutConstraint.activate([
            addPostButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addPostButton.widthAnchor.constraint(equalToConstant: 40),
            addPostButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    func setupTableView() {
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        selectedButton?.setTitleColor(.labelsPrimary, for: .normal)
        sender.setTitleColor(.complementary, for: .normal)
        selectedButton = sender
        
        guard let category = sender.titleLabel?.text else { return }
        filterPosts(for: category)
    }
    
    func filterPosts(for category: String) {
        if category == "새싹 돌봐드립니다." {
            filteredPosts = ["화분 관리해드려요", "꽃을 주기적으로 관리해드려요"]
        } else if category == "새싹돌봄이를 찾습니다." {
            filteredPosts = ["경비실 화분 관리해주실 분", "출장가는 동안 식물 관리 부탁드려요"]
        } else {
            filteredPosts = []
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = filteredPosts[indexPath.row]
        return cell
    }
}



