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
    private let mapView = MKMapView()
    
    private lazy var customAnnotationView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "offeringToSitterIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        // 네비게이션 바 구성
        navigationItem.title = "장소 선택"
        
        // 좌측 취소 버튼
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        // 우측 확인 버튼
        let confirmButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(confirmButtonTapped))
        navigationItem.rightBarButtonItem = confirmButton
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
        
        // 정보 레이블들 추가
        let titleLabel = UILabel()
        titleLabel.text = "선택한 곳의 정확한 장소를 입력해주세요."
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .left
        infoView.addSubview(titleLabel)

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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerCoordinate = mapView.centerCoordinate
        location.latitude = centerCoordinate.latitude
        location.longitude = centerCoordinate.longitude
    }


    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func confirmButtonTapped() {
        // TODO: 확인 버튼 동작 구현
        dismiss(animated: true, completion: nil)
    }
}
