//
//  SearchMapViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import SwiftUI

class SearchMapViewController: UIViewController, UISearchBarDelegate {

    private var locations: [Location] = []
    private var currentPage: Int = 1
    private var isEnd: Bool = false
    private let tableView = UITableView()
    private let placeholderLabel = UILabel()
    
    private let userLocation: Location = {
        guard let location = LoginViewModel.shared.user?.location else {
            return Location.seoulLocation   // location 없으면 서울 시청으로
        }
        return location
    }()
    
    var makePlanViewModel: MakePlanViewModel?
    var addPostViewModel: AddPostViewModel?

    private var searchWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .bgPrimary
        setupNavigationBar()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 선택된 row 해제
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    // MARK: - NAVIGATION BAR
    
    private func setupNavigationBar() {
        // Cancel button
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        // Search bar
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소를 검색하세요"
        searchBar.backgroundColor = .bgPrimary
        searchBar.delegate = self

        navigationItem.titleView = searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.searchPlaces(query: searchText)
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem) // Adjust debounce time as needed
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SETUP UI
    
    private func setupUI() {
        // UITableView 설정
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        // PlaceholderLabel 설정
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        // PlaceholderLabel의 초기 상태 설정
        updatePlaceholder(text: "이웃과 만나서\n새싹을 주고 받을 장소를 선택해주세요!\n\n위치 선정이 어렵다면,\n찾기 쉬운 공공장소는 어떠세요?", isPrimary: true)
        
        // PlaceholderLabel의 위치 설정
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        updateUI()
    }
    
    private func updatePlaceholder(text: String, isPrimary: Bool) {
        let fullText = NSMutableAttributedString(string: text)
        
        // 설정할 기본 속성
        let primaryAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isPrimary ? UIColor.labelsPrimary : UIColor.labelsSecondary,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        
        let grayAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.labelsSecondary,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        
        // 텍스트를 부분적으로 나누어 적용
        let grayTextRange = (text as NSString).range(of: "위치 선정이 어렵다면,\n찾기 쉬운 공공장소는 어떠세요?")
        
        fullText.addAttributes(primaryAttributes, range: NSRange(location: 0, length: text.count)) // 전체에 기본 속성 적용
        fullText.addAttributes(grayAttributes, range: grayTextRange) // 회색 텍스트 부분만 회색으로 설정
        
        placeholderLabel.attributedText = fullText
    }

    
    private func updateUI() {
        if locations.isEmpty {
            tableView.isHidden = true
            placeholderLabel.isHidden = false
        } else {
            tableView.isHidden = false
            placeholderLabel.isHidden = true
            tableView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchPlaces(query: query)
    }

    private func searchPlaces(query: String) {
        
        guard !query.isEmpty else {
            locations.removeAll()
            updateUI()
            return
        }
        
        // 초기화
        locations.removeAll()
        currentPage = 1
        isEnd = false
//        updatePlaceholder(text: "검색 중...", isPrimary: false)
        updateUI()


        KakaoAPIService.shared.searchPlacesNearby(query: query, location: self.userLocation, page: currentPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (newLocations, isEnd)):
                self.locations.append(contentsOf: newLocations)
                self.isEnd = isEnd
                DispatchQueue.main.async {
                    if self.locations.isEmpty {
                        self.updatePlaceholder(text: "검색 결과가 없습니다.", isPrimary: false)
                    }
                    self.updateUI()
                }
            case .failure(let error):
                print("Error occurred: \(error)")
                self.locations = []
                DispatchQueue.main.async {
                    self.updatePlaceholder(text: "검색 결과가 없습니다.", isPrimary: false)
                    self.updateUI()
                }
            }
        }
    }

    private func loadMorePlaces(query: String) {
        // isEnd 가 true인 경우, Last Page 이므로 종료
        guard !isEnd else {
            print("Last Page: \(currentPage), \(isEnd)")
            return
        }
        currentPage += 1

        KakaoAPIService.shared.searchPlacesNearby(query: query, location: self.userLocation, page: currentPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (newLocations, isEnd)):
                self.locations.append(contentsOf: newLocations)
                self.isEnd = isEnd
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error occurred: \(error)")
            }
        }
    }
}


extension SearchMapViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITABLEVIEW DATASOURCE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let location = locations[indexPath.row]
        
        // 대체 텍스트 설정
        let placeName = location.placeName.isEmpty ? "이름 없음" : location.placeName
        let address = location.address.isEmpty ? "주소 없음" : location.address
        
        // 셀의 텍스트 설정
        cell.textLabel?.numberOfLines = 0
        
        // attributedText 설정
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.labelsPrimary,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.labelsSecondary,
            .font: UIFont.preferredFont(forTextStyle: .subheadline)
        ]
        
        let attributedText = NSMutableAttributedString(string: placeName + "\n", attributes: titleAttributes)
        attributedText.append(NSAttributedString(string: address, attributes: subtitleAttributes))
        
        cell.textLabel?.attributedText = attributedText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = locations[indexPath.row]
        if let makePlanViewModel = self.makePlanViewModel {
            let detailViewController = SearchMapDetailViewController(location: selectedLocation, makePlanViewModel: makePlanViewModel)
            let navigationController = UINavigationController(rootViewController: detailViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true, completion: nil)
        } else if let addPostViewModel = self.addPostViewModel {
            let detailViewController = SearchMapDetailViewController(location: selectedLocation, addPostViewModel: addPostViewModel)
            let navigationController = UINavigationController(rootViewController: detailViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true, completion: nil)
        } else {
            let detailViewController = SearchMapDetailViewController(location: selectedLocation)
            let navigationController = UINavigationController(rootViewController: detailViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true, completion: nil)
        }
        
    }

    // MARK: - UITABLEVIEW DELEGATE

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == locations.count - 1 { // 마지막 셀에 도달했을 때
            guard let query = (navigationItem.titleView as? UISearchBar)?.text else { return }
            loadMorePlaces(query: query)
        }
    }
    
}


// MARK: - PREVIEWS

struct SearchMapViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = SearchMapViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

#Preview {
    SearchMapViewControllerPreview()
}
