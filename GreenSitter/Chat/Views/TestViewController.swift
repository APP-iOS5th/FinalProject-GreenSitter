//
//  TestViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/18/24.
//

import UIKit

class TestViewController: UIViewController {
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setTitle("plusButton", for: .normal)
        plusButton.backgroundColor = .systemBlue
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addAction(UIAction { [weak self] _ in
            self?.presentChatAdditionalButtonsViewController()
        }, for: .touchUpInside)
        return plusButton
    }()
    
    private lazy var planDetailButton: UIButton = {
        let planDetailButton = UIButton()
        planDetailButton.setTitle("자세히 보기", for: .normal)
        planDetailButton.backgroundColor = .systemBlue
        planDetailButton.translatesAutoresizingMaskIntoConstraints = false
        planDetailButton.addAction(UIAction { [weak self] _ in
            let plan = Plan(planId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), planDate: Date(), planPlace: Location.sampleLocation, contract: nil, ownerNotification: true, sitterNotification: true, isAccepted: true)
            let makePlanViewModel = MakePlanViewModel(date: plan.planDate, planPlace: plan.planPlace, ownerNotification: plan.ownerNotification, sitterNotification: plan.sitterNotification, progress: 3, isPlaceSelected: true)
            self?.present(MakePlanViewController(viewModel: makePlanViewModel), animated: true)
        }, for: .touchUpInside)
        return planDetailButton
    }()
    
    private lazy var placeButton: UIButton = {
        let placeButton = UIButton()
        placeButton.setTitle("장소 보기", for: .normal)
        placeButton.backgroundColor = .systemBlue
        placeButton.translatesAutoresizingMaskIntoConstraints = false
        placeButton.addAction(UIAction { [weak self] _ in
            let plan = Plan(planId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), planDate: Date(), planPlace: Location.sampleLocation, contract: nil, ownerNotification: true, sitterNotification: true, isAccepted: true)
            guard let planPlace = plan.planPlace else { return }
            let navigationController = UINavigationController(rootViewController: PlanPlaceDetailViewController(location: planPlace))
            self?.present(navigationController, animated: true)
        }, for: .touchUpInside)
        return placeButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            if settings.authorizationStatus != .authorized {
//                print("Push notification authorization not granted.")
//            } else {
//                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//            }
//        }
    }
    
    private func setupUI() {
        view.addSubview(plusButton)
        view.addSubview(planDetailButton)
        view.addSubview(placeButton)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            plusButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -100),
            plusButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 100),
            plusButton.widthAnchor.constraint(equalToConstant: 200),
            plusButton.heightAnchor.constraint(equalToConstant: 100),
            
            planDetailButton.bottomAnchor.constraint(equalTo: plusButton.topAnchor, constant: -100),
            planDetailButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 100),
            planDetailButton.widthAnchor.constraint(equalToConstant: 200),
            planDetailButton.heightAnchor.constraint(equalToConstant: 100),
            
            placeButton.bottomAnchor.constraint(equalTo: planDetailButton.topAnchor, constant: -100),
            placeButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 100),
            placeButton.widthAnchor.constraint(equalToConstant: 200),
            placeButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func presentChatAdditionalButtonsViewController() {
        let chatAdditionalButtonsViewController = ChatAdditionalButtonsViewController()
        chatAdditionalButtonsViewController.modalPresentationStyle = .overCurrentContext
        self.present(chatAdditionalButtonsViewController, animated: true, completion: nil)
    }
}
