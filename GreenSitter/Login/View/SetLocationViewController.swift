//
//  SetLocationViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/8/24.
//

import Combine
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SetLocationViewController: UIViewController, UITextFieldDelegate {
    
    private let mapViewModel = MapViewModel()
    private var cancellables = Set<AnyCancellable>()

    var users: User?
    
    let db = Firestore.firestore()
    var currentUser: User? // 현재 사용자 객체
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "위치정보 입력 "
        label.textColor = .labelsPrimary
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = 
        """
        주변의 새싹 돌봄이 ☘️
        새싹 돌봄이를 찾는 분들을
        매칭 해드립니다!
        """
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0 // 여러 줄 텍스트를 지원
        label.textColor = .labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var locationTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 30
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.fillPrimary
        textField.placeholder = "현재 위치 가져오기 실패"
//        textField.clearsOnBeginEditing = true //편집시 기존텍스트필드값 지우기
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // 위치 텍스트 추가
        let label = UILabel()
        label.text = "위치 "
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .labelsPrimary
        label.sizeToFit()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width + 10, height: textField.frame.height))
        label.frame.origin = CGPoint(x: 10, y: (containerView.frame.height - label.frame.height) / 2)
        containerView.addSubview(label)
        
        textField.leftView = containerView
        textField.leftViewMode = .always

        textField.isEnabled = false  // 편집 불가능 설정

        return textField
    }()

    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "DominentColor")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        print("User 객체 상태: \(String(describing: users))")
        
        view.backgroundColor = .bgPrimary
        
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(locationTextField)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),

            locationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor ),
            locationTextField.widthAnchor.constraint(equalToConstant: 350),
            
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            nextButton.widthAnchor.constraint(equalToConstant: 350),
            nextButton.heightAnchor.constraint(equalToConstant: 45),
            

        ])
//        getUserData()
    }
    
    private func bindViewModel() {
        mapViewModel.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                print("SetLocation View Location: \(location)")
                self?.users?.location = location
                self?.locationTextField.text = location.address
            }
            .store(in: &cancellables)
    }
    
    
    //MARK: - NextButton Method
    @objc func nextTap() {
        guard let currentLocation = mapViewModel.currentLocation else {
            print("CurrentLocation is nil")
            return
        }
        
        updateLocationInFirestore(location: currentLocation)
    }
    
    //MARK: - 파이어베이스 위치정보 저장
    private func updateLocationInFirestore(location: Location) {
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }
        
        let userData: [String: Any] = [
            "location": location.toDictionary()
        ]
        
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                print("Location successfully saved!")
            }
        }
        
        DispatchQueue.main.async {
            let setProfileViewController = SetProfileViewController(location: location)
            self.navigationController?.pushViewController(setProfileViewController, animated: true)
        }

    }
    
    
    
}

