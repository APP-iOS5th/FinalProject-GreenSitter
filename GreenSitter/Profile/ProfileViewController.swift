//
//  ProfileViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let db = Firestore.firestore()
    var user: User?
    let storage = Storage.storage()
    
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
        button.addTarget(self, action: #selector(changeImageTap), for: .touchUpInside)
        button.layer.cornerRadius = 50
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 프로필 보기", for: .normal)
        button.setTitleColor(UIColor(named: "LabelsPrimary"), for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "BGSecondary")
        return tableView
    }()
    
    
    var sectionTitle = ["내 정보", "계정"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BGSecondary") /*.white*/
        navigationItem.title = "프로필"
        
        view.addSubview(circleView)
        view.addSubview(imageButton)
        view.addSubview(profileButton)
        view.addSubview(tableView)
        
        fetchUserFirebase()
        
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            tableView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    //MARK: - 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    //MARK: -섹션 제목
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitle[section]
    }
    
    //MARK: - 섹션의 행수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    //MARK: - 테이블 셀 관련
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileTableViewCell
        let cornerRadius: CGFloat = 10
        var maskedCorners: CACornerMask = []
        
        if indexPath.row == 0 {
            // 첫 번째 셀: 상단 모서리를 둥글게
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            // 마지막 셀: 하단 모서리를 둥글게
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.titleLabel.text = "이름"
                cell.bodyLabel.text = "지용"
                cell.actionButton.isHidden = false
                cell.actionButton.setTitle("변경", for: .normal)
                cell.actionButton.addTarget(self, action: #selector(changeNicknameButtonTap), for: .touchUpInside)
                cell.setIconHidden(true)
            }
            else if indexPath.row == 1 {
                cell.titleLabel.text = "사는 곳"
                cell.bodyLabel.text = "경기도 양주시"
                cell.actionButton.isHidden = false
                cell.actionButton.setTitle("변경", for: .normal)
                cell.actionButton.addTarget(self, action: #selector(changeLocationButtonTap), for: .touchUpInside)
                cell.setIconHidden(true)
            }
            else if indexPath.row == 2 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "레벨"
                cell.iconImageView.image = UIImage(named: "로고7") // 레벨 아이콘 추가
                cell.actionButton.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
                cell.actionButton.addTarget(self, action: #selector(inpoButtonTap), for: .touchUpInside)
                cell.actionButton.isHidden = false // 변경 버튼 숨기기
                cell.iconImageView.isHidden = false // 아이콘 보이기
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "내가 쓴 돌봄 후기"
                cell.iconImageView.image = UIImage(systemName: "pencil")
                cell.actionButton.isHidden = true
                cell.iconImageView.isHidden = false
            }
            else if indexPath.row == 1 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "로그아웃"
                cell.bodyLabel.textColor = UIColor.systemBlue
                cell.iconImageView.image = UIImage(systemName: "power")
                cell.iconImageView.tintColor = UIColor.systemBlue
                cell.actionButton.isHidden = true
                cell.iconImageView.isHidden = false
            }
            else if indexPath.row == 2 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "탈퇴하기"
                cell.bodyLabel.textColor = UIColor.red
                cell.iconImageView.image = UIImage(systemName: "person.crop.circle.badge.xmark")
                cell.iconImageView.tintColor = UIColor.red
                cell.actionButton.isHidden = true
                cell.iconImageView.isHidden = false
            }
        }
        
        // 셀의 모서리 설정
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
        
        // 테두리 설정
        cell.contentView.layer.cornerRadius = cornerRadius
        cell.contentView.layer.maskedCorners = maskedCorners
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.backgroundColor = .white
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택된 셀의 선택 상태 해제
        
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            // 로그아웃 셀을 선택했을 때
            logout()
        case (1, 2):
            // 탈퇴하기 셀을 선택했을 때
            accountDeletion()
        default:
            break
        }
    }
    
    //MARK: - 닉네임 변경 Method
    @objc func changeNicknameButtonTap() {
        let nickname = NicknameViewController()
        
        present(nickname, animated: true)
        
        if let presentationController = nickname.presentationController as? UISheetPresentationController {
            presentationController.detents = [
                UISheetPresentationController.Detent.custom { _ in
                    return 213 // 원하는 높이로 조정
                }
            ]
            presentationController.preferredCornerRadius = 20 // 모서리 둥글기 설정 (선택 사항)
        }
    }
    
    //MARK: - 이미지 라이브러리로 가는 Method
    @objc func changeImageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    //MARK: - Image Change Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let editedImage = info[.editedImage] as? UIImage {
            uploadImage(image: editedImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updateNickname(imageURL)
                    self.imageButton.setImage(editedImage, for: .normal)
                }
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadImage(image: originalImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updateNickname(imageURL)
                    self.imageButton.setImage(originalImage, for: .normal)
                }
            }
        }
    }

    
    //MARK: - 위치 변경 Method
    @objc func changeLocationButtonTap() {
        
    }
    
    //MARK: - 레벨에대한 상세정보 Method
    @objc func inpoButtonTap() {
        
    }
    
    //MARK: - Logout Method
    func logout() {
        
    }
    
    //MARK: - 회원탈퇴 Method
    func accountDeletion() {
        
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
    //MARK: - 변경된 사진을 파이어베이스에 저장
    func updateNickname(_ profileImage: String) {
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }
        
        let userData: [String: Any] = ["profileImage": profileImage]
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                print("Nickname successfully saved!")
            }
        }
    }
    
    //MARK: - 이미지 파일 스토리지 업로드
    func uploadImage(image: UIImage, completion: @escaping(String?) -> Void) {
        let storageRef = storage.reference().child("gs://greensitter-6dedd.appspot.com/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Error: Unable to convert UIImage to Data")
            completion(nil)
            return
        }
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Firebase Storage Error: \(error)")
                completion(nil)
                return
            }
            // 업로드 완료 후 이미지 다운로드 URL을 가져옴
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
}
