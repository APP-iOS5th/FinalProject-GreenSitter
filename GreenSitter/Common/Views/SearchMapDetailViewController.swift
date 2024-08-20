//
//  SearchMapDetailViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/14/24.
//

import UIKit
import MapKit

class SearchMapDetailViewController: UIViewController {

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
    
    private lazy var placeNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.textColor = UIColor.label
        textField.textAlignment = .left
        textField.placeholder = "예) 강남역 1번 출구 앞, 와르르 멘션 2동 경비실.."
        return textField
    }()

    private lazy var addressTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textField.textColor = UIColor.secondaryLabel
        textField.textAlignment = .left
        return textField
    }()


    init(location: Location) {
        self.location = location
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
        // Navigation bar setup
        navigationItem.title = "장소 선택"
        
        // Cancel button
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        // Confirm button
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
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75) // Height 75%
        ])

        // Initial map setup
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
        let infoView = UIView()
        infoView.backgroundColor = .bgSecondary
        view.addSubview(infoView)
        
        infoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Adding info labels
        let titleLabel = UILabel()
        titleLabel.text = "선택한 곳의 정확한 장소를 입력해주세요."
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .left
        infoView.addSubview(titleLabel)

        placeNameTextField.text = location.placeName
        infoView.addSubview(placeNameTextField)

        addressTextField.text = location.address
        infoView.addSubview(addressTextField)

        // Label layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        placeNameTextField.translatesAutoresizingMaskIntoConstraints = false
        addressTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            placeNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            placeNameTextField.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            placeNameTextField.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            addressTextField.topAnchor.constraint(equalTo: placeNameTextField.bottomAnchor, constant: 4),
            addressTextField.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            addressTextField.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16)
        ])
    }

    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func confirmButtonTapped() {
        // TODO: Implement confirm button action
        dismiss(animated: true, completion: nil)
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
