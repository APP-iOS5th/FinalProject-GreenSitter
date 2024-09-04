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
    func presentMakePlan(planType: PlanType)
}

class ChatAdditionalButtonsViewModel {
    
    var delegate: ChatAdditionalButtonsViewModelDelegate?
    
    var buttonModels: [ChatAdditionalButtonModel] {
        return [
            ChatAdditionalButtonModel(imageName: "photo.on.rectangle", titleText: "앨범", buttonAction: albumButtonTapped),
            ChatAdditionalButtonModel(imageName: "camera.fill", titleText: "카메라", buttonAction: cameraButtonTapped),
            ChatAdditionalButtonModel(imageName: "tray.and.arrow.up", titleText: "위탁 약속 정하기", buttonAction: { [weak self] in self?.planButtonTapped(planType: .leavePlan) }),
            ChatAdditionalButtonModel(imageName: "tray.and.arrow.down", titleText: "회수 약속 정하기", buttonAction: { [weak self] in self?.planButtonTapped(planType: .getBackPlan) })
        ]
    }
    
    //MARK: Button Action Functions
    func albumButtonTapped() {
        delegate?.presentPhotoPicker()
    }
    
    func cameraButtonTapped() {
        delegate?.presentCamera()
    }
    
    func planButtonTapped(planType: PlanType) {
        delegate?.presentMakePlan(planType: planType)
    }
}
