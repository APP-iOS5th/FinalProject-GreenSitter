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
    
    init(date: Date = Date(), planPlace: Location? = nil, ownerNotification: Bool = true, sitterNotification: Bool = true, progress: Int = 0, isPlaceSelected: Bool = false, planType: PlanType, chatViewModel: ChatViewModel? = nil, chatRoom: ChatRoom, messageId: String? = nil) {
        let interval = 5
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
        let currentMinute = currentDateComponents.minute ?? 0
        let currentHour = currentDateComponents.hour ?? 0

        let remainder = currentMinute % interval
        var newMinute: Int
        let newHour: Int

        if remainder == 0 {
            newMinute = currentMinute
            newHour = currentHour
        } else {
            newMinute = ((currentMinute / interval) + 1) * interval
            newHour = newMinute >= 60 ? currentHour + 1 : currentHour
            if newMinute >= 60 {
                newMinute -= 60
            }
        }

        let newDate = calendar.date(
            bySettingHour: newHour,
            minute: newMinute,
            second: 0,
            of: date
        ) ?? date

        
        self.planDate = newDate
        self.planPlace = planPlace ?? chatRoom.preferredPlace
        self.ownerNotification = ownerNotification
        self.sitterNotification = sitterNotification
        self.progress = progress
        self.isPlaceSelected = isPlaceSelected
        self.planType = planType
        self.chatViewModel = chatViewModel
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
        Task {
            await chatViewModel?.sendPlanMessage(plan: plan, chatRoom: chatRoom)
            await chatViewModel?.updatePostStatusAfterMakePlan(chatRoomId: chatRoom.id, planType: planType, postId: chatRoom.postId, recipientId: chatRoom.userId)
        }
        chatRoom.postStatus = .inTrade
        if planType == .leavePlan {
            chatRoom.hasLeavePlan = true
        } else {
            chatRoom.hasGetBackPlan = true
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
    
    func cancelPlan() {
        Task {
            await chatViewModel?.updatePostStatusAfterCancelPlan(chatRoomId: chatRoom.id, planType: planType, postId: chatRoom.postId)
            await chatViewModel?.sendButtonTapped(text: "약속을 취소했습니다.", chatRoom: chatRoom)
        }
    }
}
