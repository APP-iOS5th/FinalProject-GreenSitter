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
    
    private var planPlace: Location? = Location.sampleLocation
    
    private var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var instructionText: UILabel = {
       let instructionText = UILabel()
        instructionText.text = "새싹 돌봄이와\n만날 장소를 정해주세요."
        instructionText.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        instructionText.numberOfLines = 2
        instructionText.textColor = UIColor(named: "LabelsPrimary")
        instructionText.translatesAutoresizingMaskIntoConstraints = false
        return instructionText
    }()
    
    private var placeText: UILabel = {
        let placeText = UILabel()
        placeText.textAlignment = .center
        placeText.font = UIFont.systemFont(ofSize: 17)
        placeText.textColor = .systemGreen
        placeText.translatesAutoresizingMaskIntoConstraints = false
        return placeText
    }()
    
    private var dealHereText: UILabel = {
        let dealHereText = UILabel()
        dealHereText.text = "여기서 거래할게요!"
        dealHereText.textAlignment = .center
        dealHereText.font = UIFont.systemFont(ofSize: 17)
        dealHereText.textColor = UIColor(named: "LabelsPrimary")
        dealHereText.translatesAutoresizingMaskIntoConstraints = false
        return dealHereText
    }()
    
    private var dealHereButton: UIButton = {
        let dealHereButton = UIButton()
        dealHereButton.layer.cornerRadius = 10
        dealHereButton.layer.borderWidth = 1
        dealHereButton.layer.borderColor = UIColor(named: "SeparatorsNonOpaque")?.cgColor
        dealHereButton.clipsToBounds = true
        dealHereButton.backgroundColor = UIColor(named: "BGPrimary")
        dealHereButton.translatesAutoresizingMaskIntoConstraints = false
        return dealHereButton
    }()
    
    private var anotherPlaceText: UILabel = {
        let anotherPlaceText = UILabel()
        anotherPlaceText.text = "그 외 장소에서 거래할게요!"
        anotherPlaceText.textAlignment = .center
        anotherPlaceText.font = UIFont.systemFont(ofSize: 17)
        anotherPlaceText.textColor = UIColor(named: "LabelsPrimary")
        anotherPlaceText.translatesAutoresizingMaskIntoConstraints = false
        return anotherPlaceText
    }()
    
    private var anotherPlaceButton: UIButton = {
        let anotherPlaceButton = UIButton()
        anotherPlaceButton.layer.cornerRadius = 10
        anotherPlaceButton.layer.borderWidth = 1
        anotherPlaceButton.layer.borderColor = UIColor(named: "SeparatorsNonOpaque")?.cgColor
        anotherPlaceButton.clipsToBounds = true
        anotherPlaceButton.backgroundColor = UIColor(named: "BGPrimary")
        anotherPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        return anotherPlaceButton
    }()
    
    private var nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.setTitle("다음", for: .normal)
        nextButton.backgroundColor = .systemGray3
        nextButton.layer.cornerRadius = 10
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        return nextButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "BGSecondary")
        
        dealHereButton.addAction(UIAction { [weak self] _ in
            self?.dealHereButtonTapped()
        }, for: .touchUpInside)
        
        anotherPlaceButton.addAction(UIAction { [weak self] _ in
            self?.anotherPlaceButtonTapped()
        }, for: .touchUpInside)
        
        nextButton.addAction(UIAction { [weak self] _ in
            guard let planPlace = self?.planPlace else {
                print("planPlace is nil")
                return
            }
            self?.viewModel.planPlace = planPlace
            self?.viewModel.progress = 2
            self?.viewModel.gotoNextPage()
        }, for: .touchUpInside)
        setupUI()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(instructionText)
        scrollView.addSubview(dealHereButton)
        scrollView.addSubview(anotherPlaceButton)
        
        dealHereButton.addSubview(placeText)
        dealHereButton.addSubview(dealHereText)
        anotherPlaceButton.addSubview(anotherPlaceText)

        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            instructionText.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            instructionText.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            instructionText.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            dealHereButton.topAnchor.constraint(equalTo: instructionText.bottomAnchor, constant: 60),
            dealHereButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            dealHereButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            dealHereButton.heightAnchor.constraint(equalToConstant: 150),
            
            placeText.centerXAnchor.constraint(equalTo: dealHereButton.centerXAnchor),
            placeText.centerYAnchor.constraint(equalTo: dealHereButton.centerYAnchor, constant: -16),
            
            dealHereText.centerXAnchor.constraint(equalTo: dealHereButton.centerXAnchor),
            dealHereText.centerYAnchor.constraint(equalTo: dealHereButton.centerYAnchor, constant: 16),
            
            anotherPlaceButton.topAnchor.constraint(equalTo: dealHereButton.bottomAnchor, constant: 20),
            anotherPlaceButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            anotherPlaceButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            anotherPlaceButton.heightAnchor.constraint(equalToConstant: 150),
            
            anotherPlaceText.centerXAnchor.constraint(equalTo: anotherPlaceButton.centerXAnchor),
            anotherPlaceText.centerYAnchor.constraint(equalTo: anotherPlaceButton.centerYAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
        
        placeText.text = "서울특별시 종로구 사직로8길 1"
        nextButton.isEnabled = isDealHereButtonSelected
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

