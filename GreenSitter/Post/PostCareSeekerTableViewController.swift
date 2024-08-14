//
//  PostCareSeekerTableViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/9/24.
//


import UIKit

class PostCareSeekerTableViewController: UIViewController, UITableViewDataSource {
    
    var careSeekerTableView = UITableView(frame: .zero, style: .plain)
    let mockData = [["경비실 화분 관리해주실 분"],
                    ["출장가는 동안 식물 관리 부탁드려요"],
                    ["provider111"],
                    ["provider222"],
                    ["provider3333"],
                    ["provider4444"],
                    ["provider5555"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.careSeekerTableView)
        self.careSeekerTableView.dataSource = self
        self.careSeekerTableView.register(UITableView.self, forCellReuseIdentifier: "CareSeekerCell")
        
        self.careSeekerTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            careSeekerTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            careSeekerTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            careSeekerTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            careSeekerTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        print(mockData)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mockData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CareSeekerCell", for: indexPath)
        cell.textLabel?.text = mockData[indexPath.section][indexPath.row]
        return cell
    }
}



