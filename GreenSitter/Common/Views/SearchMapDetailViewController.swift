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
    
    private lazy var placeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.label
        label.textAlignment = .left
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
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

        view.backgroundColor = .white
        setupNavigationBar()
        setupMapView()
        setupCustomAnnotation()
        setupLocationInfoView()
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
        infoView.backgroundColor = .white
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

        placeNameLabel.text = location.placeName
        infoView.addSubview(placeNameLabel)

        addressLabel.text = location.address
        infoView.addSubview(addressLabel)

        // Label layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        placeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            placeNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            placeNameLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            placeNameLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            addressLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16)
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
        let centerCoordinate = mapView.centerCoordinate
        location.latitude = centerCoordinate.latitude
        location.longitude = centerCoordinate.longitude
        
        KakaoAPIService.shared.fetchCoordinateToAddress(location: location) { [weak self] result in
            switch result {
            case .success(let updatedLocation):
                print("regionDidChangeAnimated")

                DispatchQueue.main.async {
                    self?.placeNameLabel.text = updatedLocation.placeName
                    self?.addressLabel.text = updatedLocation.address
                    print("placeNameLabel: \(String(describing: self?.placeNameLabel.text))")
                    print("address: \(String(describing: self?.addressLabel.text))")
                }
            case .failure(let error):
                print("Failed to fetch address: \(error.localizedDescription)")
            }
        }
    }

}

/*
 
 extension SearchMapDetailViewController: MKMapViewDelegate {
     func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
         let centerCoordinate = mapView.centerCoordinate
         location.latitude = centerCoordinate.latitude
         location.longitude = centerCoordinate.longitude
         
         KakaoAPIService.shared.fetchCoordinateToAddress(location: location) { [weak self] result in
             switch result {
             case .success(let updatedLocation):
                 DispatchQueue.main.async {
                     self?.placeNameLabel.text = updatedLocation.placeName
                     self?.addressLabel.text = updatedLocation.address
                 }
             case .failure(let error):
                 print("Failed to fetch address: \(error.localizedDescription)")
             }
         }
     }

 }

 */
