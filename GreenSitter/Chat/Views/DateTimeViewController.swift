//
//  DateTimeViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/9/24.
//

import UIKit

class DateTimeViewController: UIViewController {
    
    private var instructionText: UILabel = {
       let instructionText = UILabel()
        instructionText.text = "새싹 돌봄이와\n약속날짜/시간을 정해주세요."
        instructionText.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        instructionText.numberOfLines = 2
        instructionText.textColor = UIColor(named: "LabelsPrimary")
        instructionText.translatesAutoresizingMaskIntoConstraints = false
        return instructionText
    }()
    
    private var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.text = "Aug 15, 2024"
        dateLabel.textAlignment = .center
        dateLabel.textColor = .systemBlue
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        dateLabel.backgroundColor = UIColor(named: "FillTertiary")
        dateLabel.layer.cornerRadius = 6
        dateLabel.clipsToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    private var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.text = "12:43 AM"
        timeLabel.textAlignment = .center
        timeLabel.textColor = .systemBlue
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        timeLabel.backgroundColor = UIColor(named: "FillTertiary")
        timeLabel.layer.cornerRadius = 6
        timeLabel.clipsToBounds = true
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeLabel
    }()
    
    private var datePicker: UIDatePicker = {
       let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.backgroundColor = UIColor(named: "BGPrimary")
        datePicker.layer.cornerRadius = 13
        datePicker.clipsToBounds = true
        datePicker.layer.borderWidth = 1
        datePicker.layer.borderColor = UIColor.clear.cgColor
        datePicker.layer.shadowColor = UIColor.systemGray.cgColor
        datePicker.layer.shadowOffset = CGSize(width: 5, height: 5)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private var nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.setTitle("다음", for: .normal)
        nextButton.backgroundColor = UIColor(named: "DominentColor")
        nextButton.layer.cornerRadius = 10
        nextButton.clipsToBounds = true
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        return nextButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BGSecondary")
        
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        setupUI()
    }

    private func setupUI() {
        view.addSubview(instructionText)
        view.addSubview(dateLabel)
        view.addSubview(timeLabel)
        view.addSubview(datePicker)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            instructionText.topAnchor.constraint(equalTo: view.topAnchor),
            instructionText.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            instructionText.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 40),
            dateLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -6),
            dateLabel.widthAnchor.constraint(equalToConstant: 130),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            timeLabel.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 40),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeLabel.widthAnchor.constraint(equalToConstant: 90),
            timeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc
    private func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: sender.date)
        
        let dateLabel = self.view.subviews.compactMap { $0 as? UILabel }[1]
        let timeLabel = self.view.subviews.compactMap { $0 as? UILabel }[2]
        
        DispatchQueue.main.async {
            dateLabel.text = dateString
            timeLabel.text = timeString
        }
    }
}
