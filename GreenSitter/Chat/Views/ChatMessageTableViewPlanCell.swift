//
//  ChatMessageTableViewPlanCell.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/22/24.
//

import UIKit

class ChatMessageTableViewPlanCell: UITableViewCell {
    var detailButtonAction: (() -> Void)?
    var placeButtonAction: (() -> Void)?
    
    var isIncoming: Bool = false {
        didSet {
            setupUI()
        }
    }
    
    var isRead: Bool = false {
        didSet {
            isReadLabel.text = isRead ? "" : "읽지 않음"
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "약속을 만들었습니다."
        label.textColor = UIColor(named: "LabelsPrimary")
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var planDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(named: "LabelsPrimary")
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var planTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textColor = UIColor(named: "LabelsPrimary")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var planPlaceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(named: "LabelsPrimary")
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setTitle("자세히 보기", for: .normal)
        button.backgroundColor = .dominent
        button.layer.cornerRadius = 7
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var placeButton: UIButton = {
        let button = UIButton()
        button.setTitle("장소 보기", for: .normal)
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor(named: "ComplementaryColor")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(placeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BGPrimary")
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo7")
        
        return imageView
    }()
    
    // TODO: - 오전 12시에 날짜 출력
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .fillTertiary
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
        label.text = "2024년 8월 19일"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "오후 1:43"
        label.textColor = .labelsSecondary
        label.font = UIFont.systemFont(ofSize: 11)
        
        return label
    }()
    
    lazy var isReadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .complementary
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        bubbleView.addSubview(titleLabel)
        bubbleView.addSubview(planDateLabel)
        bubbleView.addSubview(planTimeLabel)
        bubbleView.addSubview(planPlaceLabel)
        bubbleView.addSubview(detailButton)
        bubbleView.addSubview(placeButton)
        contentView.addSubview(bubbleView)
        contentView.addSubview(timeLabel)
        
        // 제약조건 재설정을 위한 기존 제약조건 제거
        NSLayoutConstraint.deactivate(contentView.constraints)
        
        if isIncoming {
            contentView.addSubview(profileImageView)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 15),
                titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                titleLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                planDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                planDateLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                planDateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                planDateLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                planTimeLabel.topAnchor.constraint(equalTo: planDateLabel.bottomAnchor, constant: 5),
                planTimeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                planTimeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                planTimeLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                planPlaceLabel.topAnchor.constraint(equalTo: planTimeLabel.bottomAnchor, constant: 5),
                planPlaceLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                planPlaceLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                planPlaceLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                detailButton.topAnchor.constraint(equalTo: planPlaceLabel.bottomAnchor, constant: 15),
                detailButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                detailButton.heightAnchor.constraint(equalToConstant: 35),
                detailButton.widthAnchor.constraint(equalToConstant: 100),

                placeButton.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: 5),
                placeButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                placeButton.heightAnchor.constraint(equalToConstant: 35),
                placeButton.widthAnchor.constraint(equalToConstant: 100),
                placeButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -15),
                
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                profileImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 52),
                profileImageView.heightAnchor.constraint(equalToConstant: 52),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
                bubbleView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 5),
                timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100)
            ])
        } else {
            contentView.addSubview(isReadLabel)
            
            NSLayoutConstraint.activate([
                isReadLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                isReadLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 100),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: isReadLabel.trailingAnchor, constant: 5),
                
                titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 15),
                titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                titleLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                planDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                planDateLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                planDateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                planDateLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                planTimeLabel.topAnchor.constraint(equalTo: planDateLabel.bottomAnchor, constant: 5),
                planTimeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                planTimeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                planTimeLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                planPlaceLabel.topAnchor.constraint(equalTo: planTimeLabel.bottomAnchor, constant: 5),
                planPlaceLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
                planPlaceLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
                planPlaceLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                
                detailButton.topAnchor.constraint(equalTo: planPlaceLabel.bottomAnchor, constant: 15),
                detailButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                detailButton.heightAnchor.constraint(equalToConstant: 35),
                detailButton.widthAnchor.constraint(equalToConstant: 100),
                
                placeButton.topAnchor.constraint(equalTo: detailButton.bottomAnchor, constant: 5),
                placeButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                placeButton.heightAnchor.constraint(equalToConstant: 35),
                placeButton.widthAnchor.constraint(equalToConstant: 100),
                placeButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -15),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5),
                bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            ])
        }
    }
    
    @objc
    func detailButtonTapped() {
        detailButtonAction?()
    }
    
    @objc
    func placeButtonTapped() {
        placeButtonAction?()
    }
}
