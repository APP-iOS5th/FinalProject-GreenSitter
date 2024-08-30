//
//  AddPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/13/24.
//

import UIKit
import PhotosUI
import MapKit

class AddPostViewController: UIViewController {
    
    private var postType: PostType
    private var viewModel: AddPostViewModel
    
    init(postType: PostType, viewModel: AddPostViewModel) {
        self.postType = postType
        self.viewModel = AddPostViewModel(postType: postType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .labelsPrimary
        textField.font = .systemFont(ofSize: 18)

        // placeholder 텍스트의 색상을 변경
        textField.attributedPlaceholder = NSAttributedString(
            string: "제목을 입력하세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.labelsSecondary]
        )
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    
    private let dividerLine1: UIView = {
        let line = UIView()
        line.backgroundColor = .separatorsNonOpaque
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let pickerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "rectangle.stack.fill.badge.plus")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dividerLine2: UIView = {
        let line = UIView()
        line.backgroundColor = .separatorsNonOpaque
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let textViewPlaceHolder = "텍스트를 입력하세요."
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        view.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        view.font = .systemFont(ofSize: 18)
        view.text = textViewPlaceHolder
        view.textColor = .labelsSecondary
        view.delegate = self
        view.sizeToFit()
        view.isScrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var remainCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "0/700"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .labelsSecondary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dividerLine3: UIView = {
        let line = UIView()
        line.backgroundColor = .separatorsNonOpaque
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = .labelsSecondary
        label.font = .systemFont(ofSize: 16)
        label.text = "거래 희망 장소를 선택할 수 있어요."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mapIconButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "lookingForSitterIcon")
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("작성완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .dominent
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerImageViewTapped))
        pickerImageView.addGestureRecognizer(tapGesture)
        
        updateImageStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: 단순히 address으로 표시 -> Map 으로 표시
        if let address = viewModel.postLocation?.address {
            mapLabel.text = address
        }
    }
    
    @objc private func saveButtonTapped() {
        saveButton.isEnabled = false
        
        guard validateInputs() else {
            saveButton.isEnabled = true
            return
        }
        
        guard let currentUser = LoginViewModel.shared.user else {
            print("User ID is not available")
            saveButton.isEnabled = true

            return
        }
        
        viewModel.savePost(userId: currentUser.id, userProfileImage: currentUser.profileImage, userNickname: currentUser.nickname, userLocation: currentUser.location, userLevel: currentUser.levelPoint, postTitle: titleTextField.text!, postBody: textView.text) { [weak self] result in
            DispatchQueue.main.async {
                self?.saveButton.isEnabled = true
            }
            switch result {
            case .success(_):
                self?.showAlert(title: "알림", message: "게시물을 성공적으로 저장했습니다.")
            case .failure(let error):
                print("Error add post: \(error.localizedDescription)")
                self?.showAlert(title: "게시물 저장 실패", message: error.localizedDescription)
            }
        }
    }
    
    private func validateInputs() -> Bool {
        var isValid = true
        
        if titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            titleTextField.attributedPlaceholder = NSAttributedString(string: "제목을 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            titleTextField.layer.borderColor = UIColor.clear.cgColor
            titleTextField.layer.borderWidth = 1.0
            isValid = false
        } else {
            titleTextField.layer.borderColor = UIColor.clear.cgColor
        }
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textView.text == textViewPlaceHolder {
            textView.textColor = .red
            textView.text = textViewPlaceHolder
            isValid = false
        } else {
            textView.layer.borderColor = UIColor.clear.cgColor
        }
        
        return isValid
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let popAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(popAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupLayout() {
        self.title = postType.rawValue
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(dividerLine1)
        contentView.addSubview(imageScrollView)
        imageScrollView.addSubview(imageStackView)
        imageStackView.addArrangedSubview(pickerImageView)
        contentView.addSubview(dividerLine2)
        contentView.addSubview(textView)
        contentView.addSubview(remainCountLabel)
        contentView.addSubview(dividerLine3)
        contentView.addSubview(mapLabel)
        contentView.addSubview(mapIconButton)
        
        view.addSubview(saveButton)

        mapIconButton.addTarget(self, action: #selector(mapIconButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dividerLine1.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            dividerLine1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine1.heightAnchor.constraint(equalToConstant: 1),
            
            imageScrollView.topAnchor.constraint(equalTo: dividerLine1.bottomAnchor, constant: 16),
            imageScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            //
            imageScrollView.heightAnchor.constraint(equalToConstant: 104),
            
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor, constant: 16),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor, constant: -16),
            imageStackView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
            
            pickerImageView.widthAnchor.constraint(equalToConstant: 100),
            pickerImageView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
            
            dividerLine2.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 16),
            dividerLine2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine2.heightAnchor.constraint(equalToConstant: 1),
            
            textView.topAnchor.constraint(equalTo: dividerLine2.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            remainCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            remainCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            
            dividerLine3.topAnchor.constraint(equalTo: remainCountLabel.bottomAnchor, constant: 16),
            dividerLine3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 40),
            // map Label 간 하단 간격 필요
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60),
            mapLabel.trailingAnchor.constraint(equalTo: mapIconButton.leadingAnchor, constant: -8),
            
            mapIconButton.centerYAnchor.constraint(equalTo: mapLabel.centerYAnchor),
            mapIconButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -55), // 버튼의 우측 여백
            mapIconButton.heightAnchor.constraint(equalToConstant: 50),
            mapIconButton.widthAnchor.constraint(equalToConstant: 50),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    @objc private func mapIconButtonTapped() {
        let searchMapViewController = SearchMapViewController()
        searchMapViewController.addPostViewModel = viewModel
        let navigationController = UINavigationController(rootViewController: searchMapViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    
}

extension AddPostViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let textCount = textView.text.count
        let maxLength = 700
        
        if textCount > maxLength {
            let index = textView.text.index(textView.text.startIndex, offsetBy: maxLength)
            textView.text = String(textView.text[..<index])
        }
        
        remainCountLabel.text = "\(textView.text.count)/\(maxLength)"
        
        if textView.text.count == maxLength {
            remainCountLabel.textColor = .red
        } else {
            remainCountLabel.textColor = .labelsSecondary
        }
        
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        let minHeight: CGFloat = 200 // 최소 높이
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = max(minHeight, estimatedSize.height)
            }
        }
        
        // 내용이 비어있을 때 처리
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .labelsSecondary
            textView.selectedTextRange = nil
            textView.resignFirstResponder()
        } else if textView.textColor == .labelsSecondary && textView.text != textViewPlaceHolder {
            textView.textColor = .labelsPrimary
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .labelsSecondary {
            textView.text = nil
            textView.textColor = .labelsPrimary
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .red
        }
    }
}

extension AddPostViewController: PHPickerViewControllerDelegate {
    
    private func updateImageStackView() {
            imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            for (index, image) in viewModel.selectedImages.enumerated() {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 10
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                
                // Delete button
                let deleteButton = UIButton(type: .custom)
                deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                deleteButton.tintColor = .red
                deleteButton.translatesAutoresizingMaskIntoConstraints = false
                deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
                deleteButton.tag = index
                
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                containerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                containerView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                
                containerView.addSubview(imageView)
                containerView.addSubview(deleteButton)
                
                imageView.translatesAutoresizingMaskIntoConstraints = false
                deleteButton.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                    
                    deleteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -5),
                    deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 5)
                ])
                
                imageStackView.addArrangedSubview(containerView)
            }
            
            imageStackView.addArrangedSubview(pickerImageView)
        }
        
        @objc private func deleteImage(_ sender: UIButton) {
            let index = sender.tag
            viewModel.selectedImages.remove(at: index)
            updateImageStackView()
        }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        viewModel.addSelectedImages(results: results) { [weak self] in
            DispatchQueue.main.async {
                self?.updateImageStackView()
            }
        }
    }
    
    
    @objc private func pickerImageViewTapped() {
        checkPhotoLibraryPermission()
    }
    
    private func checkPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.presentImagePickerController()
                case .denied, .restricted:
                    self?.showPhotoLibraryAccessDeniedAlert()
                case .notDetermined:
                    // 권한 요청 대화상자가 표시
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func showPhotoLibraryAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "사진 접근 권한이 없습니다",
            message: "사진을 선택하려면 '설정'에서 사진 접근 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func presentImagePickerController() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}
