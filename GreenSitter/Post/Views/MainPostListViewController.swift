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
    
    var postType: [PostType] = []
    
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
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "현재위치에서 등록된 게시물이 아직 없어요."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .labelsSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let additionalStateLabel: UILabel = {
        let label = UILabel()
        label.text = "첫번째로 게시물을 등록해보세요!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        label.textColor = .labelsSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateImageView: UIImageView = {
           let imageView = UIImageView()
           imageView.image = UIImage(named: "traveler")
           imageView.contentMode = .scaleAspectFit
           imageView.translatesAutoresizingMaskIntoConstraints = false
           return imageView
       }()
    
    private let emptyStateStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        setupCategoryButtons()
        setupNavigationBarButtons()
        setupLocationLabel()
        setupTableView()
        setupEmptyStateView()
        bindViewModel()
        fetchPostsByCategoryAndLocationWithViewModel()
    }
    
    private func setupEmptyStateView() {
            // 스택 뷰에 이미지와 라벨을 추가
            emptyStateStackView.addArrangedSubview(emptyStateImageView)
            emptyStateStackView.addArrangedSubview(emptyStateLabel)
            emptyStateStackView.addArrangedSubview(additionalStateLabel)
            
            view.addSubview(emptyStateStackView)
            
            NSLayoutConstraint.activate([
                emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyStateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
                
                emptyStateImageView.widthAnchor.constraint(equalToConstant: 150),
                emptyStateImageView.heightAnchor.constraint(equalToConstant: 150)
            ])
        }
        
        // 게시글이 없을 때는 라벨을 표시하고, 있을 때는 숨김
        private func updateEmptyStateStackView() {
            emptyStateStackView.isHidden = !viewModel.filteredPosts.isEmpty
        }

    
    
    private func fetchPostsByCategoryAndLocationWithViewModel(loadMore: Bool = false) {
        guard let categoryText = selectedButton?.titleLabel?.text else {
            return
        }
        
        if Auth.auth().currentUser != nil, let userLocation = LoginViewModel.shared.user?.location {
            viewModel.fetchPostsByCategoryAndLocation(for: categoryText, userLocation: userLocation, loadMore: loadMore)
        } else { // 비로그인, 혹은 위치 정보 없으면
            viewModel.fetchPostsByCategoryAndLocation(for: categoryText, userLocation: nil, loadMore: loadMore)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard (selectedButton?.titleLabel?.text) != nil else {
            return
        }
        
        
        setupLocationLabel()
        
        fetchPostsByCategoryAndLocationWithViewModel()
//        self.tableView.reloadData()
        
        // 선택된 row 해제
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    private func bindViewModel() {
        viewModel.$filteredPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.tableView.reloadData()
                self?.updateEmptyStateStackView()
            }
            .store(in: &cancellables)
    }
    
    func setupNavigationBarButtons() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: PostType.offeringToSitter.rawValue, image: UIImage(systemName: "hand.raised.fill")) { [weak self] _ in
                self?.handleAddPostButtonTapped(postType: .offeringToSitter)
            },
            UIAction(title: PostType.lookingForSitter.rawValue, image: UIImage(systemName: "person.fill")) { [weak self] _ in
                self?.handleAddPostButtonTapped(postType: .lookingForSitter)
            },
        ])
        
        addPostButton.menu = menu
        addPostButton.showsMenuAsPrimaryAction = true
        
        searchPostButton.addTarget(self, action: #selector(searchPostButtonTapped), for: .touchUpInside)
        

        let searchBarButton = UIBarButtonItem(customView: searchPostButton)
        let addBarButton = UIBarButtonItem(customView: addPostButton)
        let locationBarButton = UIBarButtonItem(customView: locationLabel)
        
        navigationItem.rightBarButtonItems = [addBarButton, searchBarButton]
        navigationItem.leftBarButtonItem = locationBarButton
    }
    
    @objc private func searchPostButtonTapped() {
        let searchPostVC = SearchPostViewController(posts: viewModel.filteredPosts)
        navigationController?.pushViewController(searchPostVC, animated: true)
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
        selectedButton?.setTitleColor(.labelsSecondary, for: .normal)
        selectedButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
      
        if let previousButton = selectedButton, let previousImageView = previousButton.viewWithTag(100) as? UIImageView {
            previousImageView.removeFromSuperview()
        }
    
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
        
//        guard !viewModel.isLoading else { return }
//        fetchPostsByCategoryAndLocationWithViewModel(loadMore: false)
        if Auth.auth().currentUser != nil, let userLocation = LoginViewModel.shared.user?.location {
            viewModel.fetchPostsByCategoryAndLocation(for: category, userLocation: userLocation, loadMore: false)
        } else { // 비로그인, 혹은 위치 정보 없으면
            viewModel.fetchPostsByCategoryAndLocation(for: category, userLocation: nil, loadMore: false)
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
        updateEmptyStateStackView()
        return viewModel.filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! PostTableViewCell
        if let post = viewModel.filteredPosts[safe: indexPath.row] {
            cell.configure(with: post)
        } else {
            cell.configure(with: nil)
        }
        
        
        return cell
    }
    
    // MARK: - UITABLE VIEW DELEGATE
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = viewModel.filteredPosts[indexPath.row]
        let postDetailViewController = PostDetailViewController(postId: post.id)
        navigationController?.pushViewController(postDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.filteredPosts.count - 1 {
            guard !viewModel.filteredPosts.isEmpty else { return }
            loadMorePosts()
        }
    }
    
    private func loadMorePosts() {
        guard let categoryText = selectedButton?.titleLabel?.text else {
            return
        }

        // MARK: - 로그인, 위치정보에 따라 post filter 다르게 적용
        if Auth.auth().currentUser != nil, let userLocation = LoginViewModel.shared.user?.location {
            viewModel.fetchPostsByCategoryAndLocation(for: categoryText, userLocation: userLocation, loadMore: true)
        } else {    // 비로그인, 혹은 위치 정보 없으면
            viewModel.fetchPostsByCategoryAndLocation(for: categoryText, userLocation: nil, loadMore: true)
        }
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
