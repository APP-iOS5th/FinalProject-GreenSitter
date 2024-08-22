//
//  SceneDelegate.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseAuth
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>() // Combine의 Cancellable 객체를 저장할 배열
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let viewModel = LoginViewModel()
        
        if let currentUser = Auth.auth().currentUser {
                // 사용자가 이미 로그인되어 있는 경우
                viewModel.firebaseFetch(userId: currentUser.uid)
                
                // Observe the user property to know when it gets updated
                viewModel.$user
                    .dropFirst() // Skip the initial nil value
                    .receive(on: DispatchQueue.main)
                    .sink { user in
                        if let user = user {
                            print("사용자 데이터 불러오기 성공 \(currentUser.uid)")
                            print("사용자: \(user)")
                        } else {
                            print("사용자 데이터 불러오기 실패")
                        }
                    }
                    .store(in: &cancellables) // Store the cancellable to retain it
            }
        // UIWindow 및 루트 뷰 컨트롤러 설정
        window = UIWindow(windowScene: windowScene)
        
        // Home(커뮤니티)
        let firstViewController = MainPostListViewController()
        let firstNavigationController = UINavigationController(rootViewController: firstViewController)
        firstNavigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), tag: 0)
        
        // Map
        let secondViewController = MapViewController()
        let secondNavigationController = UINavigationController(rootViewController: secondViewController)
        secondNavigationController.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 1)
        
        // Chat
        let thirdViewController = ChatListViewController()
        let thirdNavigationController = UINavigationController(rootViewController: thirdViewController)
        thirdNavigationController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 2)
        
        // Profile
        let profileViewController: UIViewController
        if let _ = Auth.auth().currentUser {
            // 사용자가 로그인한 경우: ProfileViewController로 이동
            guard let user = viewModel.user else { return }
            profileViewController = ProfileViewController(user: user)
        } else {
            // 사용자가 로그인하지 않은 경우: LoginViewController로 이동
            profileViewController = LoginViewController()
        }
        let fourthNavigationController = UINavigationController(rootViewController: profileViewController)
        fourthNavigationController.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person.fill"), tag: 3)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [firstNavigationController, secondNavigationController, thirdNavigationController, fourthNavigationController]
        
        tabBarController.tabBar.backgroundColor = .bgPrimary
        tabBarController.tabBar.isTranslucent = false
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
    func navigateToMainInterface() {
        let mainViewController = MainPostListViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = navigationController
    }
}

