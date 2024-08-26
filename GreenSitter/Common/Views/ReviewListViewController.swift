//
//  ReviewListViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ReviewListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let db = Firestore.firestore()
    var post: [Post] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CareRecordTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor(named: "BGSecondary")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "돌봄 후기"
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 포스트 가져오기
        let selectedPost = post[indexPath.row]
        
        let currentDate = Date()
        let postUpdateDate = selectedPost.updateDate
        let calendar = Calendar.current
        
        //업데이트한 날짜로부터 3일이 지나면 리뷰를 쓸수 없음
        if let daysDifference = calendar.dateComponents([.day], from: postUpdateDate, to: currentDate).day, daysDifference <= 3 {
            let reviewViewController = ReviewViewController()
            reviewViewController.post = selectedPost
            reviewViewController.postId = selectedPost.id
            navigationController?.pushViewController(reviewViewController, animated: true)
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CareRecordTableViewCell
        let currentPost = post[indexPath.row]
        
        cell.statusView.backgroundColor = UIColor(named: "SeparatorsOpaque")
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
