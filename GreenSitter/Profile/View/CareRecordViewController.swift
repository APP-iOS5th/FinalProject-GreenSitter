//
//  CareRecordViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/19/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CareRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    
    var post: [Post] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CareRecordTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BGSecondary")
        navigationItem.title = "돌봄 기록"
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        fetchPostFirebase()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CareRecordTableViewCell
        let currentPost = post[indexPath.row]
        
        switch currentPost.postStatus {
        case .beforeTrade:
            cell.statusView.backgroundColor = UIColor(named: "DominentColor")
        case .inTrade:
            cell.statusView.backgroundColor = UIColor(named: "DominentColor")
        case .completedTrade:
            cell.statusView.backgroundColor = UIColor(named: "SeparatorsOpaque")
        }
        
        cell.statusLabel.text = currentPost.postStatus.rawValue
        cell.titleLabel.text = currentPost.postTitle
        cell.bodyLabel.text = currentPost.postBody
        cell.timeLabel.text = DateFormatter.localizedString(from: currentPost.updateDate, dateStyle: .short, timeStyle: .short)
        
        if let imageURL = currentPost.postImages?.first {
            loadImage(from: imageURL) { image in
                DispatchQueue.main.async {
                    cell.plantImage.image = image ?? UIImage(named: "logo7")
                }
            }
        } else {
            cell.plantImage.image = UIImage(named: "logo7")
        }
        
        return cell
    }

}
