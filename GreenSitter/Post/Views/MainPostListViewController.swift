//
//  PostListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Combine
import UIKit
import FirebaseAuth

class MainPostListViewController: UIViewController {
    
    private let categoryStackView = UIStackView()
    private var selectedButton: UIButton?
    private let viewModel = MainPostListViewModel()
    private var cancellables = Set<AnyCancellable>()

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
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 선택된 row 해제
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    private func bindViewModel() {
        viewModel.$filteredPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                print("MainView - bindViewModel posts: \(posts)")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func setupNavigationBarButtons() {
        // Create a menu with actions for each PostType
        let menu = UIMenu(title: "", children: [
            UIAction(title: PostType.offeringToSitter.rawValue, image: UIImage(systemName: "hand.raised.fill")) { [weak self] _ in
                self?.handleAddPostButtonTapped(postType: .offeringToSitter)
            },
            UIAction(title: PostType.lookingForSitter.rawValue, image: UIImage(systemName: "person.fill")) { [weak self] _ in
                self?.handleAddPostButtonTapped(postType: .lookingForSitter)
            },
        ])
        
        // Attach the menu to the addPostButton
        addPostButton.menu = menu
        addPostButton.showsMenuAsPrimaryAction = true
        
        // Add the search button as a UIBarButtonItem
        let searchBarButton = UIBarButtonItem(customView: searchPostButton)
        let addBarButton = UIBarButtonItem(customView: addPostButton)
        navigationItem.rightBarButtonItems = [addBarButton, searchBarButton]
        
        // TODO: post 검색 기능
        let searchPostButtonAction = UIAction { [weak self] _ in
            // TODO: Add search functionality
            print("Search button tapped")
        }
        searchPostButton.addAction(searchPostButtonAction, for: .touchUpInside)
    }
    
    private func handleAddPostButtonTapped(postType: PostType) {
        if Auth.auth().currentUser != nil {
            navigateToAddPostViewController(with: postType)
        } else {
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 3
            }
        }
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
            
            
            let addPostViewController = AddPostViewController(postType: .lookingForSitter, viewModel: AddPostViewModel(postType: .lookingForSitter))
            
            
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
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "CustomCell")
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
        viewModel.fetchPostsByCategory(for: category)
    }
    
    private func navigateToAddPostViewController(with postType: PostType) {
        let addPostViewController = AddPostViewController(postType: postType, viewModel: AddPostViewModel(postType: postType))
        addPostViewController.hidesBottomBarWhenPushed = true
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
        return viewModel.filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! PostTableViewCell
        let post = viewModel.filteredPosts[indexPath.row]

        cell.configure(with: post)
        
        return cell
    }
    
    // MARK: - UITABLE VIEW DELEGATE
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = viewModel.filteredPosts[indexPath.row]
        let postDetailViewController = PostDetailViewController(post: post)
        postDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(postDetailViewController, animated: true)
    }

}
