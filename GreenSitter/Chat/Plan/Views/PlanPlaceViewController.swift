//
//  PlanPlaceViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/12/24.
//

import UIKit

class PlanPlaceViewController: UIViewController {
    
    init(viewModel: MakePlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModel: MakePlanViewModel
    
    private var isDealHereButtonSelected: Bool = false
    
    private lazy var planPlace: Location? = Location.sampleLocation
    
    private lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 76, right: 10)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var instructionText: UILabel = {
       let instructionText = UILabel()
        instructionText.text = "새싹 돌봄이와\n만날 장소를 정해주세요."
        instructionText.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        instructionText.numberOfLines = 2
        instructionText.textColor = UIColor(named: "LabelsPrimary")
        instructionText.translatesAutoresizingMaskIntoConstraints = false
        return instructionText
    }()
    
    private lazy var placeText: UILabel = {
        let placeText = UILabel()
        placeText.textAlignment = .center
        placeText.font = UIFont.systemFont(ofSize: 17)
        placeText.textColor = .systemGreen
        placeText.translatesAutoresizingMaskIntoConstraints = false
        placeText.text = viewModel.planPlace?.placeName
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
    
    private lazy var dealHereButton: UIButton = {
        let dealHereButton = UIButton()
        dealHereButton.layer.cornerRadius = 10
        dealHereButton.layer.borderWidth = 1
        dealHereButton.layer.borderColor = UIColor(named: "SeparatorsNonOpaque")?.cgColor
        dealHereButton.clipsToBounds = true
        dealHereButton.backgroundColor = UIColor(named: "BGPrimary")
        dealHereButton.translatesAutoresizingMaskIntoConstraints = false
        dealHereButton.addAction(UIAction { [weak self] _ in
            self?.dealHereButtonTapped()
        }, for: .touchUpInside)
        if viewModel.planPlace == nil {
            dealHereButton.isHidden = true
        }
        return dealHereButton
    }()
    
    private lazy var anotherPlaceText: UILabel = {
        let anotherPlaceText = UILabel()
        anotherPlaceText.text = "그 외 장소에서 거래할게요!"
        anotherPlaceText.textAlignment = .center
        anotherPlaceText.font = UIFont.systemFont(ofSize: 17)
        anotherPlaceText.textColor = UIColor(named: "LabelsPrimary")
        anotherPlaceText.translatesAutoresizingMaskIntoConstraints = false
        return anotherPlaceText
    }()
    
    private lazy var anotherPlaceButton: UIButton = {
        let anotherPlaceButton = UIButton()
        anotherPlaceButton.layer.cornerRadius = 10
        anotherPlaceButton.layer.borderWidth = 1
        anotherPlaceButton.layer.borderColor = UIColor(named: "SeparatorsNonOpaque")?.cgColor
        anotherPlaceButton.clipsToBounds = true
        anotherPlaceButton.backgroundColor = UIColor(named: "BGPrimary")
        anotherPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        anotherPlaceButton.addAction(UIAction { [weak self] _ in
            self?.anotherPlaceButtonTapped()
        }, for: .touchUpInside)
        return anotherPlaceButton
    }()
    
    private lazy var nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.setTitle("다음", for: .normal)
        nextButton.backgroundColor = .systemGray3
        nextButton.layer.cornerRadius = 10
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addAction(UIAction { [weak self] _ in
            guard let planPlace = self?.planPlace else {
                print("planPlace is nil")
                return
            }
            self?.viewModel.planPlace = planPlace
            self?.viewModel.progress = 2
            self?.viewModel.gotoNextPage()
        }, for: .touchUpInside)
        nextButton.isEnabled = isDealHereButtonSelected
        return nextButton
    }()
    
    private lazy var bottomPaddingView: UIView = {
       let bottomPaddingView = UIView()
        bottomPaddingView.backgroundColor = .clear
        bottomPaddingView.translatesAutoresizingMaskIntoConstraints = false
        return bottomPaddingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BGSecondary")
        
        setupUI()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(instructionText)
        scrollView.addSubview(dealHereButton)
        scrollView.addSubview(anotherPlaceButton)
        scrollView.addSubview(bottomPaddingView)
        
        dealHereButton.addSubview(placeText)
        dealHereButton.addSubview(dealHereText)
        anotherPlaceButton.addSubview(anotherPlaceText)

        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            instructionText.topAnchor.constraint(equalTo: scrollView.topAnchor),
            instructionText.layoutMarginsGuide.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            instructionText.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            
            dealHereButton.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 40),
            dealHereButton.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            dealHereButton.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            dealHereButton.heightAnchor.constraint(equalToConstant: 150),
            
            placeText.centerXAnchor.constraint(equalTo: dealHereButton.centerXAnchor),
            placeText.centerYAnchor.constraint(equalTo: dealHereButton.centerYAnchor, constant: -16),
            
            dealHereText.centerXAnchor.constraint(equalTo: dealHereButton.centerXAnchor),
            dealHereText.centerYAnchor.constraint(equalTo: dealHereButton.centerYAnchor, constant: 16),
            
            anotherPlaceButton.topAnchor.constraint(equalTo: dealHereButton.bottomAnchor, constant: 20),
            anotherPlaceButton.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            anotherPlaceButton.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            anotherPlaceButton.heightAnchor.constraint(equalToConstant: 150),
            
            anotherPlaceText.centerXAnchor.constraint(equalTo: anotherPlaceButton.centerXAnchor),
            anotherPlaceText.centerYAnchor.constraint(equalTo: anotherPlaceButton.centerYAnchor),
            
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 76),
            bottomPaddingView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            bottomPaddingView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30),
            bottomPaddingView.topAnchor.constraint(equalTo: anotherPlaceButton.bottomAnchor),
            bottomPaddingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 30),
            nextButton.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor, constant: -30)
        ])
    }
    
    private func dealHereButtonTapped(){
        DispatchQueue.main.async {
            if self.isDealHereButtonSelected {
                self.dealHereButton.layer.borderColor = UIColor(named: "SeparatorsNonOpaque")?.cgColor
                self.dealHereButton.layer.borderWidth = 1
                self.placeText.font = UIFont.systemFont(ofSize: 17)
                self.dealHereText.font = UIFont.systemFont(ofSize: 17)
                self.nextButton.backgroundColor = .systemGray3
            } else {
                self.dealHereButton.layer.borderColor = UIColor.systemGreen.cgColor
                self.dealHereButton.layer.borderWidth = 4
                self.placeText.font = UIFont.systemFont(ofSize: 17, weight: .bold)
                self.dealHereText.font = UIFont.systemFont(ofSize: 17, weight: .bold)
                self.nextButton.backgroundColor = UIColor(named: "DominentColor")
            }
            self.isDealHereButtonSelected.toggle()
            self.nextButton.isEnabled = self.isDealHereButtonSelected
        }
        
    }
    
    private func anotherPlaceButtonTapped(){
        
    }
}
