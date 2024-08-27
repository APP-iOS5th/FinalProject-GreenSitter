//
//  MapViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/9/24.
//

import Combine
import MapKit
import UIKit
import FirebaseAuth

class MapViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel = MapViewModel()  // 위치 정보 관리 뷰모델
    private let postViewModel = MainPostListViewModel()
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
    }()
    
    // 커스텀 어노테이션, 오버레이 만들기 위한 Dictionary
    private var overlayPostMapping: [MKCircle: Post] = [:]
    private var selectedAnnotation: CustomAnnotation?
    private var annotationOverlayMapping: [CustomAnnotation: MKCircle] = [:]
    
    // 선택한 어노테이션 관리
    private var currentDetailViewController: AnnotationDetailViewController?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    // zoom control, user location buttons
    private lazy var zoomInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        return button
    }()
    
    private lazy var zoomOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        return button
    }()
    
    private lazy var userLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(centerUserLocation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.checkLocationAuthorization()

        // 로그인 했을 경우 그리고 위치 정보 있을 경우.
        if Auth.auth().currentUser != nil, let userLocation = LoginViewModel.shared.user?.location {
            print("MapView - userlocation: \(userLocation)")
            postViewModel.fetchPostsWithin3Km(userLocation: userLocation)
        } else {    // 비로그인, 혹은 위치 정보 없으면
            print("MapView - userlocation: \(String(describing: LoginViewModel.shared.user?.location))")
            postViewModel.fetchPostsWithin3Km(userLocation: nil)
        }
        // 기존 코드
        //        postViewModel.fetchAllPosts()
    }
    
    // MARK: - Help methods
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(userLocationButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            zoomInButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            zoomInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            zoomInButton.widthAnchor.constraint(equalToConstant: 40),
            zoomInButton.heightAnchor.constraint(equalToConstant: 40),
            
            zoomOutButton.topAnchor.constraint(equalTo: zoomInButton.bottomAnchor, constant: 8),
            zoomOutButton.leadingAnchor.constraint(equalTo: zoomInButton.leadingAnchor),
            zoomOutButton.widthAnchor.constraint(equalTo: zoomInButton.widthAnchor),
            zoomOutButton.heightAnchor.constraint(equalTo: zoomInButton.heightAnchor),
            
            userLocationButton.topAnchor.constraint(equalTo: zoomOutButton.bottomAnchor, constant: 8),
            userLocationButton.leadingAnchor.constraint(equalTo: zoomOutButton.leadingAnchor),
            userLocationButton.widthAnchor.constraint(equalTo: zoomInButton.widthAnchor),
            userLocationButton.heightAnchor.constraint(equalTo: zoomInButton.heightAnchor),
        ])
    }
    
    @objc private func zoomIn() {
        let region = mapView.region
        let zoomedRegion = MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2, longitudeDelta: region.span.longitudeDelta / 2))
        mapView.setRegion(zoomedRegion, animated: true)
    }
    
    @objc private func zoomOut() {
        let region = mapView.region
        let zoomedRegion = MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2, longitudeDelta: region.span.longitudeDelta * 2))
        mapView.setRegion(zoomedRegion, animated: true)
    }
    
    @objc private func centerUserLocation() {
        guard let location = viewModel.currentLocation else { return }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    private func bindViewModel() {
        // current Location 기준으로 1000m 안 카메라 세팅
        viewModel.$currentLocation
            .compactMap { $0 }  // nil 이 아닌 경우만 처리
            .sink { [weak self] location in
                print("Updated Location: \(location.latitude), \(location.longitude), Address: \(location.address), placeName: \(location.placeName)")
                
                let region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                self?.mapView.setRegion(region, animated: true)
            }
            .store(in: &cancellables)
        
        // 권한 거부 시 토스트 메시지 표시
        viewModel.$isLocationAuthorized
            .sink { [weak self] status in
                switch status {
                case .denied:
                    self?.showToast(withDuration: 1, delay: 2)
                case .restrictedOrNotDetermined:
                    print("Authorization Status: Restricted or NotDetermined, No Toast")
                case .authorized:
                    print("Authorization Status: Authorized")
                }
                
            }.store(in: &cancellables)
        
        postViewModel.$filteredPosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                print("MapView - bindviewmodel posts: \(posts)")
                self?.setupMarkerAndOverlay(with: posts)
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - 위치 권한 거부 시 나오는 Toast message
    
    func showToast(withDuration: Double, delay: Double) {
        // UIView 생성
        let toastView = UIView()
        toastView.backgroundColor = .bgSecondary
        toastView.alpha = 1.0
        toastView.layer.cornerRadius = 25
        toastView.clipsToBounds = true
        toastView.layer.borderColor = UIColor.separatorsNonOpaque.cgColor
        toastView.layer.borderWidth = 1
        
        // 쉐도우 설정
        toastView.layer.shadowColor = UIColor.separatorsNonOpaque.cgColor
        toastView.layer.shadowOpacity = 0.5 // 투명도
        toastView.layer.shadowOffset = CGSize(width: 4, height: 4) // 그림자 위치
        toastView.layer.shadowRadius = 4
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        // UIImageView 생성 및 설정
        let image = UIImageView(image: UIImage(named: "logo7"))
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true  // 이미지의 크기를 설정.
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // UILabel 생성 및 설정
        let labelOne = UILabel()
        labelOne.text = "위치 권한이 필요한 기능입니다."
        labelOne.textColor = .labelsPrimary
        labelOne.font = UIFont.boldSystemFont(ofSize: 15)
        labelOne.textAlignment = .left
        labelOne.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTwo = UILabel()
        labelTwo.text = "위치 권한 설정 화면으로 이동합니다."
        labelTwo.textColor = .labelsSecondary
        labelTwo.font = UIFont.systemFont(ofSize: 12)
        labelTwo.textAlignment = .left
        labelTwo.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        // StackView 생성 및 설정 (Vertical Stack)
        let labelStackView = UIStackView(arrangedSubviews: [labelOne, labelTwo])
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView 생성 및 설정 (Horizontal Stack)
        let mainStackView = UIStackView(arrangedSubviews: [image, labelStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(mainStackView)
        toastView.addSubview(toastButton)
        self.view.addSubview(toastView)
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
            mainStackView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10),
            
            toastView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),
            toastView.heightAnchor.constraint(equalToConstant: 80),
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            toastButton.widthAnchor.constraint(equalToConstant: 20),
            toastButton.leadingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -10),
        ])
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseIn, animations: {
                toastView.isUserInteractionEnabled = false
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Post 객체 배열을 사용하여 지도에 마커 및 오버레이 추가
    
    func setupMarkerAndOverlay(with posts: [Post]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        overlayPostMapping.removeAll()
        annotationOverlayMapping.removeAll()
        
        for post in posts {
            guard let latitude = post.location?.latitude,
                  let longitude = post.location?.longitude else { continue }
            
            let circleCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let randomOffset = generateRandomOffset(for: circleCenter, radius: 500)
            let randomCenter = CLLocationCoordinate2D(
                latitude: circleCenter.latitude + randomOffset.latitudeDelta,
                longitude: circleCenter.longitude + randomOffset.longitudeDelta
            )
            
            // 오버레이를 미리 생성하고, 나중에 선택되었을 때 사용할 수 있도록 mapping에 저장
            let circle = MKCircle(center: randomCenter, radius: 500)
            
            // 맵 뷰에 오버레이 추가하기 전에, post 값을 circle 키에 넣기
            overlayPostMapping[circle] = post
            
//            mapView.addOverlay(circle)  // MKOverlayRenderer 메소드 호출
            
            let annotation = CustomAnnotation(postType: post.postType, coordinate: randomCenter)
            mapView.addAnnotation(annotation)  // MKAnnotationView
            
            // 어노테이션과 오버레이를 매핑 (오버레이는 아직 맵에 추가하지 않음)
            annotationOverlayMapping[annotation] = circle
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
}


// MARK: - MKMAPVIEW DELEGATE

extension MapViewController: MKMapViewDelegate {
    
    // MKAnnotationView
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
        
        // postType 따라서 어노테이션에 이미지 다르게 적용
        let sesacImage: UIImage!
        let size = CGSize(width: 50, height: 50)
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
    
    // MARK: - MKAnnotationView 터치 이벤트 관리
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? CustomAnnotation else { return }
        
        // 기존 선택된 어노테이션의 오버레이는 전부 제거
        if let previousAnnotation = selectedAnnotation,
           let overlay = annotationOverlayMapping[previousAnnotation] {
            mapView.removeOverlay(overlay)
            annotationOverlayMapping.removeValue(forKey: previousAnnotation)
        }
        
        // 새로운 어노테이션 선택 시 오버레이 추가
        let circle = MKCircle(center: annotation.coordinate, radius: 500)
        mapView.addOverlay(circle)
        annotationOverlayMapping[annotation] = circle
        
        // 현재 선택된 어노테이션으로 업데이트
        selectedAnnotation = annotation
        
        // 선택한 어노테이션 주변으로 MKCoordinateRegion 설정
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        // 어노테이션에 연결된 Post를 찾아서 상세 정보를 표시
        if let post = overlayPostMapping.first(where: { $0.key.coordinate.latitude == annotation.coordinate.latitude && $0.key.coordinate.longitude == annotation.coordinate.longitude })?.value {
            presentAnnotationDetail(for: post)
        }
    }
    
    // MARK: - MKAnnotationView 선택 해제 이벤트 관리
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotation = view.annotation as? CustomAnnotation else { return }
        
        // 선택 해제된 어노테이션에 연결된 오버레이는 제거
        if let overlay = annotationOverlayMapping[annotation] {
            mapView.removeOverlay(overlay)
            annotationOverlayMapping.removeValue(forKey: annotation)
        }
        
        // 상세 뷰 숨김
        hideAnnotationDetail()
    }
    
    // MARK: - AnnotationDetailViewController를 맵 위에 커스텀 방식으로 추가
    
    private func presentAnnotationDetail(for post: Post) {
        if let currentDetailViewController = currentDetailViewController {
            // 이미 창이 떠 있는 경우, Post 데이터만 업데이트
            currentDetailViewController.updatePost(post)
        } else {
            // 새로운 DetailViewController 추가
            let detailViewController = AnnotationDetailViewController(post: post)
            detailViewController.delegate = self
            
            // 최상위 뷰 계층에 추가하기 위해 keyWindow 가져오기
            if let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
                
                keyWindow.addSubview(detailViewController.view)
                
                // DetailViewController의 레이아웃 설정
                detailViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    detailViewController.view.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor),
                    detailViewController.view.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor),
                    detailViewController.view.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor),
                    detailViewController.view.heightAnchor.constraint(equalToConstant: 200)
                ])
                
                addChild(detailViewController)
                detailViewController.didMove(toParent: self)
                currentDetailViewController = detailViewController
            }
        }
    }

    
    private func hideAnnotationDetail() {
        if let currentDetailViewController = currentDetailViewController {
            currentDetailViewController.willMove(toParent: nil)
            currentDetailViewController.view.removeFromSuperview()
            currentDetailViewController.removeFromParent()
            self.currentDetailViewController = nil
        }
    }
    
    // MKOverlayRenderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            
            // 딕셔너리로부터 해당 circleOverlay에 저장된 Post 가져오기
            if let post = overlayPostMapping[circleOverlay] {
                // 오버레이 색 적용
                switch post.postType {
                case .lookingForSitter:
                    circleRenderer.fillColor = UIColor.complementary.withAlphaComponent(0.3)
                case .offeringToSitter:
                    circleRenderer.fillColor = UIColor.dominent.withAlphaComponent(0.3)
                }
            } else {
                circleRenderer.fillColor = UIColor.gray.withAlphaComponent(0.3)
            }

            circleRenderer.strokeColor = .separatorsNonOpaque
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        return MKOverlayRenderer()
    }

}


// MARK: - AnnotationDetailViewControllerDelegate
extension MapViewController: AnnotationDetailViewControllerDelegate {
    func annotationDetailViewControllerDidDismiss(_ controller: AnnotationDetailViewController) {
        if let selectedAnnotation = selectedAnnotation {
            mapView.deselectAnnotation(selectedAnnotation, animated: true)
        }
    }
}
