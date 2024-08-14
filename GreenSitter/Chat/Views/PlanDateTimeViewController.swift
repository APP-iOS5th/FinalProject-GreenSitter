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
    
    private var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
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
        nextButton.addAction(UIAction { [weak self] _ in
            guard let selectedDate = self?.datePicker.date else {
                print("date did not selected")
                return
            }
            self?.viewModel.planDate = selectedDate
            self?.viewModel.progress = 1
            self?.viewModel.gotoNextPage()
        }, for: .touchUpInside)
        setupUI()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(instructionText)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(timeLabel)
        scrollView.addSubview(datePicker)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            instructionText.topAnchor.constraint(equalTo: scrollView.topAnchor),
            instructionText.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            instructionText.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 40),
            dateLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -6),
            dateLabel.widthAnchor.constraint(equalToConstant: 130),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            timeLabel.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 40),
            timeLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 90),
            timeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            datePicker.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            datePicker.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -60),
            
            nextButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: viewModel.planDate)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: viewModel.planDate)
        
        dateLabel.text = dateString
        timeLabel.text = timeString
        
        datePicker.date = viewModel.planDate
    }
    
    @objc
    private func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: sender.date)
        
        let scrollView = self.view.subviews.compactMap { $0 as? UIScrollView }[0]
        let dateLabel = scrollView.subviews.compactMap { $0 as? UILabel }[1]
        let timeLabel = scrollView.subviews.compactMap { $0 as? UILabel }[2]
        
        DispatchQueue.main.async {
            dateLabel.text = dateString
            timeLabel.text = timeString
        }
    }
}
