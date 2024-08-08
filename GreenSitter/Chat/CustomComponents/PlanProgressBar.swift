//
//  PlanProgressBar.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/8/24.
//

import UIKit

class PlanProgressBar: UIStackView {
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let progressLine = UIProgressView()
         progressLine.trackTintColor = .progressGray
         progressLine.progressTintColor = .progressBlue
         progressLine.progress = 0.5
        progressLine.translatesAutoresizingMaskIntoConstraints = false
        
        let dateTimeIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal))
        
        let placeIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal))
        
        let finalConfirmIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(.progressGray, renderingMode: .alwaysOriginal))
        
        self.addSubview(progressLine)
        self.addArrangedSubview(dateTimeIcon)
        self.addArrangedSubview(placeIcon)
        self.addArrangedSubview(finalConfirmIcon)
        
        self.axis = .horizontal
        self.distribution = .equalCentering
        
        NSLayoutConstraint.activate([
            progressLine.heightAnchor.constraint(equalToConstant: 1),
            progressLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            dateTimeIcon.heightAnchor.constraint(equalToConstant: 16),
            dateTimeIcon.widthAnchor.constraint(equalToConstant: 16),
            
            placeIcon.heightAnchor.constraint(equalToConstant: 16),
            placeIcon.widthAnchor.constraint(equalToConstant: 16),
            
            finalConfirmIcon.heightAnchor.constraint(equalToConstant: 16),
            finalConfirmIcon.widthAnchor.constraint(equalToConstant: 16),
        ])
    }
}
