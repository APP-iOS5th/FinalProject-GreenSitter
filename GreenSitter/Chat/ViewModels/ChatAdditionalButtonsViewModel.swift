//
//  ChatAdditionalButtonViewModel.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/7/24.
//

import Foundation

protocol ChatAdditionalButtonsViewModelDelegate {
    func presentPhotoPicker()
    func presentCamera()
    func presentMakePlan()
}

class ChatAdditionalButtonsViewModel {
    
    var delegate: ChatAdditionalButtonsViewModelDelegate?
    
    var buttonModels: [ChatAdditionalButtonModel] {
        return [
            ChatAdditionalButtonModel(imageName: "photo.on.rectangle", titleText: "앨범", buttonAction: albumButtonTapped),
            ChatAdditionalButtonModel(imageName: "camera.fill", titleText: "카메라", buttonAction: cameraButtonTapped),
            ChatAdditionalButtonModel(imageName: "calendar", titleText: "약속 정하기", buttonAction: planButtonTapped)
        ]
    }
    
    //MARK: Button Action Functions
    func albumButtonTapped() {
        delegate?.presentPhotoPicker()
    }
    
    func cameraButtonTapped() {
        delegate?.presentCamera()
    }
    
    func planButtonTapped() {
        delegate?.presentMakePlan()
    }
}
