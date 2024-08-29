//
//  SearchMapDetailViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/14/24.
//

import UIKit
import MapKit

class SearchMapDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private var makePlanViewModel: MakePlanViewModel?
    private var addPostViewModel: AddPostViewModel?
    
    private var location: Location
    private var isInitialLoad = true  // 초기 로드를 체크하기 위한 플래그    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private lazy var customAnnotationView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "offeringToSitterIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "선택한 곳의 정확한 장소를 입력해주세요."
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private lazy var placeNameTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 30
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .fillPrimary
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.textColor = .labelsPrimary
        textField.textAlignment = .left
        textField.placeholder = "예) 강남역 1번 출구 앞.."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.autocapitalizationType = .none
        
        let label = UILabel()
        label.text = "장소 "
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .labelsSecondary
        label.sizeToFit()

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width + 10, height: textField.frame.height))
        label.frame.origin = CGPoint(x: 10, y: (containerView.frame.height - label.frame.height) / 2)
        containerView.addSubview(label)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.isEnabled = true

        return textField
    }()
    
    private lazy var addressTextField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 20
        textField.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textField.placeholder = "주소를 입력해주세요."
        textField.textColor = .labelsSecondary
        textField.textAlignment = .left
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.autocapitalizationType = .none

        let label = UILabel()
        label.text = "주소 "
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .labelsSecondary
        label.sizeToFit()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width + 20, height: textField.frame.height))
        label.frame.origin = CGPoint(x: 10, y: (containerView.frame.height - label.frame.height) / 2)
        containerView.addSubview(label)
        
        textField.leftView = containerView
        textField.leftViewMode = .always

        textField.isEnabled = true
        
        return textField
    }()
    
    private lazy var infoView: UIView = {
        let infoView = UIView()
        infoView.backgroundColor = .bgSecondary
        infoView.translatesAutoresizingMaskIntoConstraints = false
        return infoView
    }()
    
    // MARK: - Initializer
    
    init(location: Location, makePlanViewModel: MakePlanViewModel? = nil, addPostViewModel: AddPostViewModel? = nil) {
        self.location = location
        self.makePlanViewModel = makePlanViewModel
        self.addPostViewModel = addPostViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .bgPrimary
        setupNavigationBar()
        setupMapView()
        setupCustomAnnotation()
        setupLocationInfoView()
    }
    
    private func updateLabels(with location: Location) {
        placeNameTextField.text = location.placeName.isEmpty ? nil : location.placeName
        addressTextField.text = location.address
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "장소 선택"
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        let confirmButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(confirmButtonTapped))
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        
        // Map view layout
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.70) // Height 70%
        ])
        
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    private func setupCustomAnnotation() {
        mapView.addSubview(customAnnotationView)
        
        NSLayoutConstraint.activate([
            customAnnotationView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            customAnnotationView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            customAnnotationView.widthAnchor.constraint(equalToConstant: 40),
            customAnnotationView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupLocationInfoView() {
        view.addSubview(infoView)
        
        infoView.addSubview(titleLabel)
        
        placeNameTextField.text = location.placeName
        infoView.addSubview(placeNameTextField)
        
        addressTextField.text = location.address
        infoView.addSubview(addressTextField)
        
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            placeNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            placeNameTextField.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            placeNameTextField.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            addressTextField.topAnchor.constraint(equalTo: placeNameTextField.bottomAnchor, constant: 8),
            addressTextField.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            addressTextField.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16)
        ])
    }
    
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func confirmButtonTapped() {
        
        guard let addressText = addressTextField.text else {
            return
        }
        
        guard let placeNameText = placeNameTextField.text else {
            return
        }
        
        location.address = addressText
        location.placeName = placeNameText
        
        // plan에서 필요한 기능
        if self.makePlanViewModel != nil {
            self.makePlanViewModel?.planPlace = location
            self.makePlanViewModel?.isPlaceSelected = true
            guard let parentViewController = self.presentingViewController else { return }
            self.dismiss(animated: true) {
                parentViewController.dismiss(animated: true)
            }
            // post 에서 필요한 기능
        } else if self.addPostViewModel != nil {
            self.addPostViewModel?.postLocation = location
            guard let parentViewController = self.presentingViewController else { return }
            self.dismiss(animated: true) {
                parentViewController.dismiss(animated: true)
            }
            // login 에서 필요한 기능
        }
        else {
            LoginViewModel.shared.updateUserLocation(with: location)
            guard let parentViewController = self.presentingViewController else { return }
            self.dismiss(animated: true) {
                parentViewController.dismiss(animated: true)
            }
        }
    }
}


extension SearchMapDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isInitialLoad {
            isInitialLoad = false
            return
        }
        let centerCoordinate = mapView.centerCoordinate
        location.latitude = centerCoordinate.latitude
        location.longitude = centerCoordinate.longitude
        
        // 카메라 움직이면 update address
        KakaoAPIService.shared.fetchCoordinateToAddress(location: location) { [weak self] result in
            switch result {
            case .success(let updatedLocation):
                DispatchQueue.main.async {
                    self?.updateLabels(with: updatedLocation)
                }
            case .failure(let error):
                print("Failed to fetch address: \(error.localizedDescription)")
            }
        }
    }
}
