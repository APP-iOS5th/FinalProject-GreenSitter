//
//  ProfileViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SeparatorsOpaque")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 60
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var imageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "로고7"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 50
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 프로필 보기", for: .normal)
        button.setTitleColor(UIColor(named: "LabelsPrimary"), for: .normal)
        button.backgroundColor = UIColor(named: "BGSecondary")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var sectionTitle = ["내 정보", "계정"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "SeparatorsOpaque")
        navigationItem.title = "프로필"

        view.addSubview(circleView)
        view.addSubview(imageButton)
        view.addSubview(profileButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 180),
            circleView.widthAnchor.constraint(equalToConstant: 120),
            circleView.heightAnchor.constraint(equalToConstant: 120),

            imageButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            imageButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            imageButton.widthAnchor.constraint(equalToConstant: 100),
            imageButton.heightAnchor.constraint(equalToConstant: 100),
            
            profileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            profileButton.widthAnchor.constraint(equalToConstant: 200),
            
            tableView.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    //섹션 제목
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitle[section]
    }
    
    //섹션의 행수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.section == 0 {
            cell.textLabel?.text = "지용"
            cell.textLabel?.text = "경기도 양주시"
            cell.textLabel?.text = "레벨"
        }
        else {
            cell.textLabel?.text = "내가쓴 돌봄후기"
            cell.textLabel?.text = "로그아웃"
            cell.textLabel?.text = "탈퇴하기"
        }
        return cell
    }
}
