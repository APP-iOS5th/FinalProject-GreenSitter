//
//  PlanProgressBar.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/8/24.
//

import UIKit

class PlanProgressBar: UIView {
    
    var progress: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    init(progress: Int) {
        super.init(frame: .zero)
        self.progress = progress
        setupUI()
        updateUI()
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
        dateTimeIcon.clipsToBounds = true
        dateTimeIcon.layer.cornerRadius = 10
        dateTimeIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let placeIcon = UIImageView(image: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal))
        placeIcon.clipsToBounds = true
        placeIcon.layer.cornerRadius = 10
        placeIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let finalConfirmIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(.progressGray, renderingMode: .alwaysOriginal))
        finalConfirmIcon.clipsToBounds = true
        finalConfirmIcon.layer.cornerRadius = 10
        finalConfirmIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let dateTimeText = UILabel()
        dateTimeText.text = "날짜 및 시간 선택"
        dateTimeText.font = UIFont.systemFont(ofSize: 10)
        dateTimeText.addCharacterSpacing(-0.025)
        dateTimeText.translatesAutoresizingMaskIntoConstraints = false
        
        let placeText = UILabel()
        placeText.text = "만날 장소 선택"
        placeText.font = UIFont.systemFont(ofSize: 10)
        placeText.addCharacterSpacing(-0.025)
        placeText.translatesAutoresizingMaskIntoConstraints = false
        
        let finalConfirmText = UILabel()
        finalConfirmText.text = "최종 확인"
        finalConfirmText.font = UIFont.systemFont(ofSize: 10)
        finalConfirmText.addCharacterSpacing(-0.025)
        finalConfirmText.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(progressLine)
        self.addSubview(dateTimeIcon)
        self.addSubview(placeIcon)
        self.addSubview(finalConfirmIcon)
        self.addSubview(dateTimeText)
        self.addSubview(placeText)
        self.addSubview(finalConfirmText)
        
        
        NSLayoutConstraint.activate([
            progressLine.heightAnchor.constraint(equalToConstant: 1),
            progressLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            progressLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            progressLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            dateTimeIcon.heightAnchor.constraint(equalToConstant: 20),
            dateTimeIcon.widthAnchor.constraint(equalToConstant: 20),
            dateTimeIcon.centerXAnchor.constraint(equalTo: progressLine.leadingAnchor),
            dateTimeIcon.centerYAnchor.constraint(equalTo: progressLine.centerYAnchor),
            
            placeIcon.heightAnchor.constraint(equalToConstant: 20),
            placeIcon.widthAnchor.constraint(equalToConstant: 20),
            placeIcon.centerXAnchor.constraint(equalTo: progressLine.centerXAnchor),
            placeIcon.centerYAnchor.constraint(equalTo: progressLine.centerYAnchor),
            
            finalConfirmIcon.heightAnchor.constraint(equalToConstant: 20),
            finalConfirmIcon.widthAnchor.constraint(equalToConstant: 20),
            finalConfirmIcon.centerXAnchor.constraint(equalTo: progressLine.trailingAnchor),
            finalConfirmIcon.centerYAnchor.constraint(equalTo: progressLine.centerYAnchor),
            
            dateTimeText.centerXAnchor.constraint(equalTo: dateTimeIcon.centerXAnchor),
            dateTimeText.topAnchor.constraint(equalTo: dateTimeIcon.bottomAnchor, constant: 5),
            
            placeText.centerXAnchor.constraint(equalTo: placeIcon.centerXAnchor),
            placeText.topAnchor.constraint(equalTo: placeIcon.bottomAnchor, constant: 5),
            
            finalConfirmText.centerXAnchor.constraint(equalTo: finalConfirmIcon.centerXAnchor),
            finalConfirmText.topAnchor.constraint(equalTo: finalConfirmIcon.bottomAnchor, constant: 5),
        ])
    }
    
    private func updateUI() {
        let progressLine = self.subviews.compactMap { $0 as? UIProgressView }.first
        progressLine?.progress = Float(progress) / 2.0
        
        let dateTimeIcon = self.subviews.compactMap { $0 as? UIImageView }[0]
        let placeIcon = self.subviews.compactMap { $0 as? UIImageView }[1]
        let finalConfirmIcon = self.subviews.compactMap { $0 as? UIImageView }[2]
        
        let dateTimeText = self.subviews.compactMap { $0 as? UILabel }[0]
        let placeText = self.subviews.compactMap { $0 as? UILabel }[1]
        let finalConfirmText = self.subviews.compactMap { $0 as? UILabel }[2]
        
        switch progress {
        case 0:
            dateTimeIcon.image = UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            dateTimeIcon.backgroundColor = .white
            placeIcon.image = UIImage(systemName: "circle")?.withTintColor(.progressGray, renderingMode: .alwaysOriginal)
            placeIcon.backgroundColor = UIColor(named: "BGSecondary")
            finalConfirmIcon.image = UIImage(systemName: "circle")?.withTintColor(.progressGray, renderingMode: .alwaysOriginal)
            finalConfirmIcon.backgroundColor = UIColor(named: "BGSecondary")
            
            dateTimeText.textColor = UIColor(named: "LabelsPrimary")
            placeText.textColor = .progressDeactivateGray
            finalConfirmText.textColor = .progressDeactivateGray
        case 1:
            dateTimeIcon.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            dateTimeIcon.backgroundColor = .white
            placeIcon.image = UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            placeIcon.backgroundColor = .white
            finalConfirmIcon.image = UIImage(systemName: "circle")?.withTintColor(.progressGray, renderingMode: .alwaysOriginal)
            finalConfirmIcon.backgroundColor = UIColor(named: "BGSecondary")
            
            dateTimeText.textColor = .progressDeactivateGray
            placeText.textColor = UIColor(named: "LabelsPrimary")
            finalConfirmText.textColor = .progressDeactivateGray
        case 2:
            dateTimeIcon.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            dateTimeIcon.backgroundColor = .white
            placeIcon.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            placeIcon.backgroundColor = .white
            finalConfirmIcon.image = UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            finalConfirmIcon.backgroundColor = .white
            
            dateTimeText.textColor = .progressDeactivateGray
            placeText.textColor = .progressDeactivateGray
            finalConfirmText.textColor = UIColor(named: "LabelsPrimary")
        case 3:
            dateTimeIcon.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            dateTimeIcon.backgroundColor = .white
            placeIcon.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            placeIcon.backgroundColor = .white
            finalConfirmIcon.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal)
            finalConfirmIcon.backgroundColor = .white
            
            dateTimeText.textColor = .progressDeactivateGray
            placeText.textColor = .progressDeactivateGray
            finalConfirmText.textColor = .progressDeactivateGray
        default:
            break
        }
    }
}

extension UILabel {
    //자간 수정 기능
    func addCharacterSpacing(_ value: Double = -0.03) {
        let kernValue = self.font.pointSize * CGFloat(value)
        guard let text = text, !text.isEmpty else { return }
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        attributedText = string
    }
}
