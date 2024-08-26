//
//  ChatMessageTableViewImageCell.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/21/24.
//

import UIKit

protocol ChatMessageTableViewImageCellDelegate: AnyObject {
    func imageViewTapped(images: [UIImage], index: Int)
}

class ChatMessageTableViewImageCell: UITableViewCell {
    weak var delegate: ChatMessageTableViewImageCellDelegate?
    
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
    
    var imageSize: CGFloat?
    
    var images: [UIImage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.updateBubbleView()
            }
        }
    }
    
    private lazy var firstImageView: UIImageView = {
       let firstImageView = UIImageView()
        firstImageView.layer.cornerRadius = 10
        firstImageView.backgroundColor = .white
        firstImageView.clipsToBounds = true
        firstImageView.contentMode = .scaleAspectFit
        firstImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        firstImageView.isUserInteractionEnabled = true
        firstImageView.addGestureRecognizer(tapGesture)
        return firstImageView
    }()
    
    private lazy var secondImageView: UIImageView = {
       let secondImageView = UIImageView()
        secondImageView.layer.cornerRadius = 10
        secondImageView.backgroundColor = .white
        secondImageView.clipsToBounds = true
        secondImageView.contentMode = .scaleAspectFit
        secondImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        secondImageView.isUserInteractionEnabled = true
        secondImageView.addGestureRecognizer(tapGesture)
        return secondImageView
    }()
    
    private lazy var thirdImageView: UIImageView = {
       let thirdImageView = UIImageView()
        thirdImageView.layer.cornerRadius = 10
        thirdImageView.backgroundColor = .white
        thirdImageView.clipsToBounds = true
        thirdImageView.contentMode = .scaleAspectFit
        thirdImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        thirdImageView.isUserInteractionEnabled = true
        thirdImageView.addGestureRecognizer(tapGesture)
        return thirdImageView
    }()
    
    private lazy var fourthImageView: UIImageView = {
       let fourthImageView = UIImageView()
        fourthImageView.layer.cornerRadius = 10
        fourthImageView.backgroundColor = .white
        fourthImageView.clipsToBounds = true
        fourthImageView.contentMode = .scaleAspectFit
        fourthImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        fourthImageView.isUserInteractionEnabled = true
        fourthImageView.addGestureRecognizer(tapGesture)
        return fourthImageView
    }()
    
    lazy var morePhotosLabel: UILabel = {
        let morePhotosLabel = UILabel()
        morePhotosLabel.layer.cornerRadius = 10
        morePhotosLabel.backgroundColor = .white
        morePhotosLabel.clipsToBounds = true
        morePhotosLabel.translatesAutoresizingMaskIntoConstraints = false
        morePhotosLabel.numberOfLines = 0
        morePhotosLabel.textAlignment = .center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMorePhotosLabelTap(_:)))
        morePhotosLabel.isUserInteractionEnabled = true
        morePhotosLabel.addGestureRecognizer(tapGesture)
        return morePhotosLabel
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        

        // bubbleView의 너비를 동적으로 계산
        let bubbleViewWidth = bubbleView.bounds.width
        let spacing = 10
        var imageSize: CGFloat
        
        switch images.count {
        case 1...3:
            imageSize = (bubbleViewWidth - CGFloat(spacing * ( images.count - 1 )))  / CGFloat(images.count)
        default:
            imageSize = (bubbleViewWidth - CGFloat(spacing)) / 2
        }
        
        bubbleView.subviews.forEach { NSLayoutConstraint.deactivate($0.constraints) }
        
        switch images.count {
        case 0:
            break
        case 1:
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                firstImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        case 2:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                firstImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                
                secondImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                secondImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                secondImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                secondImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        case 3:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            bubbleView.addSubview(thirdImageView)
        case 4:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            bubbleView.addSubview(thirdImageView)
            bubbleView.addSubview(fourthImageView)
            
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                
                secondImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                secondImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                secondImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                
                thirdImageView.topAnchor.constraint(equalTo: firstImageView.bottomAnchor, constant: 10),
                thirdImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                thirdImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                thirdImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                
                
                fourthImageView.topAnchor.constraint(equalTo: secondImageView.bottomAnchor, constant: 10),
                fourthImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                fourthImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                fourthImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        default:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            bubbleView.addSubview(thirdImageView)
            bubbleView.addSubview(morePhotosLabel)
            
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                
                secondImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                secondImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                secondImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                
                thirdImageView.topAnchor.constraint(equalTo: firstImageView.bottomAnchor, constant: 10),
                thirdImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                thirdImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                thirdImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                
                morePhotosLabel.topAnchor.constraint(equalTo: secondImageView.bottomAnchor, constant: 10),
                morePhotosLabel.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                morePhotosLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                morePhotosLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        }
        
        NSLayoutConstraint.activate([
            firstImageView.heightAnchor.constraint(equalToConstant: imageSize),
            secondImageView.heightAnchor.constraint(equalToConstant: imageSize),
            thirdImageView.heightAnchor.constraint(equalToConstant: imageSize),
            fourthImageView.heightAnchor.constraint(equalToConstant: imageSize),
            morePhotosLabel.heightAnchor.constraint(equalToConstant: imageSize),
        ])
        
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        print("setupUI")
//        contentView.subviews.forEach { $0.removeFromSuperview() }
//        // 제약조건 재설정을 위한 기존 제약조건 제거
//        contentView.subviews.forEach { NSLayoutConstraint.deactivate($0.constraints) }
//        NSLayoutConstraint.deactivate(contentView.constraints)
//        NSLayoutConstraint.deactivate(bubbleView.constraints)
        
        // 제약조건 재설정을 위한 기존 제약조건 제거
        NSLayoutConstraint.deactivate(contentView.constraints)
        // profileImageView와 isReadLabel 제거
        profileImageView.removeFromSuperview()
        isReadLabel.removeFromSuperview()
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(timeLabel)
        
        if isIncoming {
            contentView.addSubview(profileImageView)
            
            // timeLabel이 충분한 공간을 차지하도록 우선순위 설정
            timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            
            NSLayoutConstraint.activate([
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                profileImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 52),
                profileImageView.heightAnchor.constraint(equalToConstant: 52),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 5),
                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100)
            ])
        } else {
            contentView.addSubview(isReadLabel)
            
            // isReadLabel과 timeLabel이 충분한 공간을 차지하도록 우선순위 설정
            isReadLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            isReadLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

            NSLayoutConstraint.activate([
                isReadLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                isReadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 100),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: isReadLabel.trailingAnchor, constant: 5),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5),
                bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            ])
        }
        setupImageView()
    }
    
    private func setupImageView() {
        print("setupImageView")
        bubbleView.subviews.forEach { NSLayoutConstraint.deactivate($0.constraints) }
        bubbleView.subviews.forEach { $0.removeFromSuperview() }
//        NSLayoutConstraint.deactivate(bubbleView.constraints)
        
        switch images.count {
        case 0:
            break
        case 1:
            bubbleView.addSubview(firstImageView)
            
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                firstImageView.heightAnchor.constraint(equalTo: firstImageView.widthAnchor),
                firstImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        case 2:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                firstImageView.heightAnchor.constraint(equalTo: firstImageView.widthAnchor),
                firstImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                
                secondImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                secondImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                secondImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                secondImageView.heightAnchor.constraint(equalTo: secondImageView.widthAnchor),
                secondImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        case 3:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            bubbleView.addSubview(thirdImageView)
        case 4:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            bubbleView.addSubview(thirdImageView)
            bubbleView.addSubview(fourthImageView)
            
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                firstImageView.heightAnchor.constraint(equalTo: firstImageView.widthAnchor),
                
                secondImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                secondImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                secondImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                secondImageView.heightAnchor.constraint(equalTo: secondImageView.widthAnchor),
                
                thirdImageView.topAnchor.constraint(equalTo: firstImageView.bottomAnchor, constant: 10),
                thirdImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                thirdImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                thirdImageView.heightAnchor.constraint(equalTo: thirdImageView.widthAnchor),
                thirdImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                
                
                fourthImageView.topAnchor.constraint(equalTo: secondImageView.bottomAnchor, constant: 10),
                fourthImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                fourthImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                fourthImageView.heightAnchor.constraint(equalTo: secondImageView.widthAnchor),
                fourthImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        default:
            bubbleView.addSubview(firstImageView)
            bubbleView.addSubview(secondImageView)
            bubbleView.addSubview(thirdImageView)
            bubbleView.addSubview(morePhotosLabel)
            
            NSLayoutConstraint.activate([
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                firstImageView.heightAnchor.constraint(equalTo: firstImageView.widthAnchor),
                
                secondImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                secondImageView.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                secondImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                secondImageView.heightAnchor.constraint(equalTo: secondImageView.widthAnchor),
                
                thirdImageView.topAnchor.constraint(equalTo: firstImageView.bottomAnchor, constant: 10),
                thirdImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                thirdImageView.trailingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: -5),
                thirdImageView.heightAnchor.constraint(equalTo: thirdImageView.widthAnchor),
                thirdImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                
                morePhotosLabel.topAnchor.constraint(equalTo: secondImageView.bottomAnchor, constant: 10),
                morePhotosLabel.leadingAnchor.constraint(equalTo: bubbleView.centerXAnchor, constant: 5),
                morePhotosLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                morePhotosLabel.heightAnchor.constraint(equalTo: secondImageView.widthAnchor),
                morePhotosLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            ])
        }
    }
    
    private func updateBubbleView() {
        print("updateBubbleView")
        switch images.count {
        case 0:
            break
        case 1:
            firstImageView.image = images[0]
        case 2:
            firstImageView.image = images[0]
            secondImageView.image = images[1]
        case 3:
            firstImageView.image = images[0]
            secondImageView.image = images[1]
            thirdImageView.image = images[2]
        case 4:
            firstImageView.image = images[0]
            secondImageView.image = images[1]
            thirdImageView.image = images[2]
            fourthImageView.image = images[3]
        default:
            firstImageView.image = images[0]
            secondImageView.image = images[1]
            thirdImageView.image = images[2]
            morePhotosLabel.text = "+ \(images.count - 3)\n더보기"
        }
    }
    
    @objc
    private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView, let image = imageView.image else { return }
        
        guard let index = images.firstIndex(of: image) else { return }
        
        delegate?.imageViewTapped(images: images, index: index)
    }
    
    @objc
    private func handleMorePhotosLabelTap(_ sender: UITapGestureRecognizer) {
        guard let _ = sender.view as? UILabel else { return }
        
        delegate?.imageViewTapped(images: images, index: 3)
    }
}



