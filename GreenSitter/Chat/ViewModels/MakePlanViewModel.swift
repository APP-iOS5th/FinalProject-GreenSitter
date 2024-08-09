//
//  MakePlanViewModel.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/9/24.
//

import Foundation

protocol MakePlanViewModelDelegate {
    func gotoNextPage()
}

class MakePlanViewModel {
    var planDate: Date
    var planPlace: Location?
//    var contract: Contract
    var ownerNotification: Bool
    var sitterNotification: Bool
    var progress: Int
    
    var delegate: MakePlanViewModelDelegate?
    
    init(planDate: Date = Date(), planPlace: Location? = nil, ownerNotification: Bool = true, sitterNotification: Bool = true, progress: Int = 0) {
        self.planDate = planDate
        self.planPlace = planPlace
        self.ownerNotification = ownerNotification
        self.sitterNotification = sitterNotification
        self.progress = progress
    }
    
    func gotoNextPage() {
        delegate?.gotoNextPage()
    }
}
