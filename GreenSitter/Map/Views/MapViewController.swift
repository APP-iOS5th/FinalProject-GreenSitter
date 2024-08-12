//
//  MapViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/9/24.
//

import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController {

    let locationManager = CLLocationManager()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
    }()

    private var overlayPostMapping: [MKCircle: Post] = [:]

    private var currentDetailViewController: AnnotationDetailViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        view.addSubview(mapView)

        setupMapUI(with: Post.samplePosts)  // 나중에 실제 서버 데이터로 변경

//        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        locationManager.requestLocation()
    }
    
    // Post 객체 배열을 사용하여 지도에 마커 및 오버레이 추가
    func setupMapUI(with posts: [Post]) {
        for post in posts {
            guard let latitude = post.location?.latitude,
                  let longitude = post.location?.longitude else { continue }
            
            let circleCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let randomOffset = generateRandomOffset(for: circleCenter, radius: 500)
            let randomCenter = CLLocationCoordinate2D(
                latitude: circleCenter.latitude + randomOffset.latitudeDelta,
                longitude: circleCenter.longitude + randomOffset.longitudeDelta
            )
            
            let circle = MKCircle(center: randomCenter, radius: 500)

            // Associate the circle with the post BEFORE adding the overlay to the map view
            overlayPostMapping[circle] = post
//            print("dict after add: \(overlayPostMapping)")
            
            mapView.addOverlay(circle)  // MKOverlayRenderer 메소드 호출
            

            // 원래의 circleCenter 위치에 마커 추가 (테스트 용)
//            let originalMarker = MKPointAnnotation()
//            originalMarker.coordinate = circleCenter
//            originalMarker.title = "실제 위치: \(post.postTitle)"
            
            // Release 버전에서는 randomcenter 만 사용
//            let randomCenterMarker = MKPointAnnotation()
//            randomCenterMarker.coordinate = randomCenter
//            randomCenterMarker.title = post.postTitle
//            randomCenterMarker.subtitle = post.postBody

//            mapView.addAnnotation(originalMarker)
//            mapView.addAnnotation(randomCenterMarker)
            
            let pin = CustomAnnotation(postType: post.postType, coordinate: randomCenter)
            mapView.addAnnotation(pin)
        }
    }
    
    
    // 실제 위치(center) 기준으로 반경 내의 무작위 좌표를 새로운 중심점으로 설정
    func generateRandomOffset(for center: CLLocationCoordinate2D, radius: Double) -> (latitudeDelta: Double, longitudeDelta: Double) {
        let earthRadius: Double = 6378137 // meters
        let dLat = (radius / earthRadius) * (180 / .pi)
        let dLong = dLat / cos(center.latitude * .pi / 180)
        
        let randomLatDelta = Double.random(in: -dLat...dLat)
        let randomLongDelta = Double.random(in: -dLong...dLong)
        
        return (latitudeDelta: randomLatDelta, longitudeDelta: randomLongDelta)
    }
    
    
    // MARK: - 위치 권한 거부 시 나오는 Toast message
    func showToast(withDuration: Double, delay: Double) {
        let toastLabelWidth: CGFloat = 380
        let toastLabelHeight: CGFloat = 80
        
        // UIView 생성
        let toastView = UIView(frame: CGRect(x: (self.view.frame.size.width - toastLabelWidth) / 2, y: 75, width: toastLabelWidth, height: toastLabelHeight))
        toastView.backgroundColor = UIColor.white
        toastView.alpha = 1.0
        toastView.layer.cornerRadius = 25
        toastView.clipsToBounds = true
        toastView.layer.borderColor = UIColor.gray.cgColor
        toastView.layer.borderWidth = 1
        
        // 쉐도우 설정
        toastView.layer.shadowColor = UIColor.gray.cgColor
        toastView.layer.shadowOpacity = 0.5 // 투명도
        toastView.layer.shadowOffset = CGSize(width: 4, height: 4) // 그림자 위치
        toastView.layer.shadowRadius = 10
        
        // UIImageView 생성 및 설정
        let image = UIImageView(image: UIImage(named: "logo7"))
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true  // 이미지의 크기를 설정.
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // UIButton 생성
        let toastButton = UIButton()
        toastButton.titleLabel?.font = .systemFont(ofSize: 13)
        toastButton.setTitle("설정", for: .normal)
        toastButton.setTitleColor(.white, for: .normal)
        toastButton.backgroundColor = UIColor(.dominent)
        toastButton.layer.cornerRadius = 4
        toastButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        toastButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonAction = UIAction { _ in
            print("Button Action")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        toastButton.addAction(buttonAction, for: .touchUpInside)
        
        // UILabel 생성 및 설정
        let labelOne = UILabel()
        labelOne.text = "위치 권한이 필요한 기능입니다."
        labelOne.textColor = .black
        labelOne.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        labelOne.textAlignment = .left
        labelOne.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTwo = UILabel()
        labelTwo.text = "위치 권한 설정 화면으로 이동합니다."
        labelTwo.textColor = .black
        labelTwo.font = UIFont.systemFont(ofSize: 12)
        labelTwo.textAlignment = .left
        labelTwo.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView 생성 및 설정 (Vertical Stack)
        let labelStackView = UIStackView(arrangedSubviews: [labelOne, labelTwo])
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView 생성 및 설정 (Horizontal Stack)
        let mainStackView = UIStackView(arrangedSubviews: [image, labelStackView, toastButton])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(mainStackView)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
            mainStackView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10)
        ])
        
        self.view.addSubview(toastView) // toastView를 self.view에 추가
        self.view.bringSubviewToFront(toastView) // toastView를 최상단으로
        
        print(self.view.subviews)

        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
            toastView.alpha = 0.0
        }, completion: {(isCompleted) in
            toastView.removeFromSuperview()
        })
    }

}


// MARK: - MKMAPVIEW DELEGATE

extension MapViewController: MKMapViewDelegate {
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }
           
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let sesacImage: UIImage!
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        
        switch annotation.postType {
        case .lookingForSitter:
            sesacImage = UIImage(named: "lookingForSitterIcon")
        case .offeringToSitter:
            sesacImage = UIImage(named: "offeringToSitterIcon")
        default:
            sesacImage = UIImage(systemName: "mappin.circle.fill")
        }
        
        sesacImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotationCoordinate = view.annotation?.coordinate else { return }
        let region = MKCoordinateRegion(center: annotationCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        // 기존의 시트가 표시된 상태라면 닫음
        if let currentDetailViewController = currentDetailViewController {
            currentDetailViewController.dismiss(animated: false) {
                self.presentAnnotationDetail(for: view)
            }
        } else {
            presentAnnotationDetail(for: view)
        }
    }
    
    private func presentAnnotationDetail(for view: MKAnnotationView) {
        // 어노테이션에 연결된 Post를 가져옴
        if let annotation = view.annotation as? CustomAnnotation,
           let post = overlayPostMapping.first(where: { $0.key.coordinate.latitude == annotation.coordinate.latitude && $0.key.coordinate.longitude == annotation.coordinate.longitude })?.value {
            
            // 이미지 확대 애니메이션 추가
            UIView.animate(withDuration: 0.3) {
                view.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            }
            
            // 새 하프 시트 뷰 컨트롤러 생성 및 표시
            let postDetailViewController = AnnotationDetailViewController()
            postDetailViewController.post = post
            postDetailViewController.delegate = self  // Set delegate
            postDetailViewController.modalPresentationStyle = .pageSheet
            if let sheet = postDetailViewController.sheetPresentationController {
                sheet.detents = [.custom { context in
                    return context.maximumDetentValue * 0.25
                }]
            }
            present(postDetailViewController, animated: true, completion: nil)
            currentDetailViewController = postDetailViewController
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
//            print("rendererFor methods: dict: \(overlayPostMapping)")
            // Retrieve the associated Post object from the dictionary
            if let post = overlayPostMapping[circleOverlay] {
                switch post.postType {
                case .lookingForSitter:
                    circleRenderer.fillColor = UIColor.complementary.withAlphaComponent(0.3) // Use appropriate color
                case .offeringToSitter:
                    circleRenderer.fillColor = UIColor.dominent.withAlphaComponent(0.3) // Use appropriate color
                }
            } else {
                print("post is nil")
                circleRenderer.fillColor = UIColor.gray.withAlphaComponent(0.3) // Default color
            }

            circleRenderer.strokeColor = UIColor.separatorsOpaque
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        return MKOverlayRenderer()
    }

}

// MARK: - CLLOCATION MANAGER DELEGATE

extension MapViewController: CLLocationManagerDelegate {
    
    
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            locationManager.startUpdatingLocation()
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            getLocationUsagePermission()
            showToast(withDuration: 1, delay: 4)
        default:
            print("GPS: Default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let myLocation = locations.first {
            let latitude = myLocation.coordinate.latitude
            let longitude = myLocation.coordinate.longitude
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
}

// MARK: - AnnotationDetailViewControllerDelegate

extension MapViewController: AnnotationDetailViewControllerDelegate {
    func annotationDetailViewControllerDidDismiss(_ controller: AnnotationDetailViewController) {
        if let selectedAnnotationView = mapView.selectedAnnotations.compactMap({ mapView.view(for: $0) }).first {
            UIView.animate(withDuration: 0.1) {
                selectedAnnotationView.transform = CGAffineTransform.identity
            }
        }
        // 시트가 닫혔으므로 currentDetailViewController를 nil로 설정
        currentDetailViewController = nil
    }
}
