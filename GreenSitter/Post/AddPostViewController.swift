//
//  AddPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/13/24.
//

import UIKit
import MapKit

class AddPostViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
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
    
    private let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.backward")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    private let pickerImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .lightGray
        image.tintColor = .gray
        image.image = UIImage(systemName: "photo.on.rectangle.fill")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
        pickerImageView.isUserInteractionEnabled = true // 이미지 뷰 상호작용 활성화
    }
    
    @objc private func pickerImageViewTapped() {
        presentImagePickerController()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleTextField)
        contentView.addSubview(dividerLine1)
        contentView.addSubview(pickerImageView)
        contentView.addSubview(dividerLine2)
        contentView.addSubview(textView)
        contentView.addSubview(remainCountLabel)
        contentView.addSubview(dividerLine3)
        contentView.addSubview(mapLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            
            dividerLine1.bottomAnchor.constraint(equalTo: titleTextField.topAnchor, constant: 35),
            dividerLine1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dividerLine1.widthAnchor.constraint(equalToConstant: 360),
            dividerLine1.heightAnchor.constraint(equalToConstant: 1),
            
            pickerImageView.widthAnchor.constraint(equalToConstant: 100),
            pickerImageView.heightAnchor.constraint(equalToConstant: 100),
            pickerImageView.topAnchor.constraint(equalTo: dividerLine1.bottomAnchor, constant: 20),
            pickerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            dividerLine2.topAnchor.constraint(equalTo: pickerImageView.bottomAnchor, constant: 20),
            dividerLine2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dividerLine2.widthAnchor.constraint(equalToConstant: 360),
            dividerLine2.heightAnchor.constraint(equalToConstant: 1),
            
            textView.topAnchor.constraint(equalTo: dividerLine2.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            remainCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5),
            remainCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            remainCountLabel.heightAnchor.constraint(equalToConstant: 20),
            
            dividerLine3.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 60),
            dividerLine3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dividerLine3.widthAnchor.constraint(equalToConstant: 360),
            dividerLine3.heightAnchor.constraint(equalToConstant: 1),
            
            mapLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapLabel.bottomAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 30),
            
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 20),
            mapView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 250),
           
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapTextView(_ sender: Any) {
        view.endEditing(true)
    }
    
    private func updateCountLabel(characterCount: Int) {
        remainCountLabel.text = "\(characterCount)/700"
        remainCountLabel.asColor(targetString: "\(characterCount)", color: characterCount == 0 ? .lightGray : .blue)
    }
    
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

extension AddPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
            updateCountLabel(characterCount: 0)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)

        let characterCount = newString.count
        guard characterCount <= 700 else { return false }
        updateCountLabel(characterCount: characterCount)

        return true
    }
}

extension UILabel {
    func asColor(targetString: String, color: UIColor?) {
        let fullText = text ?? ""
        let range = (fullText as NSString).range(of: targetString)
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: color as Any, range: range)
        attributedText = attributedString
    }
}

#Preview {
    return UINavigationController(rootViewController: AddPostViewController())
}
