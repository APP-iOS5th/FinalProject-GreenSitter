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
    
    private let scrollView: UIScrollView = {
        let scrollView =  UIScrollView()
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
    
    let textViewPlaceHolder = "텍스트를 입력하세요."
    
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
        
        // 게시글 저장 로직 추가
        print("제목: \(titleText)")
        print("내용: \(textViewText)")
        
        // 저장 후 화면을 종료
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupLayout() {
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

            dividerLine1.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            dividerLine1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine1.heightAnchor.constraint(equalToConstant: 1),

            imageScrollView.topAnchor.constraint(equalTo: dividerLine1.bottomAnchor, constant: 20),
            imageScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageScrollView.heightAnchor.constraint(equalToConstant: 100),

            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            imageStackView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),

            pickerImageView.widthAnchor.constraint(equalToConstant: 100),
            pickerImageView.heightAnchor.constraint(equalToConstant: 100),

            dividerLine2.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 20),
            dividerLine2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine2.heightAnchor.constraint(equalToConstant: 1),

            textView.topAnchor.constraint(equalTo: dividerLine2.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),

            remainCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5),
            remainCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            remainCountLabel.heightAnchor.constraint(equalToConstant: 20),

            dividerLine3.topAnchor.constraint(equalTo: remainCountLabel.bottomAnchor, constant: 10),
            dividerLine3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerLine3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),

            mapLabel.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 20),
            mapLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            mapIconView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 10),
            mapIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapIconView.widthAnchor.constraint(equalToConstant: 70),
            mapIconView.heightAnchor.constraint(equalToConstant: 70),

            mapView.topAnchor.constraint(equalTo: mapIconView.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 300),

            saveButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
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
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count
        remainCountLabel.text = "\(characterCount)/700"
    }
    
    private func presentImagePickerController() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                guard let self = self else { return }
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        let imageView = UIImageView(image: image)
                        imageView.contentMode = .scaleAspectFill
                        imageView.clipsToBounds = true
                        imageView.translatesAutoresizingMaskIntoConstraints = false
                        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                        self.imageStackView.insertArrangedSubview(imageView, at: self.imageStackView.arrangedSubviews.count - 1)
                    }
                }
            }
        }
    }
}


#Preview {
    return UINavigationController(rootViewController: AddPostViewController())
}
