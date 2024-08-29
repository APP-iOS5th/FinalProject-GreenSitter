//
//  PlanProgressBar.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/8/24.
//

import UIKit

class PlanProgressBar: UIView {
    
    var progress: Int {
        didSet {
            updateUI()
        }
    }
    
    let progressGray = UIColor(hexCode: "C6C6C6")
    let progressBlue = UIColor(hexCode: "3686D0")
    let progressDeactivateGray = UIColor(hexCode: "717171")
    
    init(progress: Int) {
        self.progress = progress
        super.init(frame: .zero)
        setupUI()
        updateUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var progressLine: UIProgressView = {
        let progressLine = UIProgressView()
        progressLine.trackTintColor = progressGray
        progressLine.progressTintColor = progressBlue
        progressLine.setProgress(Float(progress) / 2.0, animated: false)
        progressLine.translatesAutoresizingMaskIntoConstraints = false
        return progressLine
    }()
    
    private lazy var dateTimeIcon: UIImageView = {
        let dateTimeIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal))
        dateTimeIcon.clipsToBounds = true
        dateTimeIcon.layer.cornerRadius = 10
        dateTimeIcon.translatesAutoresizingMaskIntoConstraints = false
        return dateTimeIcon
    }()
    
    private lazy var placeIcon: UIImageView = {
        let placeIcon = UIImageView(image: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal))
        placeIcon.clipsToBounds = true
        placeIcon.layer.cornerRadius = 10
        placeIcon.translatesAutoresizingMaskIntoConstraints = false
        return placeIcon
    }()
    
    private lazy var finalConfirmIcon: UIImageView = {
        let finalConfirmIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal))
        finalConfirmIcon.clipsToBounds = true
        finalConfirmIcon.layer.cornerRadius = 10
        finalConfirmIcon.translatesAutoresizingMaskIntoConstraints = false
        return finalConfirmIcon
    }()
    
    private lazy var dateTimeText: UILabel = {
        let dateTimeText = UILabel()
        dateTimeText.text = "날짜 및 시간 선택"
        dateTimeText.font = UIFont.systemFont(ofSize: 10)
        dateTimeText.addCharacterSpacing(-0.025)
        dateTimeText.translatesAutoresizingMaskIntoConstraints = false
        return dateTimeText
    }()
    
    private lazy var placeText: UILabel = {
        let placeText = UILabel()
        placeText.text = "만날 장소 선택"
        placeText.font = UIFont.systemFont(ofSize: 10)
        placeText.addCharacterSpacing(-0.025)
        placeText.translatesAutoresizingMaskIntoConstraints = false
        return placeText
    }()
    
    private lazy var finalConfirmText: UILabel = {
        let finalConfirmText = UILabel()
        finalConfirmText.text = "최종 확인"
        finalConfirmText.font = UIFont.systemFont(ofSize: 10)
        finalConfirmText.addCharacterSpacing(-0.025)
        finalConfirmText.translatesAutoresizingMaskIntoConstraints = false
        return finalConfirmText
    }()
    
    private func setupUI() {
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
        progressLine.setProgress(Float(progress) / 2.0, animated: true)

        func animateIconChange(icon: UIImageView, newImage: UIImage?, backgroundColor: UIColor?) {
            UIView.transition(with: icon, duration: 0.5, options: .transitionCrossDissolve, animations: {
                icon.image = newImage
                icon.backgroundColor = backgroundColor
            }, completion: nil)
        }

        func animateTextColorChange(label: UILabel, newColor: UIColor?) {
            UIView.transition(with: label, duration: 1.0, options: .transitionCrossDissolve, animations: {
                label.textColor = newColor
            }, completion: nil)
        }

        switch progress {
        case 0:
            animateIconChange(icon: dateTimeIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: placeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))
            animateIconChange(icon: finalConfirmIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))

            animateTextColorChange(label: dateTimeText, newColor: UIColor(named: "LabelsPrimary"))
            animateTextColorChange(label: placeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: finalConfirmText, newColor: progressDeactivateGray)
        case 1:
            animateIconChange(icon: dateTimeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: placeIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: finalConfirmIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))

            animateTextColorChange(label: dateTimeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: placeText, newColor: UIColor(named: "LabelsPrimary"))
            animateTextColorChange(label: finalConfirmText, newColor: progressDeactivateGray)
        case 2:
            animateIconChange(icon: dateTimeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: placeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: finalConfirmIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)

            animateTextColorChange(label: dateTimeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: placeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: finalConfirmText, newColor: UIColor(named: "LabelsPrimary"))
        case 3:
            animateIconChange(icon: dateTimeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: placeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: finalConfirmIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)

            animateTextColorChange(label: dateTimeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: placeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: finalConfirmText, newColor: progressDeactivateGray)
        default:
            break
        }
    }

}
