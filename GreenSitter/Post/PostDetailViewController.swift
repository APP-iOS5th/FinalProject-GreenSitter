//
//  PostDetailViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/10/24.
//

import UIKit
import MapKit

class PostDetailViewController: UIViewController {
    
    private let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.backward")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "부리부리대마왕"
        return label
    }()
    
    private let userLevelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lv. 1 🌱"
        return label
    }()
    
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2시간 전"
        return label
    }()
    
    private let deviderLine1: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let deviderLine2: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let deviderLine3: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .dominent
        label.text = "거래중"
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        label.text = "대형 화분 주기적으로 관리해드려요!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pickerImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .lightGray
        image.tintColor = .gray
        image.image = UIImage(systemName: "photo.on.rectangle.fill")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = """
        저는 병갈고무나무랑 여인초를 키우고 있는데,
        저랑 비슷한 품종의 식물을 키우는 분들 계신가요?
        저는 재택근무 중이라 바쁘신 분들 대신해서
        화분 관리 도와드릴 수 있어요~~
        서로서로 정보 공유도 했으면 좋겠어요 ^^
        """
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("채팅하기", for: .normal)
        button.backgroundColor = .complementary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = .labelsSecondary
        label.font = .systemFont(ofSize: 16)
        label.text = "거래 희망 장소를 선택할 수 있어요."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerImageViewTapped))
        pickerImageView.addGestureRecognizer(tapGesture)
        pickerImageView.isUserInteractionEnabled = true // 이미지 뷰 상호작용 활성화
    }
    
    @objc private func pickerImageViewTapped() {
        presentImagePickerController()
    }
    
    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(userLevelLabel)
        view.addSubview(postTimeLabel)
        view.addSubview(statusLabel)
        view.addSubview(postTitleLabel)
        view.addSubview(pickerImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(deviderLine1)
        view.addSubview(deviderLine2)
        view.addSubview(deviderLine3)
        view.addSubview(contactButton)
        view.addSubview(mapLabel)
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            
            userLevelLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            userLevelLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            
            postTimeLabel.topAnchor.constraint(equalTo: userLevelLabel.bottomAnchor, constant: 4),
            postTimeLabel.leadingAnchor.constraint(equalTo: userLevelLabel.leadingAnchor),
            
            statusLabel.bottomAnchor.constraint(equalTo: postTimeLabel.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.widthAnchor.constraint(equalToConstant: 40),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            postTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 50),
            postTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            postTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            deviderLine1.bottomAnchor.constraint(equalTo: postTitleLabel.topAnchor, constant: 35),
            deviderLine1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviderLine1.widthAnchor.constraint(equalToConstant: 360),
            deviderLine1.heightAnchor.constraint(equalToConstant: 1),
            
            deviderLine2.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -20),
            deviderLine2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviderLine2.widthAnchor.constraint(equalToConstant: 360),
            deviderLine2.heightAnchor.constraint(equalToConstant: 1),
            
            deviderLine3.bottomAnchor.constraint(equalTo: mapLabel.topAnchor, constant: -10),
            deviderLine3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviderLine3.widthAnchor.constraint(equalToConstant: 360),
            deviderLine3.heightAnchor.constraint(equalToConstant: 1),
            
            pickerImageView.widthAnchor.constraint(equalToConstant: 100),
            pickerImageView.heightAnchor.constraint(equalToConstant: 100),
            pickerImageView.topAnchor.constraint(equalTo: deviderLine1.bottomAnchor, constant: 20),
            pickerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionLabel.bottomAnchor.constraint(equalTo: deviderLine3.topAnchor, constant: -30),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            contactButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            contactButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contactButton.widthAnchor.constraint(equalToConstant: 100),
            contactButton.heightAnchor.constraint(equalToConstant: 40),
            
            mapLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapLabel.bottomAnchor.constraint(equalTo: mapView.topAnchor, constant: -10 ),
            
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

extension PostDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alert = UIAlertController(title: "사진 선택", message: "사진을 가져올 곳을 선택하세요.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("카메라 사용 불가")
            }
        }))
        alert.addAction(UIAlertAction(title: "사진 라이브러리", style: .default, handler: { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            pickerImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

#Preview {
    return UINavigationController(rootViewController: PostDetailViewController())
}
