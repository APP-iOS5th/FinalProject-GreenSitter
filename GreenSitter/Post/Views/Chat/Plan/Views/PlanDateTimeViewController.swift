//
//  DateTimeViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/9/24.
//

import UIKit

class PlanDateTimeViewController: UIViewController {
    
    init(viewModel: MakePlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModel: MakePlanViewModel
    
    private lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 76, right: 10)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var instructionText: UILabel = {
       let instructionText = UILabel()
        instructionText.text = "새싹 돌봄이와\n약속날짜/시간을 정해주세요."
        instructionText.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        instructionText.numberOfLines = 2
        instructionText.textColor = UIColor(named: "LabelsPrimary")
        instructionText.translatesAutoresizingMaskIntoConstraints = false
        return instructionText
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textAlignment = .center
        dateLabel.textColor = .systemBlue
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        dateLabel.backgroundColor = UIColor(named: "FillTertiary")
        dateLabel.layer.cornerRadius = 6
        dateLabel.clipsToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.textColor = .systemBlue
        timeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        timeLabel.backgroundColor = UIColor(named: "FillTertiary")
        timeLabel.layer.cornerRadius = 6
        timeLabel.clipsToBounds = true
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeLabel
    }()
    
    private lazy var datePicker: UIDatePicker = {
       let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        datePicker.minimumDate = Date()
        datePicker.date = viewModel.planDate
        datePicker.backgroundColor = UIColor(named: "BGPrimary")
        datePicker.layer.cornerRadius = 13
        datePicker.clipsToBounds = true
        datePicker.layer.borderWidth = 1
        datePicker.layer.borderColor = UIColor.clear.cgColor
        datePicker.layer.shadowColor = UIColor.systemGray.cgColor
        datePicker.layer.shadowOffset = CGSize(width: 5, height: 5)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addAction(UIAction { [weak self] _ in
            self?.updateLabel()
        }, for: .valueChanged)
        return datePicker
    }()
    
    private lazy var bottomPaddingView: UIView = {
       let bottomPaddingView = UIView()
        bottomPaddingView.backgroundColor = .clear
        bottomPaddingView.translatesAutoresizingMaskIntoConstraints = false
        return bottomPaddingView
    }()
    
    private lazy var nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.setTitle("다음", for: .normal)
        nextButton.backgroundColor = UIColor(named: "DominentColor")
        nextButton.layer.cornerRadius = 10
        nextButton.clipsToBounds = true
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addAction(UIAction { [weak self] _ in
            guard let selectedDate = self?.datePicker.date else {
                print("date did not selected")
                return
            }
            self?.viewModel.planDate = selectedDate
            self?.viewModel.progress = 1
            self?.viewModel.gotoNextPage()
        }, for: .touchUpInside)
        return nextButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BGSecondary")
        
        setupUI()
        updateLabel()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(instructionText)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(timeLabel)
        scrollView.addSubview(datePicker)
        scrollView.addSubview(bottomPaddingView)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            instructionText.topAnchor.constraint(equalTo: scrollView.topAnchor),
            instructionText.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            instructionText.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            dateLabel.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 40),
            dateLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -6),
            dateLabel.widthAnchor.constraint(equalToConstant: 130),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            timeLabel.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 40),
            timeLabel.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            timeLabel.widthAnchor.constraint(equalToConstant: 90),
            timeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            datePicker.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 76),
            bottomPaddingView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            bottomPaddingView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            bottomPaddingView.topAnchor.constraint(equalTo: datePicker.bottomAnchor),
            bottomPaddingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            nextButton.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30)
        ])
    }
    
    private func updateLabel() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: datePicker.date)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: datePicker.date)
        
        DispatchQueue.main.async {
            self.dateLabel.text = dateString
            self.timeLabel.text = timeString
        }
    }
}
