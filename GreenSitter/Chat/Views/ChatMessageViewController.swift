//
//  ChatMessageViewController.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/14/24.
//

import UIKit

class ChatMessageViewController: UIViewController {
    // 메세지 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        // 셀 구분선 제거
        tableView.separatorStyle = .none
        // 셀 선택 불가능하게 설정
        tableView.allowsSelection = false
//        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .bgSecondary

        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }

}

//extension ChatMessageViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//    }
//}

extension ChatMessageViewController: UITableViewDelegate {
    
}
