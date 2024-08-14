//
//  PostTableViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class PostCareProviderTableViewController: UIViewController, UITableViewDataSource {
    
    var careProviderTableView = UITableView(frame: .zero, style: .plain)
    let mockData = [["화분 관리해드려요"], ["몬스테라 관리해드려요"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.careProviderTableView)
        self.careProviderTableView.dataSource = self
        self.careProviderTableView .register(UITableView.self, forCellReuseIdentifier: "CareProviderCell")
        
        self.careProviderTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            careProviderTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            careProviderTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            careProviderTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            careProviderTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mockData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockData[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CareProviderCell", for: indexPath)
        cell.textLabel?.text = mockData[indexPath.section][indexPath.row]
        return cell
    }
}

