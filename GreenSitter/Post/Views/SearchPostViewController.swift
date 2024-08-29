//
//  SearchPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/28/24.
//

import UIKit
import Combine

class SearchPostViewController: UIViewController {
    
    private let viewModel: SearchPostViewModel
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
    
    init(posts: [Post]) {
        self.viewModel = SearchPostViewModel(posts: posts)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupTableView()
        bindViewModel()
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
    
    private func performSearch(with searchText: String) {
        viewModel.filterPosts(with: searchText)
    }
}

extension SearchPostViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 2 { // 검색어가 두 글자 이상인 경우 검색 실행
            performSearch(with: searchText)
        } else if searchText.isEmpty {
            performSearch(with: "")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 검색 버튼이 클릭된 경우 키보드 숨김
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 취소 버튼이 클릭된 경우 검색어 비우기 및 키보드 숨김
        searchBar.text = ""
        searchBar.resignFirstResponder()
        performSearch(with: "")
    }
}

//MARK: - TableView

extension SearchPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? PostTableViewCell else {
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
