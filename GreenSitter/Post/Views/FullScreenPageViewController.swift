//
//  FullScreenPageViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/24/24.
//

import UIKit
import FirebaseStorage

class FullScreenPageViewController: UIPageViewController {
    private var imageUrls: [String]
    private var currentIndex: Int
    
    private let pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(imageUrls: [String], initialIndex: Int) {
        self.imageUrls = imageUrls
        self.currentIndex = initialIndex
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        let initialVC = FullScreenImageViewController()
        initialVC.loadImage(url: imageUrls[currentIndex])
        setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
        
        setupUI()
        updatePageLabel()
    }
    
    private func setupUI() {
        view.addSubview(pageLabel)
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            pageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func updatePageLabel() {
        pageLabel.text = "\(currentIndex + 1) / \(imageUrls.count)"
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension FullScreenPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard currentIndex > 0 else { return nil }
        
        let previousIndex = currentIndex - 1
        let previousVC = FullScreenImageViewController()
        previousVC.loadImage(url: imageUrls[previousIndex])
        return previousVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard currentIndex < imageUrls.count - 1 else { return nil }
        
        let nextIndex = currentIndex + 1
        let nextVC = FullScreenImageViewController()
        nextVC.loadImage(url: imageUrls[nextIndex])
        return nextVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = pageViewController.viewControllers?.first as? FullScreenImageViewController,
           let index = imageUrls.firstIndex(of: currentVC.imageUrl) {
            currentIndex = index
            updatePageLabel()
        }
    }
}

