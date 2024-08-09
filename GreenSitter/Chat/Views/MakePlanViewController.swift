//
//  MakePlanViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/8/24.
//

import UIKit

class MakePlanViewController: UIViewController {
    
    private var viewModel = MakePlanViewModel()

    private var pages: [UIViewController] = []
    
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
        let planProgressBar = PlanProgressBar(progress: 0)
        planProgressBar.translatesAutoresizingMaskIntoConstraints = false
        return planProgressBar
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pages = [dateTimeViewController, placeViewController, finalConfirmViewController]
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: true)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        return pageViewController
    }()
    
    private lazy var dateTimeViewController: DateTimeViewController = {
        let dateTimeViewController = DateTimeViewController(viewModel: viewModel)
        return dateTimeViewController
    }()
    
    private lazy var placeViewController: UIViewController = {
        let placeViewController = UIViewController()
        placeViewController.view.backgroundColor = .blue
        return placeViewController
    }()
    
    private lazy var finalConfirmViewController: UIViewController = {
        let finalConfirmViewController = UIViewController()
        finalConfirmViewController.view.backgroundColor = .green
        return finalConfirmViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGSecondary")
        
        setupUI()
        
        viewModel.delegate = self
    }
    
    private func setupUI() {
        addChild(pageViewController)
        
        view.addSubview(navigationBar)
        view.addSubview(planProgressBar)
        view.addSubview(pageViewController.view)
        
        pageViewController.didMove(toParent: self)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            planProgressBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            planProgressBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            planProgressBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),
            planProgressBar.heightAnchor.constraint(equalToConstant: 80),
            
            pageViewController.view.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: 20),
            pageViewController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            pageViewController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),
            pageViewController.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
}

extension MakePlanViewController: MakePlanViewModelDelegate {
    func gotoNextPage() {
        planProgressBar.progress = viewModel.progress
        //        if let currentViewController = pageViewController.viewControllers?.first,
        //           let currentIndex = pages.firstIndex(of: currentViewController) {
        //            let nextIndex = (currentIndex + 1) % pages.count
        //            pageViewController.setViewControllers([pages[nextIndex]], direction: .forward, animated: true, completion: nil)
        //        }
    }
}
