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
    var isPlaceSelected: Bool
    let planType: PlanType
    
    var delegate: MakePlanViewModelDelegate?
    
    var chatViewModel: ChatViewModel?
    var chatRoom: ChatRoom
    
    var messageId: String?
    
    init(date: Date = Date(), planPlace: Location? = Location.sampleLocation, ownerNotification: Bool = true, sitterNotification: Bool = true, progress: Int = 0, isPlaceSelected: Bool = false, planType: PlanType, chatRoom: ChatRoom, messageId: String? = nil) {
        let interval = 5
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: ((calendar.component(.minute, from: date) + 5) / interval) * interval, second: 0, of: date) ?? date
        
        self.planDate = date
        self.planPlace = planPlace
        self.ownerNotification = ownerNotification
        self.sitterNotification = sitterNotification
        self.progress = progress
        self.isPlaceSelected = isPlaceSelected
        self.planType = planType
        self.chatRoom = chatRoom
        self.messageId = messageId
    }
    
    func gotoNextPage() {
        delegate?.gotoNextPage()
    }
    
    func backtoPreviousPage() {
        delegate?.backtoPreviousPage()
    }
    
    func sendPlan() {
        let plan = Plan(planId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), planDate: planDate, planPlace: planPlace, contract: nil, ownerNotification: ownerNotification, sitterNotification: sitterNotification, isAccepted: false, planType: planType)
        print("chatRoomID: \(chatRoom.id)")
        print("chatRoom.postId: \(chatRoom.postId)")
        Task {
            await chatViewModel?.sendPlanMessage(plan: plan, chatRoom: chatRoom)
            await chatViewModel?.updatePostStatus(chatRoomId: chatRoom.id, planType: planType, postId: chatRoom.postId)
        }
    }
    
    func updatePlanNotification() async {
        guard let messageId = messageId else { return }
        
        let firestoreManager = FirestoreManager()
        do {
            try await firestoreManager.updatePlanNotification(chatRoomId: chatRoom.id, messageId: messageId, ownerNotification: ownerNotification, sitterNotification: sitterNotification)
        } catch {
            print(error.localizedDescription)
        }
    }
}
