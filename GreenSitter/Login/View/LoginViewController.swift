//
//  LoginViewController.swift
//  GreenSitter
//
//  Created by Jiyong Cha on 8/7/24.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

protocol LoginViewControllerDelegate: AnyObject {
    func didCompleteLogin()
}

class LoginViewController: UIViewController, SetLocationViewControllerDelegate {
    func didCompleteLocationSetup() {
        self.delegate?.didCompleteLogin()
        self.dismiss(animated: true, completion: nil)
    }
    
    weak var delegate: LoginViewControllerDelegate?
    
    var currentNonce: String? //Apple Login Property
    let db = Firestore.firestore()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "새싹 돌봄이"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .labelsPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text =
        """
        내 주변의 새싹 돌봄이 ☘️들이
        당신의 소중한 식물을
        돌봐드립니다
        """
        label.font = .systemFont(ofSize: 17)
        label.textColor = .labelsPrimary
        label.textAlignment = .center
        label.numberOfLines = 0 // 여러 줄 텍스트를 지원
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "googleLogin"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var textButton: UIButton = {
        let button = UIButton()
        button.setTitle("둘러보기", for: .normal)
        button.setTitleColor(.labelsPrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        button.style = .plain
        button.tintColor = .labelsPrimary
        button.target = self
        button.action = #selector(navigationTap)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .bgPrimary
        
        navigationItem.leftBarButtonItem = closeButton
        
        view.addSubview(bodyLabel)
        view.addSubview(titleLabel)
        view.addSubview(appleButton)
        view.addSubview(googleButton)
        view.addSubview(textButton)
        
        googleButton.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleLogin), for: .touchUpInside)
        textButton.addTarget(self, action: #selector(navigationTap), for: .touchUpInside)
        
        showToast(withDuration: 1, delay: 2)
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            
            // Body Label
            bodyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            // Google Button
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleButton.bottomAnchor.constraint(equalTo: appleButton.topAnchor, constant: -20),
            googleButton.widthAnchor.constraint(equalToConstant: 230),
            googleButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Apple Button
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleButton.bottomAnchor.constraint(equalTo: textButton.topAnchor, constant: -20),
            appleButton.widthAnchor.constraint(equalToConstant: 230),
            appleButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Text Button
            textButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    //MARK: - ToastMessage
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
        labelOne.text = "로그인 권한이 필요한 기능입니다"
        labelOne.textColor = .labelsPrimary
        labelOne.font = UIFont.boldSystemFont(ofSize: 15)
        labelOne.textAlignment = .left
        labelOne.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTwo = UILabel()
        labelTwo.text = "로그인 화면으로 이동합니다"
        labelTwo.textColor = .labelsSecondary
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
        let mainStackView = UIStackView(arrangedSubviews: [image, labelStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(mainStackView)
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
        ])
        
        UIView.animate(withDuration: withDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            // 사라지는 애니메이션
            UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseIn, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
    
    
    
    //MARK: - GoogleLogin
    @objc func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: Unable to fetch clientID.")
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                print("Google SignIn Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {
                print("Error: GoogleSignIn result is nil.")
                return
            }
            
            guard let idToken = user.idToken?.tokenString else {
                print("Error: Unable to fetch idToken.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // Firebase 인증 처리
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase SignIn Error: \(error.localizedDescription)")
                    return
                }
                
                guard let user = authResult?.user else {
                    print("Error: Firebase authResult is nil.")
                    return
                }
                
                // Firebase Database에 사용자 정보 저장
                let userRef = self.db.collection("users").document(user.uid)
                
                userRef.getDocument { document, error in
                    if let error = error {
                        print("Error fetching user document: \(error)")
                        
                    }
                    else if let document = document, document.exists {
                        // 재로그인 (유저 데이터가 있는 경우)
                        DispatchQueue.main.async {
                            LoginViewModel.shared.firebaseFetch(docId: user.uid) {}
                            self.navigationController?.popToRootViewController(animated: false) // 모든 푸시된 뷰를 pop
                            self.dismiss(animated: true, completion: {
                                self.delegate?.didCompleteLogin()
                            })
                        }
                    }
                    
                    else {
                        // 유저 데이터가 없는 경우, 회원가입 계속
                        userRef.setData([
                            "platform": "google"
                        ]) { error in
                            if let error = error {
                                print("Firestore Writing Error: \(error)")
                            } else {
                                DispatchQueue.main.async {
                                    let setLocationViewController = SetLocationViewController()
                                    setLocationViewController.delegate = self
                                    self.navigationController?.pushViewController(setLocationViewController, animated: true)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    //MARK: - MainView move
    @objc func navigationTap() {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: \.isKeyWindow),
           let tabBarController = window.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 0 // 메인 뷰(홈) 탭으로 이동
            dismiss(animated: true, completion: nil) // 로그인 뷰 닫기
        }
    }
}


//MARK: - AppleLogin
extension LoginViewController:ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    //Apple의 응답을 처리
    @objc func appleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Firebase에 사용자 인증 정보 저장
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: String(data: appleIDCredential.identityToken!, encoding: .utf8)!,
                                                      rawNonce: currentNonce!)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [self] (authResult, error) in
                if (error != nil) {
                    //로그인 오류 처리
                    print("Apple 로그인 오류: \(error?.localizedDescription)")
                    return
                }
                //Firebase Database에 사용자 정보 저장
                if let user = authResult?.user {
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(user.uid)
                    
                    userRef.getDocument { document, error in
                        if let error  = error {
                            print("Error fetching user document: \(error)")
                        }
                        else if let document = document, document.exists {
                            // 재로그인 (유저 데이터가 있는 경우)
                            DispatchQueue.main.async {
                                LoginViewModel.shared.firebaseFetch(docId: user.uid) {}
                                self.navigationController?.popToRootViewController(animated: false) // 모든 푸시된 뷰를 pop
                                self.dismiss(animated: true, completion: {
                                    self.delegate?.didCompleteLogin()
                                })

                            }
                        }
                        else {
                            // 유저 데이터가 없는 경우, 회원가입 계속
                            userRef.setData([
                                "platform": "apple"
                            ]) { error in
                                if let error = error {
                                    print("Firestore Writing Error: \(error)")
                                } else {
                                    DispatchQueue.main.async {
                                        let setLocationViewController = SetLocationViewController()
                                        setLocationViewController.delegate = self
                                        self.navigationController?.pushViewController(setLocationViewController, animated: true)
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
    }
    
    //로그인 실패 처리코드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 로그인 실패: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window! // 현재 뷰 컨트롤러의 윈도우를 반환
    }
    
    //로그인 요청 시 nonce값이 필요해서 주어진 길이의 난수 문자열을 생성하는 매서드
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    //주어진 문자열의 SHA256 해시 값을 반환하는 메서드
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

#Preview {
    LoginViewController()
}
