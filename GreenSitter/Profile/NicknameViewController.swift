//
//  NicknameViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
class NicknameViewController: UIViewController {
    
    var user: User?
    private let db = Firestore.firestore()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이름 변경"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var nicknameTextfield: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 30
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
        
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "SeparatorsOpaque")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
        return button
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.backgroundColor = UIColor(named: "DominentColor")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(completeButtonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        print("size: \(view.frame.size)") // View의 크기를 확인
        
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(nicknameTextfield)
        view.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            nicknameTextfield.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nicknameTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameTextfield.widthAnchor.constraint(equalToConstant: 350),
            
            completeButton.topAnchor.constraint(equalTo: nicknameTextfield.bottomAnchor, constant: 40),
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 350),
            completeButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        fetchUserFirebase()
    }
    
    //MARK: - 닫기 버튼 Method
    @objc func closeButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 닉네임 변경 메소드
    @objc func completeButtonTap() {
        
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
                    DispatchQueue.main.async {
                        if let nickname = data["nickname"] as? String {
                            self.nicknameTextfield.placeholder = nickname
                            print("Nickname in UITextField: \(nickname)") // 닉네임 출력
                        } else {
                            print("No nickname found in data")
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
