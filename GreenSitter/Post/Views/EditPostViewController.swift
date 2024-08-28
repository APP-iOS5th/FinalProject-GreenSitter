//
//  EditPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/20/24.
//

import UIKit
import PhotosUI
import MapKit

class EditPostViewController: UIViewController, UITextViewDelegate, PHPickerViewControllerDelegate {
    
    private let post: Post
    private var viewModel: EditPostViewModel
    
    init(post: Post, viewModel: EditPostViewModel) {
        self.post = post
        self.viewModel = viewModel
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
        textField.tintColor = .black
        textField.font = .systemFont(ofSize: 18)
        textField.placeholder = "제목을 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let dividerLine1: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
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
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let textViewPlaceHolder = "텍스트를 입력하세요."
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        view.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        view.font = .systemFont(ofSize: 18)
        view.text = textViewPlaceHolder
        view.textColor = .lightGray
        view.delegate = self
        view.sizeToFit()
        view.isScrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var remainCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "0/700"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dividerLine3: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private let mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.text = "거래 희망 장소를 선택할 수 있어요."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mapIconView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "lookingForSitterIcon")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isHidden = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("작성완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .dominent
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.tintColor = .labelsPrimary
        button.target = self
        button.action = #selector(closeButtonTapped)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPrimary
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerImageViewTapped))
        pickerImageView.addGestureRecognizer(tapGesture)
        
        // 기존 이미지를 로드
        loadExistingImages()
        updateImageStackView()
    }
    
    @objc private func pickerImageViewTapped() {
        presentImagePickerController()
    }
    
    @objc private func saveButtonTapped() {
        guard validateInputs() else { return }
        
        guard let userDocId = LoginViewModel.shared.user?.id else {
            print("User ID is not available")
            return
        }
        
        // ViewModel의 updatePost 메서드 호출
        viewModel.updatePost { result in
            switch result {
            case .success:
                print("Successfully updated post")
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("Failed to update post: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func validateInputs() -> Bool {
        var isValid = true
        
        if titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            titleTextField.attributedPlaceholder = NSAttributedString(string: "제목을 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            titleTextField.layer.borderColor = UIColor.red.cgColor
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
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupLayout() {
        self.title = post.postType.rawValue
        navigationItem.leftBarButtonItem = closeButton
        
        titleTextField.text = viewModel.postTitle
        textView.text = viewModel.postBody
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(dividerLine1)
        contentView.addSubview(imageScrollView)
        contentView.addSubview(dividerLine2)
        contentView.addSubview(textView)
        contentView.addSubview(remainCountLabel)
        contentView.addSubview(dividerLine3)
        contentView.addSubview(mapLabel)
        contentView.addSubview(mapIconView)
        contentView.addSubview(mapView)
        contentView.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        imageScrollView.addSubview(imageStackView)
        imageStackView.addArrangedSubview(pickerImageView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dividerLine1.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dividerLine1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine1.heightAnchor.constraint(equalToConstant: 1),
            
            imageScrollView.topAnchor.constraint(equalTo: dividerLine1.bottomAnchor, constant: 16),
            imageScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageScrollView.heightAnchor.constraint(equalToConstant: 130),
            
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
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
            
            dividerLine3.topAnchor.constraint(equalTo: remainCountLabel.bottomAnchor, constant: 8),
            dividerLine3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 16),
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            mapIconView.leadingAnchor.constraint(equalTo: mapLabel.trailingAnchor, constant: 8),
            mapIconView.centerYAnchor.constraint(equalTo: mapLabel.centerYAnchor),
            mapIconView.heightAnchor.constraint(equalToConstant: 20),
            mapIconView.widthAnchor.constraint(equalToConstant: 20),
            
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func addImageToStackView(_ image: UIImage) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 130).isActive = true

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // 삭제 버튼 생성
        let deleteButton = UIButton(type: .custom)
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        
        containerView.addSubview(imageView)
        containerView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            deleteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
        ])

        imageStackView.insertArrangedSubview(containerView, at: imageStackView.arrangedSubviews.count - 1)
        
        updateImageStackView()
    }

    // 2. 사진 삭제 함수
    @objc private func deleteImage(_ sender: UIButton) {
        guard let containerView = sender.superview else { return }
        containerView.removeFromSuperview()
        updateImageStackView()
    }

    // 3. 기존에 업로드된 사진 로드
    private func loadExistingImages() {
        for image in viewModel.postImages {
            addImageToStackView(image)
        }
    }

    private func updateImageStackView() {
        pickerImageView.isHidden = imageStackView.arrangedSubviews.count > 4
    }
    
    // PHPickerViewControllerDelegate methods
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self?.addImageToStackView(image)
                        }
                    }
                }
            }
        }
    }
    
    private func presentImagePickerController() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10 - (imageStackView.arrangedSubviews.count - 1)
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        remainCountLabel.text = "\(characterCount)/700"
        
        // 글자 수 제한 설정
        if characterCount > 700 {
            textView.deleteBackward()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
    
}
