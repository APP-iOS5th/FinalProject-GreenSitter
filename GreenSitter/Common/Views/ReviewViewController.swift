//
//  ReviewViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    var selectedRatingButton: UIButton?
    var review: Post?
    var selectedTextButtons: Set<UIButton> = []
    var post: [Post] = []
    var postId: String?
    var creatorId: String?

   

    
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
        tableView.register(ReviewSendTableViewCell.self, forCellReuseIdentifier: "reviewSendTableViewCell")
        
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
        let cell:  UITableViewCell
        let currentPost = post[indexPath.row]
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "reviewPostTableViewCell", for: indexPath) as! ReviewPostTableViewCell
            (cell as! ReviewPostTableViewCell).titleLabel.text = currentPost.postTitle
            (cell as! ReviewPostTableViewCell).bodyLabel.text = currentPost.postBody
            (cell as! ReviewPostTableViewCell).timeLabel.text = DateFormatter.localizedString(from: currentPost.updateDate, dateStyle: .short, timeStyle: .short)
            if let imageURL = currentPost.postImages?.first {
                loadImage(from: imageURL) { image in
                    DispatchQueue.main.async {
                        (cell as! ReviewPostTableViewCell).plantImage.image = image ?? UIImage(named: "logo7")
                    }
                }
            }
            else {
                (cell as! ReviewPostTableViewCell).plantImage.image = UIImage(named: "logo7")
            }

            cell.backgroundColor = UIColor(named: "BGPrimary")
            return cell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "reviewSendTableViewCell", for: indexPath) as! ReviewSendTableViewCell
            (cell as! ReviewSendTableViewCell).badButton.setImage(UIImage(named: "2"), for: .normal)
            (cell as! ReviewSendTableViewCell).badButton.addTarget(self, action: #selector(selectButtonTap), for: .touchUpInside)
            (cell as! ReviewSendTableViewCell).averageButton.setImage(UIImage(named: "3"), for: .normal)
            (cell as! ReviewSendTableViewCell).averageButton.addTarget(self, action: #selector(selectButtonTap), for: .touchUpInside)
            (cell as! ReviewSendTableViewCell).goodButton.setImage(UIImage(named: "4"), for: .normal)
            (cell as! ReviewSendTableViewCell).goodButton.addTarget(self, action: #selector(selectButtonTap), for: .touchUpInside)
            
            (cell as! ReviewSendTableViewCell).row1Button.setTitle("시간 약속을 잘 지켜요!", for: .normal)
            (cell as! ReviewSendTableViewCell).row1Button.addTarget(self, action: #selector(slectTextButtonTap), for: .touchUpInside)
            (cell as! ReviewSendTableViewCell).row2Button.setTitle("의사소통이 원활해요!", for: .normal)
            (cell as! ReviewSendTableViewCell).row2Button.addTarget(self, action: #selector(slectTextButtonTap), for: .touchUpInside)
            (cell as! ReviewSendTableViewCell).row3Button.setTitle("신뢰할 수 있어요!", for: .normal)
            (cell as! ReviewSendTableViewCell).row3Button.addTarget(self, action: #selector(slectTextButtonTap), for: .touchUpInside)
            (cell as! ReviewSendTableViewCell).row4Button.setTitle("매우 친절해요!", for: .normal)
            (cell as! ReviewSendTableViewCell).row4Button.addTarget(self, action: #selector(slectTextButtonTap), for: .touchUpInside)
            
            (cell as! ReviewSendTableViewCell).reviewTextField.placeholder = "직접 입력"
            (cell as! ReviewSendTableViewCell).completeButton.setTitle("완료", for: .normal)
            (cell as! ReviewSendTableViewCell).completeButton.addTarget(self, action: #selector(completeButtonTap), for: .touchUpInside)

            cell.backgroundColor = UIColor(named: "BGSecondary") // 두 번째 섹션 셀 배경색 설정
            return cell
            
        default:
            cell = UITableViewCell()
        }
        return cell
    }
    
    //MARK: - 셀 높이 조정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 600
        }
        else {
            return UITableView.automaticDimension
        }
    }
}
