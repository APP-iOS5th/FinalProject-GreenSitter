//
//  TestViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/7/24.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SetProfileViewController: UIViewController {
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    var selectButton: UIButton? // 선택한 버튼을 저장할 변수
    
    private let location: Location
    
    init(location: Location) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 정보 입력"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func createImageButton() -> UIButton {
        let button = UIButton()
        button.configuration?.imagePadding = 5        
        button.imageView?.contentMode = .scaleAspectFit
        //         button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    
    lazy var imageButton1 = createImageButton()
    lazy var imageButton2 = createImageButton()
    lazy var imageButton3 = createImageButton()
    lazy var imageButton4 = createImageButton()
    lazy var imageButton5 = createImageButton()
    lazy var imageButton6 = createImageButton()
    
    lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 30
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .fillPrimary
        textField.textColor = .labelsPrimary
        textField.placeholder = "닉네임을 입력해주세요."
        textField.clearsOnBeginEditing = true
        textField.autocapitalizationType = .none

        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "닉네임 "
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .labelsSecondary
        label.sizeToFit()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width + 10, height: textField.frame.height))
        label.frame.origin = CGPoint(x: 10, y: (containerView.frame.height - label.frame.height) / 2)
        containerView.addSubview(label)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var nicknameStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""  // 처음에는 빈 문자열로 설정
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red  // 에러 메시지는 빨간색으로 표시
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("건너뛰기", for: .normal)
        button.setTitleColor(.labelsPrimary, for: .normal)
        button.addTarget(self, action: #selector(skipTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var imageStackView1: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageButton1, imageButton2, imageButton3])
        stackView.axis = .horizontal
        stackView.spacing = 10 // 간격 추가
        stackView.distribution = .fillEqually // 버튼들이 동일한 크기로 분배
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var imageStackView2: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageButton4, imageButton5, imageButton6])
        stackView.axis = .horizontal
        stackView.spacing = 10 // 간격 추가
        stackView.distribution = .fillEqually // 버튼들이 동일한 크기로 분배
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPrimary
        
        // 서브뷰 추가
        view.addSubview(titleLabel)
        view.addSubview(imageStackView1)
        view.addSubview(imageStackView2)
        view.addSubview(nickNameTextField)
        view.addSubview(nicknameStatusLabel)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        imageButton1.addTarget(self, action: #selector(imageButtonTap(_ :)), for: .touchUpInside)
        imageButton2.addTarget(self, action: #selector(imageButtonTap(_ :)), for: .touchUpInside)
        imageButton3.addTarget(self, action: #selector(imageButtonTap(_ :)), for: .touchUpInside)
        imageButton4.addTarget(self, action: #selector(imageButtonTap(_ :)), for: .touchUpInside)
        imageButton5.addTarget(self, action: #selector(imageButtonTap(_ :)), for: .touchUpInside)
        imageButton6.addTarget(self, action: #selector(imageButtonTap(_ :)), for: .touchUpInside)
        nickNameTextField.addTarget(self, action: #selector(nicknameTextChanged(_:)), for: .editingChanged)
        
        setupImage()
        updateNextButtonAppearance(isUniqueNickname: false)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageStackView1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStackView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            imageStackView1.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
            imageStackView1.heightAnchor.constraint(equalToConstant: 100),
            
            imageStackView2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageStackView2.topAnchor.constraint(equalTo: imageStackView1.bottomAnchor, constant: 20),
            imageStackView2.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
            imageStackView2.heightAnchor.constraint(equalToConstant: 100),
            
            nickNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nickNameTextField.topAnchor.constraint(equalTo: imageStackView2.bottomAnchor, constant: 20),
            nickNameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
            
            nicknameStatusLabel.topAnchor.constraint(equalTo: nickNameTextField.bottomAnchor, constant: 8),
            nicknameStatusLabel.leadingAnchor.constraint(equalTo: nickNameTextField.leadingAnchor),
            nicknameStatusLabel.trailingAnchor.constraint(equalTo: nickNameTextField.trailingAnchor),
            
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -15),
            nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
            nextButton.heightAnchor.constraint(equalToConstant: 45),
            
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
    }
    
    // MARK: - 중복된 닉네임 체크
    func checkNicknameAvailability(nickname: String) {
        let usersRef = db.collection("users")
        usersRef.whereField("nickname", isEqualTo: nickname).getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error checking nickname availability: \(error)")
                return
            }
            
            if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                // 닉네임이 이미 사용 중인 경우
                DispatchQueue.main.async {
                    self?.nicknameStatusLabel.text = "중복된 닉네임입니다."
                    self?.nicknameStatusLabel.textColor = .red
                    self?.updateNextButtonAppearance(isUniqueNickname: false)
                }
            } else {
                // 닉네임을 사용할 수 있는 경우
                DispatchQueue.main.async {
                    self?.nicknameStatusLabel.text = "사용 가능한 닉네임입니다."
                    self?.nicknameStatusLabel.textColor = .green
                    self?.updateNextButtonAppearance(isUniqueNickname: true)
                }
            }
        }
    }
    
    @objc func nicknameTextChanged(_ textField: UITextField) {
        // 닉네임 필드가 비어 있는 경우
        if let nickname = textField.text, !nickname.isEmpty {
            checkNicknameAvailability(nickname: nickname)
        } else {
            // 닉네임 필드가 비어 있으면 상태 레이블을 비우고 버튼 비활성화
            nicknameStatusLabel.text = ""
            updateNextButtonAppearance(isUniqueNickname: false)
        }
    }
    
    
    private func updateNextButtonAppearance(isUniqueNickname: Bool) {
        // 닉네임 텍스트 필드가 비어 있는지 확인
        let isNicknameEmpty = nickNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        
        // 버튼의 활성화 상태를 설정
        let isEnabled = !isNicknameEmpty && isUniqueNickname
        nextButton.isEnabled = isEnabled
        
        // 버튼의 배경색 및 텍스트 색상을 설정
        if isEnabled {
            nextButton.backgroundColor = .dominent // 활성화된 버튼 색상
            nextButton.setTitleColor(.white, for: .normal)
        } else {
            nextButton.backgroundColor = .gray // 비활성화된 버튼 색상
            nextButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    func setupImage() {
        let imageUrls = [
            "gs://greensitter-6dedd.appspot.com/꽃1.png",
            "gs://greensitter-6dedd.appspot.com/꽃2.png",
            "gs://greensitter-6dedd.appspot.com/꽃3.png",
            "gs://greensitter-6dedd.appspot.com/썩은 씨앗4.png",
            "gs://greensitter-6dedd.appspot.com/썩은씨앗5.png",
            "gs://greensitter-6dedd.appspot.com/씨앗1.png"
        ]
        
        let buttons = [imageButton1, imageButton2, imageButton3, imageButton4, imageButton5, imageButton6]
        
        for (index, url) in imageUrls.enumerated() {
            if index < buttons.count {
                downloadImage(from: url) { image in
                    DispatchQueue.main.async {
                        buttons[index].setImage(image, for: .normal)
                    }
                }
            }
        }
    }
    
    //MARK: - Storage에서 이미지 파일 불러오기
    func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        let imageRef = storage.reference(forURL: url)
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Image download error: \(error)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
        }
    }
    
    //MARK: - 선택 이미지
    @objc func imageButtonTap(_ sender: UIButton) {
        // 이전에 선택된 버튼의 테두리 해제
        selectButton?.layer.borderWidth = 0
        selectButton?.layer.borderColor = UIColor.clear.cgColor // 테두리 색상을 지움
        
        // 새로운 버튼을 선택
        selectButton = sender
        
        // 선택된 버튼의 테두리 색상을 ComplementaryColor로 설정
        if let complementaryColor = UIColor(named: "ComplementaryColor") {
            selectButton?.layer.borderColor = complementaryColor.cgColor
            selectButton?.layer.borderWidth = 2.0 // 테두리 두께 설정
        }
    }

    //MARK: - nextButton을 눌렀을때 닉네임을 파이어베이스에 저장
    
    @objc func nextTap() {
        
        guard let nickname = nickNameTextField.text, !nickname.isEmpty else {
            nickNameTextField.text = "기본 닉네임"
            return
        }
        guard let selectButton = selectButton else { return }
        
        let imageUrls = [
            "gs://greensitter-6dedd.appspot.com/꽃1.png",
            "gs://greensitter-6dedd.appspot.com/꽃2.png",
            "gs://greensitter-6dedd.appspot.com/꽃3.png",
            "gs://greensitter-6dedd.appspot.com/썩은 씨앗4.png",
            "gs://greensitter-6dedd.appspot.com/썩은씨앗5.png",
            "gs://greensitter-6dedd.appspot.com/씨앗1.png"
        ]
        
        //선택된 버튼에 맞는 url 찾기
        guard let selectedButtonIndex = [imageButton1, imageButton2, imageButton3, imageButton4, imageButton5, imageButton6].firstIndex(of: selectButton) else { return }
        let selectedImageUrl = imageUrls[selectedButtonIndex]
        
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }
        
        let userData: [String: Any] = [
            "id": user.uid,
            "enabled": true,
            "createDate": Date(),
            "updateDate": Date(),
            "profileImage": selectedImageUrl,
            "nickname": nickname,
            "levelPoint": Level.seeds.rawValue,
            "exp": 0,
            "aboutMe": "",
            "chatNotification": false
        ]
        
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                LoginViewModel.shared.firebaseFetch(docId: user.uid)

                print("Nickname successfully saved!")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func skipTap() {
        let defaultImageUrl = "gs://greensitter-6dedd.appspot.com/꽃1.png"
        
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }
        let userData: [String: Any] = [
            "id": user.uid,
            "enabled": true,
            "createDate": Date(),
            "updateDate": Date(),
            "profileImage": defaultImageUrl,
            "nickname": "기본 닉네임",   // TODO: 닉네임 자동생성기 호출
            "levelPoint": Level.seeds.rawValue,
            "exp": 0,
            "aboutMe": "",
            "chatNotification": false
        ]
        
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                LoginViewModel.shared.firebaseFetch(docId: user.uid)
                
                print("Nickname successfully saved!")
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

