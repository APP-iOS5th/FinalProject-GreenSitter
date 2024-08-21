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
import Combine

class AboutMeViewController: UIViewController{
    
    let db = Firestore.firestore()
    var user: User?
    var sectionTitle = ["자기소개", "돌봄 정보"]
    let viewModel = LoginViewModel()
    let mapViewModel = MapViewModel()
    var cancellables = Set<AnyCancellable>()

    
    
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
        label.text = user?.nickname
        label.font = UIFont.boldSystemFont(ofSize: 20)
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
        label.text = viewModel.user?.location.address
        label.font = UIFont.boldSystemFont(ofSize: 15)
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
        tableView.register(CustomTableCell.self, forCellReuseIdentifier: "customTableCell")
        
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
            
            tableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        fetchUserFirebase()
        bindViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(self.userAboutMeUpdated), name: NSNotification.Name("UserAboutMeUpdated"), object: nil)

    }
    @objc func userAboutMeUpdated() {
        // 유저 데이터를 다시 불러오기
        fetchUserFirebase()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
