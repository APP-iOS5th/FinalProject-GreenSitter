//
//  AddPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/13/24.
//

import UIKit
import PhotosUI
import MapKit

class AddPostViewController: UIViewController, UITextViewDelegate, PHPickerViewControllerDelegate {
    
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
        textField.tintColor = .black
        textField.font = .systemFont(ofSize: 18)
        textField.placeholder = "제목을 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let dividerLine1: UIImageView = {
        let line = UIImageView()
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
        imageView.backgroundColor = .lightGray
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "photo.on.rectangle.fill")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dividerLine2: UIImageView = {
        let line = UIImageView()
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
    
    private let dividerLine3: UIImageView = {
        let line = UIImageView()
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
        let image = UIImage(systemName: "map.fill")
        imageView.image = image
        imageView.tintColor = .gray
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerImageViewTapped))
        pickerImageView.addGestureRecognizer(tapGesture)
        
        updateImageStackView()
    }
    
    @objc private func pickerImageViewTapped() {
        presentImagePickerController()
    }
    
    @objc private func saveButtonTapped() {
        guard let titleText = titleTextField.text, !titleText.isEmpty else {
            showAlert(title: "제목 오류", message: "제목을 입력하세요.")
            return
        }
        
        guard let textViewText = textView.text, textViewText != textViewPlaceHolder, !textViewText.isEmpty else {
            showAlert(title: "내용 오류", message: "내용을 입력하세요.")
            return
        }
        
        viewModel.savePost(postTitle: titleText, postBody: textViewText) { result in
            switch result {
            case .success(let newPost):
                print("Add Post: \(newPost)")
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("Error add post \(error.localizedDescription)")
                self.showAlert(title: "게시물 저장 실패", message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
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
        contentView.addSubview(mapIconView)
        contentView.addSubview(mapView)
        contentView.addSubview(saveButton)
        
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
            imageScrollView.heightAnchor.constraint(equalToConstant: 104),
            
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor, constant: 16),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor, constant: -16),
            imageStackView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
            
            pickerImageView.widthAnchor.constraint(equalToConstant: 100),
            pickerImageView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
            
            
            
            pickerImageView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
            
            dividerLine2.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 16),
            dividerLine2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine2.heightAnchor.constraint(equalToConstant: 1),
            
            textView.topAnchor.constraint(equalTo: dividerLine2.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 300),
            
            remainCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            remainCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            
            dividerLine3.topAnchor.constraint(equalTo: remainCountLabel.bottomAnchor, constant: 16),
            dividerLine3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 16),
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            mapIconView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 8),
            mapIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapIconView.heightAnchor.constraint(equalToConstant: 24),
            
            mapView.topAnchor.constraint(equalTo: mapIconView.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            saveButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textCount = textView.text.count
        remainCountLabel.text = "\(textCount)/700"
        
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
            // Adjust the text view's cursor position when placeholder is set
            textView.selectedTextRange = nil
            textView.resignFirstResponder()
        } else if textView.textColor == .lightGray && textView.text != textViewPlaceHolder {
            textView.textColor = .black
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }

    
    private func updateImageStackView() {
        imageStackView.arrangedSubviews.forEach { view in
            if view != pickerImageView {
                view.removeFromSuperview()
            }
        }
        
        viewModel.selectedImages.forEach { image in
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            imageStackView.insertArrangedSubview(imageView, at: imageStackView.arrangedSubviews.count - 1)
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        viewModel.addSelectedImages(results: results) { [weak self] in
            DispatchQueue.main.async {
                self?.updateImageStackView()
            }
        }
    }
    
    private func presentImagePickerController() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}


//#Preview {
//    return UINavigationController(rootViewController: AddPostViewController(postType: PostType.lookingForSitter, viewModel: AddPostViewModel(postType: PostType.lookingForSitter)))
//}