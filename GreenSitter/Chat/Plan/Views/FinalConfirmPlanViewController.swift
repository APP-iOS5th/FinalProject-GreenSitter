//
//  ConfirmPlanViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/12/24.
//

import UIKit

class FinalConfirmPlanViewController: UIViewController {
    
    init(viewModel: MakePlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModel: MakePlanViewModel
    
    private lazy var currentId: String? = {
        viewModel.chatViewModel?.userId
    }()
    
    private lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 10)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var cautionTextStackView: UIStackView = {
       let cautionTitleLabel = UILabel()
        cautionTitleLabel.text = "서로 배려하는 소비자/새싹 돌봄이로 노력해주세요!\n"
        cautionTitleLabel.addCharacterSpacing(-0.043)
        cautionTitleLabel.numberOfLines = 3
        cautionTitleLabel.textColor = .systemGreen
        cautionTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        cautionTitleLabel.lineBreakMode = .byCharWrapping
        let firstLabel = UILabel()
        firstLabel.text = "1. 약속 시간을 지켜주세요."
        firstLabel.addCharacterSpacing(-0.043)
        firstLabel.numberOfLines = 2
        firstLabel.textColor = UIColor(named: "LabelsPrimary")
        firstLabel.font = UIFont.systemFont(ofSize: 15)
        firstLabel.lineBreakMode = .byCharWrapping
        let secondLabel = UILabel()
        secondLabel.text = "2. 약속 시간보다 늦으면, 사전에 연락해주세요."
        secondLabel.addCharacterSpacing(-0.043)
        secondLabel.numberOfLines = 2
        secondLabel.textColor = UIColor(named: "LabelsPrimary")
        secondLabel.font = UIFont.systemFont(ofSize: 15)
        secondLabel.lineBreakMode = .byCharWrapping
        
        let cautionTextStackView = UIStackView(arrangedSubviews: [cautionTitleLabel, firstLabel, secondLabel])
        cautionTextStackView.axis = .vertical
        cautionTextStackView.spacing = 5
        cautionTextStackView.backgroundColor = UIColor(named: "FillTertiary")
        cautionTextStackView.layoutMargins = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        cautionTextStackView.isLayoutMarginsRelativeArrangement = true
        cautionTextStackView.layer.cornerRadius = 14
        cautionTextStackView.clipsToBounds = true
        cautionTextStackView.translatesAutoresizingMaskIntoConstraints = false
        return cautionTextStackView
    }()
    
    private lazy var dateTimeTitle: UILabel = {
       let dateTimeTitle = UILabel()
        dateTimeTitle.text = "약속 날짜 / 시간"
        dateTimeTitle.addCharacterSpacing(-0.043)
        dateTimeTitle.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        dateTimeTitle.translatesAutoresizingMaskIntoConstraints = false
        return dateTimeTitle
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
    
    private lazy var placeTitle: UILabel = {
       let placeTitle = UILabel()
        placeTitle.text = "약속 장소"
        placeTitle.addCharacterSpacing(-0.043)
        placeTitle.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        placeTitle.translatesAutoresizingMaskIntoConstraints = false
        return placeTitle
    }()
    
    private lazy var placeText: UILabel = {
        let placeText = UILabel()
        placeText.textAlignment = .center
        placeText.font = UIFont.systemFont(ofSize: 17)
        placeText.textColor = .systemGreen
        placeText.translatesAutoresizingMaskIntoConstraints = false
        return placeText
    }()
    
    private lazy var dealHereText: UILabel = {
        let dealHereText = UILabel()
        dealHereText.text = "여기서 거래할게요!"
        dealHereText.textAlignment = .center
        dealHereText.font = UIFont.systemFont(ofSize: 17)
        dealHereText.textColor = UIColor(named: "LabelsPrimary")
        dealHereText.translatesAutoresizingMaskIntoConstraints = false
        return dealHereText
    }()
    
    private lazy var dealHereView: UIView = {
        let dealHereView = UIView()
        dealHereView.layer.cornerRadius = 10
        dealHereView.layer.borderWidth = 1
        dealHereView.layer.borderColor = UIColor(named: "SeparatorsNonOpaque")?.cgColor
        dealHereView.clipsToBounds = true
        dealHereView.backgroundColor = UIColor(named: "BGPrimary")
        dealHereView.translatesAutoresizingMaskIntoConstraints = false
        return dealHereView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "tree"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var transportAdviceStackView: UIStackView = {
        let transportAdviceLabel = UILabel()
        transportAdviceLabel.text = "해당 식물이 크거나 무거워 운송 수단이 필요할 수 있습니다.\n차량 등 적절한 운송 수단을 고려해주세요."
        transportAdviceLabel.numberOfLines = 3
        transportAdviceLabel.addCharacterSpacing(-0.043)
        transportAdviceLabel.lineBreakMode = .byCharWrapping
        transportAdviceLabel.textColor = .systemRed
        transportAdviceLabel.font = UIFont.systemFont(ofSize: 15)
        transportAdviceLabel.addCharacterSpacing(-0.043)
        
        let transportAdviceStackView = UIStackView()
        transportAdviceStackView.backgroundColor = UIColor(named: "FillTertiary")
        transportAdviceStackView.layoutMargins = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        transportAdviceStackView.isLayoutMarginsRelativeArrangement = true
        transportAdviceStackView.layer.cornerRadius = 12
        transportAdviceStackView.clipsToBounds = true
        transportAdviceStackView.addArrangedSubview(transportAdviceLabel)
        transportAdviceStackView.translatesAutoresizingMaskIntoConstraints = false
        return transportAdviceStackView
    }()
    
    private lazy var notificationSwitch: UISwitch = {
        let notificationSwitch = UISwitch()
        if currentId == viewModel.chatRoom.postUserId {
            notificationSwitch.isOn = viewModel.ownerNotification
        } else {
            notificationSwitch.isOn = viewModel.sitterNotification
        }
        notificationSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return notificationSwitch
    }()
    
    private lazy var notificationStackView: UIStackView = {
        let notificationLabel = UILabel()
        notificationLabel.text = "약속 시간 30분 전 알림"
        notificationLabel.textColor = UIColor(named: "LabelsPrimary")
        notificationLabel.font = UIFont.systemFont(ofSize: 17)
        notificationLabel.addCharacterSpacing(-0.043)
        
       let notificationStackView = UIStackView(arrangedSubviews: [notificationLabel])
        notificationStackView.axis = .horizontal
        notificationStackView.backgroundColor = UIColor(named: "BGPrimary")
        notificationStackView.layer.cornerRadius = 10
        notificationStackView.clipsToBounds = true
        notificationStackView.layoutMargins = UIEdgeInsets(top: 6.5, left: 16, bottom: 6.5, right: 16)
        notificationStackView.isLayoutMarginsRelativeArrangement = true
        notificationStackView.translatesAutoresizingMaskIntoConstraints = false
        return notificationStackView
    }()
    
    private lazy var bottomPaddingView: UIView = {
       let bottomPaddingView = UIView()
        bottomPaddingView.backgroundColor = .clear
        bottomPaddingView.translatesAutoresizingMaskIntoConstraints = false
        return bottomPaddingView
    }()
    
    private lazy var offeringButton: UIButton = {
        let offeringButton = UIButton()
        offeringButton.setTitle("약속 제안하기", for: .normal)
        offeringButton.backgroundColor = UIColor(named: "DominentColor")
        offeringButton.layer.cornerRadius = 10
        offeringButton.clipsToBounds = true
        offeringButton.translatesAutoresizingMaskIntoConstraints = false
        offeringButton.addAction(UIAction { [weak self] _ in
            guard let isNotificationSwitchOn = self?.notificationSwitch.isOn else {
                print("notificationSwitch is wrong")
                return
            }
            if self?.currentId == self?.viewModel.chatRoom.postUserId {
                self?.viewModel.ownerNotification = isNotificationSwitchOn
            } else {
                self?.viewModel.sitterNotification = isNotificationSwitchOn
            }
            self?.viewModel.progress = 3
            self?.viewModel.sendPlan()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        return offeringButton
    }()
    
    private lazy var editingButton: UIButton = {
        let editingButton = UIButton()
        editingButton.setTitle("수정하기", for: .normal)
        editingButton.backgroundColor = .systemBlue
        editingButton.layer.cornerRadius = 10
        editingButton.clipsToBounds = true
        editingButton.translatesAutoresizingMaskIntoConstraints = false
        editingButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.progress = 0
            self?.viewModel.backtoPreviousPage()
        }, for: .touchUpInside)
        return editingButton
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 10
        buttonStackView.distribution = .fillEqually
        buttonStackView.backgroundColor = UIColor(named: "BGPrimary")
        buttonStackView.layoutMargins = UIEdgeInsets(top: 16, left: 30, bottom: 16, right: 30)
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        if viewModel.progress == 3 {
            buttonStackView.isHidden = true
        }
        return buttonStackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BGSecondary")
        
        setupUI()
        updateLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maskPath = UIBezierPath(roundedRect: buttonStackView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        
        buttonStackView.layer.mask = maskLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabel()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(cautionTextStackView)
        scrollView.addSubview(dateTimeTitle)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(timeLabel)
        scrollView.addSubview(placeTitle)
        scrollView.addSubview(dealHereView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(transportAdviceStackView)
        scrollView.addSubview(notificationStackView)
        scrollView.addSubview(bottomPaddingView)
        
        dealHereView.addSubview(placeText)
        dealHereView.addSubview(dealHereText)
        notificationStackView.addArrangedSubview(notificationSwitch)
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(offeringButton)
        buttonStackView.addArrangedSubview(editingButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            cautionTextStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            cautionTextStackView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            cautionTextStackView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            dateTimeTitle.topAnchor.constraint(equalTo: cautionTextStackView.bottomAnchor, constant: 35),
            dateTimeTitle.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
            dateTimeTitle.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            dateLabel.topAnchor.constraint(equalTo: dateTimeTitle.bottomAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -6),
            dateLabel.widthAnchor.constraint(equalToConstant: 130),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            timeLabel.topAnchor.constraint(equalTo: dateTimeTitle.bottomAnchor, constant: 15),
            timeLabel.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            timeLabel.widthAnchor.constraint(equalToConstant: 90),
            timeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            placeTitle.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 25),
            placeTitle.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            placeTitle.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            dealHereView.topAnchor.constraint(equalTo: placeTitle.bottomAnchor, constant: 15),
            dealHereView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            dealHereView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            dealHereView.heightAnchor.constraint(equalToConstant: 150),
            
            placeText.centerXAnchor.constraint(equalTo: dealHereView.centerXAnchor),
            placeText.centerYAnchor.constraint(equalTo: dealHereView.centerYAnchor, constant: -16),
            
            dealHereText.centerXAnchor.constraint(equalTo: dealHereView.centerXAnchor),
            dealHereText.centerYAnchor.constraint(equalTo: dealHereView.centerYAnchor, constant: 16),
            
            imageView.topAnchor.constraint(equalTo: dealHereView.bottomAnchor, constant: 90),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            transportAdviceStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            transportAdviceStackView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            transportAdviceStackView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            notificationStackView.topAnchor.constraint(equalTo: transportAdviceStackView.bottomAnchor, constant: 40),
            notificationStackView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            notificationStackView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            offeringButton.heightAnchor.constraint(equalToConstant: 44),
            editingButton.heightAnchor.constraint(equalToConstant: 44),
            
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 150),
            bottomPaddingView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            bottomPaddingView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            bottomPaddingView.topAnchor.constraint(equalTo: notificationStackView.bottomAnchor),
            bottomPaddingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
        
    }
    
    private func updateLabel() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: viewModel.planDate)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: viewModel.planDate)
        
        dateLabel.text = dateString
        timeLabel.text = timeString
        
        placeText.text = viewModel.planPlace?.placeName
    }
    
    @objc
    private func switchValueChanged(_ sender: UISwitch) {
        if currentId == viewModel.chatRoom.postUserId {
            viewModel.ownerNotification = sender.isOn
        } else {
            viewModel.sitterNotification = sender.isOn
        }
    }
}
