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

class AboutMeViewController: UIViewController {
    
    let db = Firestore.firestore()
    var user: User?
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGSecondary")
        navigationItem.title = "내 프로필"
        
        view.addSubview(circleView)
        view.addSubview(profileImage)
        view.addSubview(levelView)
        levelView.addSubview(levelIcon) // levelIcon을 levelView의 서브뷰로 추가
        levelView.addSubview(levelLabel) // levelLabel을 levelView의 서브뷰로 추가
        view.addSubview(nicknameLabel)
        view.addSubview(separatorLine)
        view.addSubview(locationLabel)
        
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
        ])
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
