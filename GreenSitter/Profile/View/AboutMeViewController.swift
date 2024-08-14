//
//  AboutMeViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AboutMeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    var user: User?
    var sectionTitle = ["자기소개", "돌봄 정보", "돌봄 신청 정보", "시스템", "이용약관 및 개인정보 처리방침"]
    
    lazy var profileImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "로고7")
        image.layer.cornerRadius = 60
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SeparatorsOpaque")
        view.layer.cornerRadius = 70
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var levelView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "DominentColor")
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var levelLabel: UILabel = {
        let label = UILabel()
        label.text = "새싹 단계"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = /*UIColor(named: "LabelsPrimary")*/ .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var levelIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "leaf.fill")
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "지용"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = UIColor(named: "LabelsPrimary")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "경기도 양주시"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "SeparatorsOpaque")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "BGSecondary")
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGSecondary")
        navigationItem.title = "내 프로필"
        
        tableView.register(IntroductionTableCell.self, forCellReuseIdentifier: "introductionTableCell")
        tableView.register(CustomTableCell.self, forCellReuseIdentifier: "customTableCell" )
        tableView.register(InformationTableCell.self, forCellReuseIdentifier: "informationTableCell" )
        
        
        view.addSubview(circleView)
        view.addSubview(profileImage)
        view.addSubview(levelView)
        levelView.addSubview(levelIcon) // levelIcon을 levelView의 서브뷰로 추가
        levelView.addSubview(levelLabel) // levelLabel을 levelView의 서브뷰로 추가
        view.addSubview(nicknameLabel)
        view.addSubview(separatorLine)
        view.addSubview(locationLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            circleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            circleView.widthAnchor.constraint(equalToConstant: 140),
            circleView.heightAnchor.constraint(equalToConstant: 140),
            
            profileImage.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            profileImage.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 120),
            profileImage.heightAnchor.constraint(equalToConstant: 120),
            
            levelView.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 40),
            levelView.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 10),
            levelView.widthAnchor.constraint(equalToConstant: 120),
            levelView.heightAnchor.constraint(equalToConstant: 30),
            
            levelIcon.leadingAnchor.constraint(equalTo: levelView.leadingAnchor, constant: 10),
            levelIcon.centerYAnchor.constraint(equalTo: levelView.centerYAnchor),
            levelIcon.widthAnchor.constraint(equalToConstant: 20),
            levelIcon.heightAnchor.constraint(equalToConstant: 20),
            
            levelLabel.leadingAnchor.constraint(equalTo: levelIcon.trailingAnchor, constant: 10),
            levelLabel.centerYAnchor.constraint(equalTo: levelView.centerYAnchor),
            levelLabel.trailingAnchor.constraint(equalTo: levelView.trailingAnchor, constant: -10),
            
            nicknameLabel.topAnchor.constraint(equalTo: levelView.bottomAnchor, constant: 10),
            nicknameLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 50),
            nicknameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            separatorLine.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 50),
            separatorLine.widthAnchor.constraint(equalToConstant: 150), // 선의 길이
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            locationLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            locationLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 50),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            tableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    //MARK: - 섹션의 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    //MARK: - 섹션의 행수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 4
        default:
            return 0
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "introductionTableCell", for: indexPath) as! IntroductionTableCell
            (cell as! IntroductionTableCell).bodyLabel.text = "자기소개"
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "heart.fill")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 후기"
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.clipboard.fill")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 기록"
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "leaf.fill")
                (cell as! CustomTableCell).textsLabel.text = "내가 맡긴 식물"
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.rectangle.fill")
                (cell as! CustomTableCell).textsLabel.text = "내가 쓴 돌봄 후기"
            }
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "heart.fill")
                (cell as! CustomTableCell).iconImage.tintColor = .systemRed
                (cell as! CustomTableCell).textsLabel.text = "회원 탈퇴"
                (cell as! CustomTableCell).textsLabel.textColor = .systemRed
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.clipboard.fill")
                (cell as! CustomTableCell).iconImage.tintColor = .systemBlue
                (cell as! CustomTableCell).textsLabel.text = "로그아웃"
                (cell as! CustomTableCell).textsLabel.textColor = .systemBlue
            }
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "informationTableCell", for: indexPath) as! InformationTableCell
            switch indexPath.row {
            case 0:
                (cell as! InformationTableCell).infoLabel.text = "서비스 이용약관"
            case 1:
                (cell as! InformationTableCell).infoLabel.text = "개인정보 처리 방침"
            case 2:
                (cell as! InformationTableCell).infoLabel.text = "비즈니스 개인정보 처리방침"
            case 3:
                (cell as! InformationTableCell).infoLabel.text = "위치기반서비스 이용약관"
            default:
                (cell as! InformationTableCell).infoLabel.text = ""
            }
        default:
            cell = UITableViewCell()
        }
        
        // 셀의 모서리와 테두리 설정
        configureCellAppearance(cell, at: indexPath, in: tableView)
        
        return cell
    }

    
    func configureCellAppearance(_ cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        let cornerRadius: CGFloat = 10.0
        var maskedCorners: CACornerMask = []
        
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isFirstRow && isLastRow {
            // 첫 번째와 마지막 셀의 모서리만 둥글게
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstRow {
            // 첫 번째 셀의 상단 모서리만 둥글게
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            // 마지막 셀의 하단 모서리만 둥글게
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        // 셀의 외관 설정
        cell.contentView.layer.cornerRadius = cornerRadius
        cell.contentView.layer.maskedCorners = maskedCorners
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.backgroundColor = .white
    }

    
    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                print("Document data: \(data)") // Firestore에서 가져온 데이터 출력
            } else {
                print("Document does not exist")
            }
        }
    }
}
