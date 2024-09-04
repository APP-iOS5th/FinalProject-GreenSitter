//
//  ReceiveReviewViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/21/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
#if DEBUG
import SwiftUI

class ReceiveReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    var selectedRatingButton: UIButton?
    var review: Post?
    var selectedTextButtons: Set<UIButton> = []
    var post: [Post] = []
    var postId: String
    var reviews: Review?
    var selectedTexts: [String] = []
    var fetchedPostIds = Set<String>()

    
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "돌봄 후기"
        view.backgroundColor = UIColor(named: "BGSecondary")
        tableView.backgroundColor = UIColor(named: "BGSecondary")
        
//        tableView.register(ReviewPostTableViewCell.self, forCellReuseIdentifier: "reviewPostTableViewCell")
        tableView.register(ReceiveReviewTableViewCell.self, forCellReuseIdentifier: "receiveReviewTableViewCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        fetchPostFirebase()
        fetchReviewFirebase()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // 리뷰가 있는 경우에만 접근
//            guard reviews != nil else { return UITableViewCell() }
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
            cell.reviewTextField.isUserInteractionEnabled = false
            
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

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000 // 원하는 셀 높이
    }
}


struct ReceiveReviewViewController_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock postId for preview purposes
        let mockPostId = "mockPostId"

        // Wrap your UIViewController in a UIHostingController
        UIViewControllerPreview(viewController: ReceiveReviewViewController(postId: mockPostId))
            .previewLayout(.fixed(width: 375, height: 667)) // Set a preview size that fits your design
    }
}

struct UIViewControllerPreview: UIViewControllerRepresentable {
    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif

