//
//  AlbumTestViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/7/24.
//

import UIKit
import PhotosUI

class ChatAdditionalButtonsViewController: UIViewController {
    
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let chatAdditionalButtonsViewModel = ChatAdditionalButtonsViewModel()
    
    private var buttonViews: [ChatAdditionalButton] {
        chatAdditionalButtonsViewModel.buttonModels.map { model in
            let button = ChatAdditionalButton(imageName: model.imageName, titleText: model.titleText, buttonAction: UIAction { _ in model.buttonAction() })
            return button
        }
    }
    
    private lazy var additionalButtonStackView: UIStackView = {
        let additionalButtonStackView = UIStackView(arrangedSubviews: buttonViews)
        additionalButtonStackView.axis = .vertical
        additionalButtonStackView.spacing = 37
        additionalButtonStackView.alignment = .leading
        additionalButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        return additionalButtonStackView
    }()
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        var imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.preferredSymbolConfigurationForImage = imageConfig
        closeButton.configuration = buttonConfig
        closeButton.tintColor = .white.withAlphaComponent(0.85)
        closeButton.contentMode = .scaleToFill
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addAction( UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
       return closeButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        
        setupUI()
        
        chatAdditionalButtonsViewModel.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeViewController), name: NSNotification.Name("CloseChatAdditionalButtons"), object: nil)
    }
    
    @objc
    private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func closeViewController() {
        dismiss(animated: true)
    }
    
    //MARK: Setup UI
    private func setupUI() {
        view.addSubview(additionalButtonStackView)
        view.addSubview(closeButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            additionalButtonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -80),
            additionalButtonStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
            closeButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

//MARK: 앨범 터치 시 포토 피커 관련 함수
extension ChatAdditionalButtonsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        Task {
            let selectedImages = await loadImages(from: results)
            chatViewModel?.sendImageMessage(images: selectedImages, chatRoom: chatRoom)
        }
        
        picker.dismiss(animated: true)
    }
    
    private func loadImages(from results: [PHPickerResult]) async -> [UIImage] {
        var images = [UIImage]()
        
        for result in results {
            let itemProvider = result.itemProvider
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
                continue
            }
            
            if let image = await withCheckedContinuation({ continuation in
                //loadObject가 비동기적으로 동작
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }) {
                images.append(image)
            }
        }
        
        return images
    }
}

//MARK: 카메라 터치 시 카메라 관련 함수
extension ChatAdditionalButtonsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) {
            if let image = info[.originalImage] as? UIImage {
                self.chatViewModel?.sendImageMessage(images: [image], chatRoom: self.chatRoom)
            }
        }
    }
}

//MARK: viewModel에 전달할 additionalButton 함수
extension ChatAdditionalButtonsViewController: ChatAdditionalButtonsViewModelDelegate {
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .any(of: [.images, .livePhotos])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        guard let viewController = self.presentingViewController else { return }
        DispatchQueue.main.async {
            self.dismiss(animated: false) {
                viewController.present(picker, animated: true)
            }
        }
    }
    
    func presentCamera() {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.allowsEditing = false
        camera.cameraCaptureMode = .photo
        camera.delegate = self
        
        guard let viewController = self.presentingViewController else { return }
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                viewController.present(camera, animated: true)
            }
        }
    }
    
    func presentMakePlan(planType: PlanType) {
        guard let viewController = self.presentingViewController else { return }
        Task {
            let postStatus = await chatViewModel?.fetchChatPostStatus(chatRoomId: chatRoom.id)
            if postStatus == .completedTrade {
                self.dismiss(animated: true) {
                    let alert = UIAlertController(title: "약속을 만들 수 없습니다.", message: "이미 거래가 완료된 게시물입니다.", preferredStyle: .alert)
                    
                    let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                    }
                    alert.addAction(confirmAction)
                    
                    viewController.present(alert, animated: true, completion: nil)
                }
            } else {
                switch planType {
                case .leavePlan :
                    let hasLeavePlan = await chatViewModel?.fetchChatHasLeavePlan(chatRoomId: chatRoom.id) ?? true
                    if hasLeavePlan {
                        self.dismiss(animated: true) {
                            let alert = UIAlertController(title: "약속을 만들 수 없습니다.", message: "이미 위탁 약속이 있습니다. 약속을 새로 만드시려면 기존 약속을 먼저 취소해주세요.", preferredStyle: .alert)
                            
                            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                            }
                            alert.addAction(confirmAction)
                            
                            viewController.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        let makePlanViewController = MakePlanViewController(viewModel: MakePlanViewModel(planType: planType, chatRoom: chatRoom))
                        makePlanViewController.modalPresentationStyle = .fullScreen
                        makePlanViewController.viewModel.chatViewModel = chatViewModel
                        DispatchQueue.main.async {
                            self.dismiss(animated: false) {
                                viewController.present(makePlanViewController, animated: true)
                            }
                        }
                    }
                case .getBackPlan :
                    let hasGetBackPlan = await chatViewModel?.fetchChatHasLeavePlan(chatRoomId: chatRoom.id) ?? true
                    if hasGetBackPlan {
                        self.dismiss(animated: true) {
                            let alert = UIAlertController(title: "약속을 만들 수 없습니다.", message: "이미 회수 약속이 있습니다. 약속을 새로 만드시려면 기존 약속을 먼저 취소해주세요.", preferredStyle: .alert)
                            
                            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                            }
                            alert.addAction(confirmAction)
                            
                            viewController.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        let makePlanViewController = MakePlanViewController(viewModel: MakePlanViewModel(planType: planType, chatRoom: chatRoom))
                        makePlanViewController.modalPresentationStyle = .fullScreen
                        makePlanViewController.viewModel.chatViewModel = chatViewModel
                        DispatchQueue.main.async {
                            self.dismiss(animated: false) {
                                viewController.present(makePlanViewController, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}
