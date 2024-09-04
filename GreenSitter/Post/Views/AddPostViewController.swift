//
//  AddPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/13/24.
//

import UIKit
import PhotosUI
import MapKit

class AddPostViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
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
    
    private let mapLabelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView to hold the image and label (left side)
        let leftStackView = UIStackView()
        leftStackView.axis = .horizontal
        leftStackView.alignment = .center
        leftStackView.spacing = 8 // Space between image and text
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Image on the left
        let symbolImageView = UIImageView()
        let symbolImage = UIImage(systemName: "mappin.and.ellipse")
        symbolImageView.image = symbolImage?.withTintColor(.labelsSecondary, renderingMode: .alwaysOriginal)
        
        // Text label
        let textLabel = UILabel()
        textLabel.text = "거래 희망 장소를 선택하세요!"
        textLabel.font = .systemFont(ofSize: 17)
        textLabel.textColor = .labelsSecondary
        
        // Add image and label to the left stack view
        leftStackView.addArrangedSubview(symbolImageView)
        leftStackView.addArrangedSubview(textLabel)
        
        // Right arrow '>' on the far right
        let arrowImageView = UIImageView()
        let arrowImage = UIImage(systemName: "chevron.right")
        arrowImageView.image = arrowImage?.withTintColor(.labelsSecondary, renderingMode: .alwaysOriginal)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the left stack view and the arrow to the button
        button.addSubview(leftStackView)
        button.addSubview(arrowImageView)
        
        // Constraints for the left stack view (image and text)
        NSLayoutConstraint.activate([
            leftStackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            leftStackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Constraints for the arrow on the right
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Button appearance
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        
        return button
    }()


    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
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
        view.backgroundColor = .bgPrimary
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerImageViewTapped))
        pickerImageView.addGestureRecognizer(tapGesture)
        
        updateSaveButtonState()
        titleTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        
        updateImageStackView()
        
        hideKeyboard()
    }
    
    func hideKeyboard() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    @objc private func textDidChange() {
        updateSaveButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let address = viewModel.postLocation?.address
        let placeName = viewModel.postLocation?.placeName
        
        guard let textLabel = mapLabelButton.subviews
            .compactMap({ $0 as? UIStackView })
            .first?
            .arrangedSubviews
            .compactMap({ $0 as? UILabel })
            .first else { return }
        
        if let address = address, !address.isEmpty {
            textLabel.text = address
        } else if let placeName = placeName, !placeName.isEmpty {
            textLabel.text = placeName
        } else {
            textLabel.text = "거래 희망 장소를 선택하세요!"
        }
    }
    
    @objc private func saveButtonTapped() {
        
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
        contentView.addSubview(mapLabelButton)
        contentView.addSubview(mapView)
        
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        mapLabelButton.addTarget(self, action: #selector(mapLabelButtonTapped), for: .touchUpInside)

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
            
            mapLabelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapLabelButton.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 10),
            mapLabelButton.heightAnchor.constraint(equalToConstant: 60),
         
            mapView.topAnchor.constraint(equalTo: mapLabelButton.bottomAnchor, constant: 12),
            mapView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            mapView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    @objc private func mapLabelButtonTapped() {
        let searchMapViewController = SearchMapViewController()
        searchMapViewController.addPostViewModel = viewModel
        let navigationController = UINavigationController(rootViewController: searchMapViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
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
        
        let minHeight: CGFloat = 200
        
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
        
        updateSaveButtonState()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .labelsSecondary || textView.textColor == .red {
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
        
        imageStackView.addArrangedSubview(pickerImageView)
        
        // 나머지 이미지들을 추가합니다.
        for (index, image) in viewModel.selectedImages.prefix(10).enumerated() {
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
    }
    
    @objc private func deleteImage(_ sender: UIButton) {
        let index = sender.tag
        viewModel.selectedImages.remove(at: index)
        updateImageStackView()
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        // 현재 선택된 이미지 수와 추가하려는 이미지 수의 합이 10장을 초과하는지 확인
        let availableSlots = 10 - viewModel.selectedImages.count
        
        if availableSlots > 0 {
            let selectedResults = results.prefix(availableSlots)
            
            viewModel.addSelectedImages(results: Array(selectedResults)) { [weak self] in
                DispatchQueue.main.async {
                    // 추가된 이미지를 업데이트
                    for result in selectedResults {
                        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                            if let image = image as? UIImage {
                                DispatchQueue.main.async {
                                    self?.updateImageStackView()
                                }
                            }
                        }
                    }
                }
            }
            
            // 선택한 이미지가 추가 가능한 슬롯보다 많을 경우 알림 표시
            if results.count > availableSlots {
                let alert = UIAlertController(title: "이미지 초과", message: "최대 10장의 이미지만 업로드할 수 있습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                present(alert, animated: true)
            }
        } else {
            // 더 이상 이미지를 추가할 수 없는 경우 경고 메시지 표시
            let alert = UIAlertController(title: "이미지 초과", message: "최대 10장의 이미지만 업로드할 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true)
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
        if viewModel.selectedImages.count >= 10 {
            let alert = UIAlertController(title: "이미지 제한", message: "최대 10장의 이미지만 선택할 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 - viewModel.selectedImages.count
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSaveButtonState()
        return true
    }
    
    // Save 버튼의 상태를 업데이트하는 메서드
    private func updateSaveButtonState() {
        let titleTextFieldIsNotEmpty = !(titleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        
        let textViewIsNotEmpty = !textView.text.trimmingCharacters(in: .whitespaces).isEmpty && textView.text != textViewPlaceHolder
        
        if titleTextFieldIsNotEmpty && textViewIsNotEmpty {
            saveButton.backgroundColor = .dominent
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = .fillSecondary
            saveButton.isEnabled = false
        }
    }
}
