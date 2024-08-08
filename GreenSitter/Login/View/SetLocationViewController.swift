//
//  SetLocationViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/8/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SetLocationViewController: UIViewController, UITextFieldDelegate {
    
    var user: User?
    let db = Firestore.firestore()
    var currentUser: User? // 현재 사용자 객체
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "위치정보 입력"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = """
    주변의 새싹 돌봄이 ☘️
    새싹 돌봄이를 찾는 분들을
    매칭 해드립니다!
"""
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0 // 여러 줄 텍스트를 지원
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var locationTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 30
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(rgbRed: 242, green: 242, blue: 242)
        if let userLocation = user?.location {
            textField.placeholder = "\(userLocation)"
        }
        else {
            textField.placeholder = "현재 위치가져오기 실패"
        }
        textField.clearsOnBeginEditing = true //편집시 기존텍스트필드값 지우기
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // 위치 텍스트 추가
        let label = UILabel()
        label.text = "위치 "
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.sizeToFit()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width + 10, height: textField.frame.height))
        label.frame.origin = CGPoint(x: 10, y: (containerView.frame.height - label.frame.height) / 2)
        containerView.addSubview(label)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgbRed: 110, green: 190, blue: 70) // RGB 값으로 설정
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("건너뛰기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(skipTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = Auth.auth().currentUser {
            print("Current User ID: \(currentUser.uid)")
            print("Current User Email: \(currentUser.email ?? "No Email")")
            print("Current User Display Name: \(currentUser.displayName ?? "No Display Name")")
            print("Current User Photo URL: \(currentUser.photoURL?.absoluteString ?? "No Photo URL")")
        } else {
            print("No user is currently logged in.")
        }
        
        
        print("User 객체 상태: \(String(describing: user))")
        
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(locationTextField)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bodyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -180),
            
            locationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor ),
            locationTextField.widthAnchor.constraint(equalToConstant: 350), // 너비 200 설정
            
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            nextButton.widthAnchor.constraint(equalToConstant: 350),
            nextButton.heightAnchor.constraint(equalToConstant: 45),
            
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70),
        ])
        
    }
    
    
    //위치 정보 저장
    func saveUserToFirestore(user: User, userId: String) {
        let userRef = db.collection("users").document(userId)
        let userData: [String: Any] = [
            "location": user.location ?? ""
        ]
        userRef.setData(userData) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                print("Location data saved")
            }
        }
    }
    
    @objc func nextTap() {
        guard let enterLocation = locationTextField.text, !enterLocation.isEmpty else {
            print("위치 정보가 비어 있습니다.")
            return
        }
        
        guard let user = user else {
            print("User 객체가 없습니다.")
            return
        }
        
        // userId를 UUID 문자열로 변환
        let userId = user.id.uuidString
        saveUserToFirestore(user: user, userId: userId)
        let setProfileViewController = SetProfileViewController()
        navigationController?.pushViewController(setProfileViewController, animated: true)
        
    }
    
    @objc func skipTap() {
        let setProfileViewController = SetProfileViewController()
        navigationController?.pushViewController(setProfileViewController, animated: true)
    }
}

extension UIColor {
    convenience init(rgbRed: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: rgbRed / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
