//
//  ReceiveReviewViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/21/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ReceiveReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    var selectedRatingButton: UIButton?
    var review: Post?
    var selectedTextButtons: Set<UIButton> = []
    var post: Post?
    var postId: String?
    var reviews: Review?
    
    var selectedTexts: [String] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "BGSecondary")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "돌봄 후기"
        tableView.register(ReviewPostTableViewCell.self, forCellReuseIdentifier: "reviewPostTableViewCell")
        tableView.register(ReceiveReviewTableViewCell.self, forCellReuseIdentifier: "receiveReviewTableViewCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        fetchPostFirebase()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewPostTableViewCell", for: indexPath) as! ReviewPostTableViewCell
            if let post = post {
                cell.titleLabel.text = post.postTitle
                cell.bodyLabel.text = post.postBody
                cell.timeLabel.text = DateFormatter.localizedString(from: post.updateDate, dateStyle: .short, timeStyle: .short)
                cell.plantImage.image = UIImage(named: "logo7")
            } else {
                cell.titleLabel.text = "데이터 없음"
                cell.bodyLabel.text = "데이터 없음"
                cell.timeLabel.text = "데이터 없음"
                cell.plantImage.image = nil
            }
            cell.backgroundColor = UIColor.white
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiveReviewTableViewCell", for: indexPath) as! ReceiveReviewTableViewCell
            cell.badButton.setImage(UIImage(named: "2"), for: .normal)
            cell.averageButton.setImage(UIImage(named: "3"), for: .normal)
            cell.goodButton.setImage(UIImage(named: "4"), for: .normal)
            
            cell.row1Button.setTitle("시간 약속을 잘 지켜요!", for: .normal)
            cell.row2Button.setTitle("의사소통이 원활해요!", for: .normal)
            cell.row3Button.setTitle("신뢰할 수 있어요!", for: .normal)
            cell.row4Button.setTitle("매우 친절해요!", for: .normal)
            
            cell.reviewTextField.placeholder = reviews?.reviewText
            cell.backgroundColor = UIColor(named: "BGSecondary")
            
            // Update button colors based on selectedTexts
            self.updateButtonColors(selectedTexts: self.selectedTexts)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    //MARK: - 셀 높이 조정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 600
        } else {
            return UITableView.automaticDimension
        }
    }
}
