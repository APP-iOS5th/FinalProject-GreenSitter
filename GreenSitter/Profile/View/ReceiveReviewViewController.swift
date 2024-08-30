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
    var post: [Post] = []
    var postId: String
    var reviews: Review?
    var selectedTexts: [String] = []
    
    let row1Button = UIButton()
    let row2Button = UIButton()
    let row3Button = UIButton()
    let row4Button = UIButton()
    
    init(postId: String) {
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        fetchReviewFirebase()
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
            // post 배열이 비어있지 않은지 확인 후 접근
            guard !post.isEmpty else { return UITableViewCell() }
            let currentPost = post[0] // post는 하나의 요소만 포함하므로 인덱스는 항상 0
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewPostTableViewCell", for: indexPath) as! ReviewPostTableViewCell

            cell.titleLabel.text = currentPost.postTitle
            cell.bodyLabel.text = currentPost.postBody
            cell.timeLabel.text = DateFormatter.localizedString(from: currentPost.updateDate, dateStyle: .short, timeStyle: .short)
            if let imageURL = currentPost.postImages?.first {
                postLoadImage(from: imageURL) { image in
                    DispatchQueue.main.async {
                        cell.plantImage.image = image ?? UIImage(named: "logo7")
                    }
                }
            } else {
                cell.plantImage.image = UIImage(named: "logo7")
            }

            cell.backgroundColor = UIColor.white
            return cell

        case 1:
            // 리뷰가 있는 경우에만 접근
            guard reviews != nil else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiveReviewTableViewCell", for: indexPath) as! ReceiveReviewTableViewCell
            cell.badButton.setImage(UIImage(named: "2"), for: .normal)
            cell.averageButton.setImage(UIImage(named: "3"), for: .normal)
            cell.goodButton.setImage(UIImage(named: "4"), for: .normal)
            // 버튼 제목 설정
            cell.row1Button.setTitle("시간 약속을 잘 지켜요!", for: .normal)
            cell.row2Button.setTitle("의사소통이 원활해요!", for: .normal)
            cell.row3Button.setTitle("신뢰할 수 있어요!", for: .normal)
            cell.row4Button.setTitle("매우 친절해요!", for: .normal)
            
            // 리뷰 텍스트 설정
            cell.reviewTextField.placeholder = reviews?.reviewText
            
            // 버튼 배경색 설정
            let buttons = [cell.row1Button, cell.row2Button, cell.row3Button, cell.row4Button]
            let buttonTitles = [
                cell.row1Button.title(for: .normal),
                cell.row2Button.title(for: .normal),
                cell.row3Button.title(for: .normal),
                cell.row4Button.title(for: .normal)
            ]
            
            for (button, title) in zip(buttons, buttonTitles) {
                if let title = title, self.selectedTexts.contains(title) {
                    button.backgroundColor = UIColor(named: "ComplementaryColor")
                } else {
                    button.backgroundColor = UIColor.white
                }
            }
            let borderColor = UIColor(named: "ComplementaryColor")?.cgColor
            switch reviews?.rating {
            case .bad:
                cell.badButton.layer.borderColor = borderColor
                cell.badButton.layer.borderWidth = 2
            case .average:
                cell.averageButton.layer.borderColor = borderColor
                cell.averageButton.layer.borderWidth = 2
            case .good:
                cell.goodButton.layer.borderColor = borderColor
                cell.goodButton.layer.borderWidth = 2
            default:
                cell.badButton.layer.borderColor = UIColor.clear.cgColor
                cell.averageButton.layer.borderColor = UIColor.clear.cgColor
                cell.goodButton.layer.borderColor = UIColor.clear.cgColor
            }
            
            cell.reviewTextField.placeholder = reviews?.reviewText ?? "리뷰 없음"
            cell.backgroundColor = UIColor(named: "BGSecondary")
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
