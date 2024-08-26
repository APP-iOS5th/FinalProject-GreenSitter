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
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .labelsPrimary
        return label
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
        setupLocationLabel()

        fetchPostsByCategoryAndLocationWithViewModel()
        
        setupTableView()
        bindViewModel()
    }
    
    private func fetchPostsByCategoryAndLocationWithViewModel() {
        guard let categoryText = selectedButton?.titleLabel?.text else {
            return
        }
        
        // MARK: - 로그인, 위치정보에 따라 post filter 다르게 적용
        if Auth.auth().currentUser != nil, let userLocation = LoginViewModel.shared.user?.location {
            print("MainPostView - userlocation: \(userLocation)")
            viewModel.fetchPostsByCategoryAndLocation(for: categoryText, userLocation: userLocation)
        } else {    // 비로그인, 혹은 위치 정보 없으면
            print("MainPostView - userlocation: \(String(describing: LoginViewModel.shared.user?.location))")
            viewModel.fetchPostsByCategoryAndLocation(for: categoryText, userLocation: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let categoryText = selectedButton?.titleLabel?.text else {
            return
        }
        
        fetchPostsByCategoryAndLocationWithViewModel()
        setupLocationLabel()

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
        
        let locationBarButton = UIBarButtonItem(customView: locationLabel)
        
        navigationItem.rightBarButtonItems = [addBarButton, searchBarButton]
        navigationItem.leftBarButtonItem = locationBarButton
        
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
    
    private func setupLocationLabel() {
        if let userAddress = LoginViewModel.shared.user?.location.address {
            locationLabel.text = userAddress
        } else {
            locationLabel.text = ""
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
        
        // MARK: - 로그인, 위치정보에 따라 post filter 다르게 적용
        if Auth.auth().currentUser != nil, let userLocation = LoginViewModel.shared.user?.location {
            print("MainPostView - userlocation: \(userLocation)")
            viewModel.fetchPostsByCategoryAndLocation(for: category, userLocation: userLocation)
        } else {    // 비로그인, 혹은 위치 정보 없으면
            print("MainPostView - userlocation: \(String(describing: LoginViewModel.shared.user?.location))")
            viewModel.fetchPostsByCategoryAndLocation(for: category, userLocation: nil)
        }
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
