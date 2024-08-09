//
//  MakePlanViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/8/24.
//

import UIKit

class MakePlanViewController: UIViewController {

    private lazy var navigationBar : UINavigationBar = {
        let backButton = UIButton()
        backButton.setTitle(" Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.addAction(UIAction { _ in
            print("backButtonTapped")
        }, for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        let navItem = UINavigationItem(title: "약속 정하기")
        navItem.leftBarButtonItem = backButtonItem
       let navigationBar = UINavigationBar()
        navigationBar.setItems([navItem], animated: true)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    private lazy var planProgressBar: PlanProgressBar = {
        let planProgressBar = PlanProgressBar()
        planProgressBar.translatesAutoresizingMaskIntoConstraints = false
        return planProgressBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGSecondary")
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(navigationBar)
        view.addSubview(planProgressBar)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            planProgressBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 16),
            planProgressBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            planProgressBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),
            
        ])
    }
}
