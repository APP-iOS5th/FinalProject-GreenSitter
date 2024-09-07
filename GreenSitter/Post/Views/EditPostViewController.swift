//
//  EditPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/20/24.
//

import UIKit
import PhotosUI
import MapKit

class EditPostViewController: UIViewController, PHPickerViewControllerDelegate {
    
    private let post: Post
    private var viewModel: EditPostViewModel
    private var overlayPostMapping: [MKCircle: Post] = [:]
    private var isUploading = false
    private var throttleTimer: Timer?
    
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
        textField.tintColor = .labelsSecondary
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
        view.backgroundColor = .systemBackground
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
    
    private let mapLabelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let leftStackView = UIStackView()
        leftStackView.axis = .horizontal
        leftStackView.alignment = .center
        leftStackView.spacing = 8 // Space between image and text
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let symbolImageView = UIImageView()
        let symbolImage = UIImage(systemName: "mappin.and.ellipse")
        symbolImageView.image = symbolImage?.withTintColor(.labelsSecondary, renderingMode: .alwaysOriginal)
        
        let textLabel = UILabel()
        textLabel.text = "거래 희망 장소를 선택하세요!"
        textLabel.font = .systemFont(ofSize: 17)
        textLabel.textColor = .labelsSecondary
        
        leftStackView.addArrangedSubview(symbolImageView)
        leftStackView.addArrangedSubview(textLabel)
        
        let arrowImageView = UIImageView()
        let arrowImage = UIImage(systemName: "chevron.right")
        arrowImageView.image = arrowImage?.withTintColor(.labelsSecondary, renderingMode: .alwaysOriginal)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(leftStackView)
        button.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            leftStackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            leftStackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
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
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .labelsSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "이 위치는 500m 반경 이내의 지역이 표시됩니다."
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("작성완료", for: .normal)
        button.backgroundColor = .dominent
        button.isEnabled = true
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
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
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPrimary
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerImageViewTapped))
        pickerImageView.addGestureRecognizer(tapGesture)
        
        // 기존 이미지를 로드
        loadExistingImages()
        updateImageStackView()
        configureMapView(with: post)
        
        updateSaveButtonState()
        titleTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        titleTextField.delegate = self
        textView.delegate = self
        mapView.delegate = self
        
        hideKeyboard()
        
        let initialCharacterCount = textView.text.count
        remainCountLabel.text = "\(initialCharacterCount)/700"
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
        
        
        let address = viewModel.selectedPost.location?.address
        let placeName = viewModel.selectedPost.location?.placeName
        print("ADDRESS: \(String(describing: address)), placeName: \(String(describing: placeName))")
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
        configureMapView(with: viewModel.selectedPost)
        
        let initialCharacterCount = textView.text.count
        remainCountLabel.text = "\(initialCharacterCount)/700"
    }
    
    @objc private func pickerImageViewTapped() {
        presentImagePickerController()
    }
    
    @objc private func saveButtonTapped() {
        // 업로드 중이거나 쓰로틀 타이머가 동작 중이면 클릭 이벤트 무시
        guard !isUploading, throttleTimer == nil else { return }
        
        isUploading = true
        saveButton.isEnabled = false
        
        // 쓰로틀 타이머 설정: 1초 동안 중복 클릭 방지
        throttleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.throttleTimer = nil // 타이머가 끝나면 다시 클릭 가능
        }
        
        guard validateInputs() else {
            isUploading = false
            saveButton.isEnabled = true
            throttleTimer?.invalidate()
            throttleTimer = nil
            return
        }
        
        guard let currentUser = LoginViewModel.shared.user else {
            print("User ID is not available")
            isUploading = false
            saveButton.isEnabled = true
            throttleTimer?.invalidate()
            throttleTimer = nil
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        viewModel.updatePost(postTitle: titleTextField.text!, postBody: textView.text) { [weak self] result in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                // 작업이 끝난 후 다시 초기화
                self?.isUploading = false
                self?.saveButton.isEnabled = true
                self?.throttleTimer?.invalidate()
                self?.throttleTimer = nil
                
                switch result {
                case .success:
                    self?.showAlertWithNavigation(title: "성공", message: "게시글이 수정되었습니다.")
                case .failure(let error):
                    self?.showAlert(title: "게시물 저장 실패", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlertWithNavigation(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func validateInputs() -> Bool {
        var isValid = true
        
        if titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            titleTextField.attributedPlaceholder = NSAttributedString(string: "제목을 입력하세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
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
    
    private func setupLayout() {
        self.title = post.postType.rawValue
        navigationItem.leftBarButtonItem = closeButton
        
        titleTextField.text = post.postTitle
        textView.text = post.postBody
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(dividerLine1)
        contentView.addSubview(imageScrollView)
        contentView.addSubview(dividerLine2)
        contentView.addSubview(textView)
        contentView.addSubview(remainCountLabel)
        contentView.addSubview(dividerLine3)
        contentView.addSubview(mapLabelButton)
        contentView.addSubview(mapView)
        contentView.addSubview(saveButton)
        contentView.addSubview(descriptionLabel)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        mapLabelButton.addTarget(self, action: #selector(mapLabelButtonTapped), for: .touchUpInside)
        
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
            imageScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
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
            
            mapLabelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapLabelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapLabelButton.topAnchor.constraint(equalTo: dividerLine3.bottomAnchor, constant: 10),
            mapLabelButton.heightAnchor.constraint(equalToConstant: 60),
            
            mapView.topAnchor.constraint(equalTo: mapLabelButton.bottomAnchor, constant: 12),
            mapView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            mapView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            
            saveButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("Picker did finish picking. Results count: \(results.count)")
        
        picker.dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let error = error {
                        print("Error loading image: \(error)")
                        return
                    }
                    
                    guard let image = image as? UIImage else { return }
                    
                    DispatchQueue.main.async {
                        // View model에 이미지 추가
                        self?.viewModel.selectedImages.append(image)
                        self?.viewModel.addedImages.append(image)
                        // UI 업데이트
                        self?.addImageToStackView(image, "")
                    }
                }
            }
        }
    }
    
    
    private func addImageToStackView(_ image: UIImage, _ str:String?) {
        DispatchQueue.main.async {
            let existingImages = self.imageStackView.arrangedSubviews.compactMap { ($0 as? UIImageView)?.image }
            if existingImages.contains(image) {
                return
            }
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            let deleteButton = UIButton(type: .custom)
            deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            deleteButton.tintColor = .red
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            //            deleteButton.addTarget(self, action: #selector(self.deleteImage(_:)), for: .touchUpInside)
            if let str = str, !str.isEmpty {
                deleteButton.addAction(UIAction { [weak self] _ in
                    guard let self = self else { return }
                    deleteImageBy(str: str, sender: deleteButton)
                }, for: .touchUpInside)
            } else {
                deleteButton.addTarget(self, action: #selector(self.deleteImage(_:)), for: .touchUpInside)
            }
            
            
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
            
            if let pickerImageViewIndex = self.imageStackView.arrangedSubviews.firstIndex(of: self.pickerImageView) {
                self.imageStackView.insertArrangedSubview(containerView, at: pickerImageViewIndex + 1)
            } else {
                self.imageStackView.addArrangedSubview(containerView)
            }
            
            self.updateImageStackView()
        }
    }
    
    func deleteImageBy(str: String, sender: UIButton) {
        guard let containerView = sender.superview else { return }
        guard let containerViewIndex = imageStackView.arrangedSubviews.firstIndex(of: containerView) else {
            return
        }
        if let idx = viewModel.postImageURLs.firstIndex(of: str) {
            viewModel.imageURLsToDelete.append(viewModel.postImageURLs[idx])
            containerView.removeFromSuperview()
        }
        //        let originalImageViewIndex: Int = Int(containerViewIndex) - 1
        updateImageStackView()
    }
    
    @objc private func deleteImage(_ sender: UIButton) {
        print("before: \(viewModel.postImageURLs)")
        guard let containerView = sender.superview else { return }
        guard let containerViewIndex = imageStackView.arrangedSubviews.firstIndex(of: containerView) else {
            return
        }
        let originalImageViewIndex: Int = Int(containerViewIndex) - 1
        viewModel.imageURLsToDelete.append(viewModel.postImageURLs[originalImageViewIndex])
        containerView.removeFromSuperview()
        updateImageStackView()
    }
    
    
    private func loadExistingImages() {
        viewModel.loadExistingImages(from: viewModel.selectedPost.postImages ?? []) { _ in
            DispatchQueue.main.async {
                self.updateUIWithLoadedImages()
            }
        }
    }
    
    private func updateUIWithLoadedImages() {
        for urlString in viewModel.selectedImageURLs { // URL 배열을 가져옴
            loadImageFromURL(urlString) { [weak self] (image, str) in
                guard let image = image else { return }
                self?.addImageToStackView(image, str)
            }
        }
    }
    // URL로부터 UIImage를 로드하는 함수
    private func loadImageFromURL(_ urlString: String, completion: @escaping (UIImage?, String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil, nil)
                return
            }
            completion(image, urlString)
        }.resume()
    }
    
    private func updateImageStackView() {
        pickerImageView.isHidden = false
        imageScrollView.contentSize = CGSize(width: imageStackView.frame.width, height: imageStackView.frame.height)
    }
    
    private func presentImagePickerController() {
        let numberOfImages = imageStackView.arrangedSubviews.count - 1 // -1 to exclude pickerImageView
        
        if numberOfImages >= 10 {
            showAlert(title: "이미지 초과", message: "최대 10장의 이미지만 업로드할 수 있습니다.")
            return
        }
        
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
        
        if characterCount > 700 {
            textView.deleteBackward()
        }
        
        updateSaveButtonState()
    }
    
    func resetTextViewFocus() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = ""
            textView.textColor = .labelsPrimary
        } else {
            textView.textColor = .labelsPrimary
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
    
    //MARK: - mapLabelButton 탭하면 MainPostListVC로 이동하는 메서
    
    @objc private func mapLabelButtonTapped() {
        let searchMapVC = SearchMapViewController()
        searchMapVC.editPostViewModel = viewModel
        let navigationVC = UINavigationController(rootViewController: searchMapVC)
        
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true, completion: nil)
    }
}

//MARK: - MKMapViewDelegate

extension EditPostViewController: MKMapViewDelegate {
    
    private func configureMapView(with post: Post) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        overlayPostMapping.removeAll()
        guard let latitude = post.location?.latitude,
              let longitude = post.location?.longitude else { return }
        
        let circleCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // make random Center
        let randomOffset = generateRandomOffset(for: circleCenter, radius: 500)
        let randomCenter = CLLocationCoordinate2D (
            latitude: circleCenter.latitude + randomOffset.latitudeDelta,
            longitude: circleCenter.longitude + randomOffset.longitudeDelta
        )
        
        let circle = MKCircle(center: randomCenter, radius: 500)
        
        // setRegion
        DispatchQueue.main.async {
            let region = MKCoordinateRegion(center: randomCenter, latitudinalMeters: 1500, longitudinalMeters: 1500)
            self.mapView.setRegion(region, animated: false)
        }
        
        // 맵 뷰에 오버레이 추가하기 전에, post 값을 circle 키에 넣기
        overlayPostMapping[circle] = post
        mapView.addOverlay(circle)  // MKOverlayRenderer 메소드 호출
        
        let annotation = CustomAnnotation(postType: post.postType, coordinate: randomCenter)
        mapView.addAnnotation(annotation)  // MKAnnotationView
        
    }
    
    // 실제 위치(center) 기준으로 반경 내의 무작위 좌표를 새로운 중심점으로 설정
    func generateRandomOffset(for center: CLLocationCoordinate2D, radius: Double) -> (latitudeDelta: Double, longitudeDelta: Double) {
        let earthRadius: Double = 6378137 // meters
        let dLat = (radius / earthRadius) * (180 / .pi)
        let dLong = dLat / cos(center.latitude * .pi / 180)
        
        let randomLatDelta = Double.random(in: -dLat...dLat)
        let randomLongDelta = Double.random(in: -dLong...dLong)
        
        return (latitudeDelta: randomLatDelta, longitudeDelta: randomLongDelta)
    }
    
    // MKAnnotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
        } else {
            annotationView?.annotation = annotation
        }
        
        // postType 따라서 어노테이션에 이미지 다르게 적용
        let sesacImage: UIImage!
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        
        switch annotation.postType {
        case .lookingForSitter:
            sesacImage = UIImage(named: "lookingForSitterIcon")
        case .offeringToSitter:
            sesacImage = UIImage(named: "offeringToSitterIcon")
        default:
            sesacImage = UIImage(systemName: "mappin.circle.fill")
        }
        
        sesacImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage
        
        return annotationView
    }
    
    
    // MKOverlayRenderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            //            print("rendererFor methods: dict: \(overlayPostMapping)")
            
            // 딕셔너리로부터 해당 circleOverlay에 저장된 Post 가져오기
            if let post = overlayPostMapping[circleOverlay] {
                // 오버레이 색 적용
                switch post.postType {
                case .lookingForSitter:
                    circleRenderer.fillColor = UIColor.complementary.withAlphaComponent(0.5)
                case .offeringToSitter:
                    circleRenderer.fillColor = UIColor.dominent.withAlphaComponent(0.5)
                }
            } else {
                print("post is nil")
                circleRenderer.fillColor = UIColor.gray.withAlphaComponent(0.5) // Default color
            }
            
            circleRenderer.strokeColor = .separatorsNonOpaque
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
}
// MARK: -UITextFieldDelegate,UITextViewDelegate

extension EditPostViewController: UITextFieldDelegate, UITextViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSaveButtonState()
        return true
    }
    // Save 버튼의 상태를 업데이트하는 메서드
    private func updateSaveButtonState() {
        let titleTextFieldIsNotEmpty = !(titleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let textViewIsNotEmpty = !(textView.text.trimmingCharacters(in: .whitespaces).isEmpty)
        
        if titleTextFieldIsNotEmpty && textViewIsNotEmpty {
            saveButton.backgroundColor = .dominent
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = .fillSecondary
            saveButton.isEnabled = false
        }
    }
}
