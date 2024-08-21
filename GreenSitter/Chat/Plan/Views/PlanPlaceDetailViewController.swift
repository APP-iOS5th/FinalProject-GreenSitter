//
//  PlanPlaceDetailViewController.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/20/24.
//

import UIKit
import MapKit

class PlanPlaceDetailViewController: UIViewController {

    private let location: Location
    private let mapView = MKMapView()
    
    private var makePlanViewModel: MakePlanViewModel?

    init(location: Location, makePlanViewModel: MakePlanViewModel? = nil) {
        self.location = location
        self.makePlanViewModel = makePlanViewModel
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
        setupLocationInfoView()
    }

    private func setupNavigationBar() {
        // 네비게이션 바 구성
        navigationItem.title = "약속 장소"
        
        // 우측 닫기 버튼
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = closeButton
    }

    private func setupMapView() {
        view.addSubview(mapView)
        
        // 네비게이션 바 높이 확보 후 맵 뷰 위치 조정
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75) // 높이 75%
        ])

        // 지도에 위치 설정
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location.placeName
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
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
        
        // 정보 레이블들 추가

        let placeNameLabel = UILabel()
        placeNameLabel.text = location.placeName
        placeNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        placeNameLabel.textColor = UIColor.label
        placeNameLabel.textAlignment = .left
        infoView.addSubview(placeNameLabel)

        let addressLabel = UILabel()
        addressLabel.text = location.address
        addressLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addressLabel.textColor = UIColor.secondaryLabel
        addressLabel.textAlignment = .left
        infoView.addSubview(addressLabel)

        // 레이블 위치 설정
        placeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeNameLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 16),
            placeNameLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            placeNameLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            
            addressLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16)
        ])
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
