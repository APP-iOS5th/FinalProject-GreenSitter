//
//  SearchPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/28/24.
//

import UIKit
import Combine

class SearchPostViewController: UIViewController {
    
    private let viewModel = SearchPostViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색어를 입력하세요"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupTableView()
        bindViewModel()
        loadPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(tableView)
        searchBar.delegate = self
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "CustomCell")
    }
    
    private func bindViewModel() {
        viewModel.$filteredPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                print("Received posts: \(posts.count)")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func loadPosts() {
        let allCategories = "all"
        if let userLocation = LoginViewModel.shared.user?.location {
            print("Loading posts with user location")
            viewModel.fetchPostsByCategoryAndLocation(for: allCategories, userLocation: String())
        } else {
            print("Loading posts without user location")
            viewModel.fetchPostsByCategoryAndLocation(for: allCategories, userLocation: nil)
        }
    }
    
    private func performSearch(with searchText: String) {
        print("Performing search with: \(searchText)")
        viewModel.filterPosts(with: searchText)
    }
}

extension SearchPostViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        performSearch(with: "")
    }
    
    private func fetchPostsByCategoryAndLocation(for category: String, userLocation: String?) -> [Post] {
        // 실제 네트워크 요청이나 데이터베이스 쿼리 등을 통해 게시글을 가져오는 로직
        // 예시 데이터 반환
        return []
    }
}

extension SearchPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in table view: \(viewModel.filteredPosts.count)")
        return viewModel.filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? PostTableViewCell else {
            print("Failed to dequeue PostTableViewCell")
            return UITableViewCell()
        }
        let post = viewModel.filteredPosts[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = viewModel.filteredPosts[indexPath.row]
        let postDetailViewController = PostDetailViewController(postId: selectedPost.id)
        postDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
