//
//  ImageDetailViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/22/24.
//

import UIKit

class ImageDetailCollectionViewController: UIViewController {
    
    private let images: [UIImage]
    
    private var index: Int
    
    init(images: [UIImage], index: Int) {
        self.images = images
        self.index = index
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
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        return backButton
    }()
    
    private lazy var navigationBar : UINavigationBar = {
        let backButtonItem = UIBarButtonItem(customView: backButton)
        let navItem = UINavigationItem(title: "이미지 (\(index + 1)/\(images.count))")
        navItem.leftBarButtonItem = backButtonItem
       let navigationBar = UINavigationBar()
        navigationBar.setItems([navItem], animated: true)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.backgroundColor = UIColor(named: "BGSecondary")
        navigationBar.shadowImage = UIImage()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageDetailCollectionViewCell.self, forCellWithReuseIdentifier: "ImageDetailCollectionViewCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(navigationBar)
        view.addSubview(collectionView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
    }
    
    private func updateNavigationBar() {
        navigationItem.title = "이미지 (\(index)/\(images.count)"
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageDetailCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageDetailCollectionViewCell", for: indexPath) as! ImageDetailCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}
