//
//  AlbumTestViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/7/24.
//

import UIKit
import PhotosUI

class ChatAdditionalButtonsViewController: UIViewController {
    
    private let viewModel = ChatAdditionalButtonsViewModel()
    
    private var buttonViews: [ChatAdditionalButton] {
        viewModel.buttonModels.map { model in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        
        setupUI()
        
        viewModel.delegate = self
    }
    
    //MARK: Setup UI
    private func setupUI() {
        view.addSubview(additionalButtonStackView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            additionalButtonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -80),
            additionalButtonStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
        ])
    }
}

//MARK: 앨범 터치 시 포토 피커 관련 함수
extension ChatAdditionalButtonsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        Task {
            let selectedImages = await loadImages(from: results)
            print(selectedImages)
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

extension ChatAdditionalButtonsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) {
            if let image = info[.originalImage] as? UIImage {
                print(image)
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
        
        DispatchQueue.main.async {
            self.present(picker, animated: true)
        }
    }
    
    func presentCamera() {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.allowsEditing = false
        camera.cameraCaptureMode = .photo
        camera.delegate = self
        
        DispatchQueue.main.async {
            self.present(camera, animated: true)
        }
    }
    
    func presentMakePlan() {
        let makePlan = MakePlanViewController()
        DispatchQueue.main.async {
            self.present(makePlan, animated: true)
        }
    }
}
