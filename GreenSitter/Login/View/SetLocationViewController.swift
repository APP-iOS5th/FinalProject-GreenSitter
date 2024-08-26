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

protocol SetLocationViewControllerDelegate: AnyObject {
    func didCompleteLocationSetup()
}

class SetLocationViewController: UIViewController, UITextFieldDelegate, SetProfileViewControllerDelegate {
    func didCompleteProfileSetup() {
        self.delegate?.didCompleteLocationSetup()
        self.navigationController?.popToRootViewController(animated: true)
    }

    weak var delegate: SetLocationViewControllerDelegate?

    private let mapViewModel = MapViewModel()
    private var cancellables = Set<AnyCancellable>()

    var users: User?
    
    let db = Firestore.firestore()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "위치정보 입력 "
        label.textColor = .labelsPrimary
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let fullText = """
        내 주변의 새싹 돌봄이와
        새싹 보호자를 연결해드릴게요.

        내 위치를 설정해주세요.
        """
        
        let styledText = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: "새싹 돌봄이") {
            let nsRange = NSRange(range, in: fullText)
            styledText.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 17),
                .foregroundColor: UIColor.dominent
            ], range: nsRange)
        }
        
        if let range = fullText.range(of: "새싹 보호자") {
            let nsRange = NSRange(range, in: fullText)
            styledText.addAttributes([
                .font: UIFont.boldSystemFont(ofSize: 17),
                .foregroundColor: UIColor.complementary
            ], range: nsRange)
        }
        
        label.attributedText = styledText
        
        return label
    }()

    
    lazy var locationTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 30
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .fillPrimary
        textField.textColor = .labelsPrimary
        textField.placeholder = "내 위치를 입력해주세요."
//        textField.clearsOnBeginEditing = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.autocapitalizationType = .none

        // 위치 텍스트 추가
        let label = UILabel()
        label.text = "위치 "
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .labelsSecondary
        label.sizeToFit()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width + 10, height: textField.frame.height))
        label.frame.origin = CGPoint(x: 10, y: (containerView.frame.height - label.frame.height) / 2)
        containerView.addSubview(label)
        
        textField.leftView = containerView
        textField.leftViewMode = .always

        textField.isEnabled = true

        return textField
    }()
    
    lazy var guideTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "위치를 직접 수정할 수 있어요."
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.textColor = .labelsSecondary
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return textLabel
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .dominent
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        mapViewModel.checkLocationAuthorization()

        print("User 객체 상태: \(String(describing: users))")
        
        view.backgroundColor = .bgPrimary
        setupBackButton()
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(locationTextField)
        view.addSubview(nextButton)
        view.addSubview(guideTextLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            locationTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            locationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
            
            guideTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideTextLabel.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 10),
            
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
            nextButton.heightAnchor.constraint(equalToConstant: 45),
            

        ])
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
    
    

    
    // MARK: - BACK BUTTON METHOD
    
    private func setupBackButton() {
        navigationItem.hidesBackButton = true
        
        let backButton = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        // 뒤로가기 버튼이 눌렸을 때 경고창을 띄웁니다.
        let alert = UIAlertController(title: "회원가입 과정을 취소하시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            self?.deleteUserDataAndPop()
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
    }

    private func deleteUserDataAndPop() {
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }

        db.collection("users").document(user.uid).delete { [weak self] error in
            if let error = error {
                print("Firestore Deletion Error: \(error)")
            } else {
                print("User data successfully deleted!")
                
                // Firebase Authentication에서 사용자 삭제
                user.delete { authError in
                    if let authError = authError {
                        print("Firebase Auth Deletion Error: \(authError)")
                    } else {
                        print("Firebase user successfully deleted!")
                        
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    
    // MARK: - NEXT BUTTON METHOD
    
    @objc func nextTap() {
        guard let addressText = locationTextField.text else {
            return
        }
        
        if var currentLocation = mapViewModel.currentLocation {
            currentLocation.address = addressText
            updateLocationInFirestore(location: currentLocation)
        } else {
            print("mapViewModel: CurrentLocation is nil")
            updateLocationInFirestore(location: Location.seoulLocation)
        }
    }
    
    // 파이어베이스 위치정보 저장
    
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
            setProfileViewController.delegate = self
            self.navigationController?.pushViewController(setProfileViewController, animated: true)
        }
    }
}

#Preview {
    UINavigationController(rootViewController: SetLocationViewController())
}
