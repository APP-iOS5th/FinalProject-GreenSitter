//
//  MakePlanViewModel.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/9/24.
//

import Foundation

protocol MakePlanViewModelDelegate {
    func gotoNextPage()
    func backtoPreviousPage()
}

class MakePlanViewModel {
    var planDate: Date
    var planPlace: Location?
    var ownerNotification: Bool
    var sitterNotification: Bool
    var progress: Int
    
    var delegate: MakePlanViewModelDelegate?
    
    init(date: Date = Date(), planPlace: Location? = nil, ownerNotification: Bool = true, sitterNotification: Bool = true, progress: Int = 0) {
        let interval = 5
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: ((calendar.component(.minute, from: date) + 5) / interval) * interval, second: 0, of: date) ?? date
        
        self.planDate = date
        self.planPlace = planPlace
        self.ownerNotification = ownerNotification
        self.sitterNotification = sitterNotification
        self.progress = progress
    }
    
    func gotoNextPage() {
        delegate?.gotoNextPage()
    }
    
    func backtoPreviousPage() {
        delegate?.backtoPreviousPage()
    }
    
    func sendPlan() {
        let plan = Plan(planId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), planDate: planDate, planPlace: planPlace, contract: nil, ownerNotification: ownerNotification, sitterNotification: sitterNotification, isAccepted: false)
        print(plan)
    }
}
