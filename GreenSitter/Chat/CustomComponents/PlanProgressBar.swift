//
//  PlanProgressBar.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/8/24.
//

import UIKit

class PlanProgressBar: UIView {
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
        dateTimeIcon.backgroundColor = .white
        dateTimeIcon.clipsToBounds = true
        dateTimeIcon.layer.cornerRadius = 10
        dateTimeIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let placeIcon = UIImageView(image: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(.progressBlue, renderingMode: .alwaysOriginal))
        placeIcon.backgroundColor = .white
        placeIcon.clipsToBounds = true
        placeIcon.layer.cornerRadius = 10
        placeIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let finalConfirmIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(.progressGray, renderingMode: .alwaysOriginal))
        finalConfirmIcon.backgroundColor = .secondarySystemBackground
        finalConfirmIcon.clipsToBounds = true
        finalConfirmIcon.layer.cornerRadius = 10
        finalConfirmIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let dateTimeText = UILabel()
        dateTimeText.text = "날짜 및 시간 선택"
        dateTimeText.font = UIFont.systemFont(ofSize: 10)
        dateTimeText.textColor = .progressDeactivateGray
        dateTimeText.addCharacterSpacing(-0.025)
        dateTimeText.translatesAutoresizingMaskIntoConstraints = false
        
        let placeText = UILabel()
        placeText.text = "만날 장소 선택"
        placeText.font = UIFont.systemFont(ofSize: 10)
        placeText.textColor = .black
        placeText.addCharacterSpacing(-0.025)
        placeText.translatesAutoresizingMaskIntoConstraints = false
        
        let finalConfirmText = UILabel()
        finalConfirmText.text = "최종 확인"
        finalConfirmText.font = UIFont.systemFont(ofSize: 10)
        finalConfirmText.textColor = .progressDeactivateGray
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
            progressLine.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 16),
            
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
            dateTimeText.topAnchor.constraint(equalTo: dateTimeIcon.bottomAnchor),
            
            placeText.centerXAnchor.constraint(equalTo: placeIcon.centerXAnchor),
            placeText.topAnchor.constraint(equalTo: placeIcon.bottomAnchor),
            
            finalConfirmText.centerXAnchor.constraint(equalTo: finalConfirmIcon.centerXAnchor),
            finalConfirmText.topAnchor.constraint(equalTo: finalConfirmIcon.bottomAnchor),
        ])
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
