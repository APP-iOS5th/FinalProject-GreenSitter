//
//  MakePlanViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/8/24.
//

import UIKit

class MakePlanViewController: UIViewController {
    
    private var viewModel: MakePlanViewModel
    
    private var pages: [UIViewController]
    
    init(viewModel: MakePlanViewModel = MakePlanViewModel(), pages: [UIViewController] = []) {
        self.viewModel = viewModel
        self.pages = pages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var backButton : UIButton = {
        let backButton = UIButton()
        backButton.setTitle(" Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.addAction(UIAction { [weak self] _ in
            if self?.viewModel.progress == 0 || self?.viewModel.progress == 3 {
                self?.dismiss(animated: true)
                return
            } else {
                self?.viewModel.progress -= 1
                self?.backtoPreviousPage()
            }
        }, for: .touchUpInside)
        return backButton
    }()
    
    private lazy var navigationBar : UINavigationBar = {
        let backButtonItem = UIBarButtonItem(customView: backButton)
        let navItem = UINavigationItem(title: viewModel.progress == 3 ? "약속 정보" : "약속 정하기")
        navItem.leftBarButtonItem = backButtonItem
       let navigationBar = UINavigationBar()
        navigationBar.setItems([navItem], animated: true)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    private lazy var planProgressBar: PlanProgressBar = {
        let planProgressBar = PlanProgressBar(progress: viewModel.progress)
        planProgressBar.translatesAutoresizingMaskIntoConstraints = false
        return planProgressBar
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        if viewModel.progress == 3 {
            pages = [finalConfirmViewController]
        } else {
            pages = [dateTimeViewController, planPlaceViewController, finalConfirmViewController]
        }
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: true)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        return pageViewController
    }()
    
    private lazy var dateTimeViewController: PlanDateTimeViewController = {
        let dateTimeViewController = PlanDateTimeViewController(viewModel: viewModel)
        return dateTimeViewController
    }()
    
    private lazy var planPlaceViewController: UIViewController = {
        let planPlaceViewController = PlanPlaceViewController(viewModel: viewModel)
        return planPlaceViewController
    }()
    
    private lazy var finalConfirmViewController: UIViewController = {
        let finalConfirmViewController = FinalConfirmPlanViewController(viewModel: viewModel)
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
            
            pageViewController.view.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: 40),
            pageViewController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension MakePlanViewController: MakePlanViewModelDelegate {
    func gotoNextPage() {
        guard viewModel.progress < pages.count else { return }
        planProgressBar.progress = viewModel.progress
        pageViewController.setViewControllers([pages[viewModel.progress]], direction: .forward, animated: true, completion: nil)
    }
    
    func backtoPreviousPage() {
        guard viewModel.progress >= 0 else { return }
        planProgressBar.progress = viewModel.progress
        pageViewController.setViewControllers([pages[viewModel.progress]], direction: .reverse, animated: true, completion: nil)
    }
}
