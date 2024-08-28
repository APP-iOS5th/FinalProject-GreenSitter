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
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        if let currentUser = Auth.auth().currentUser {
//            LoginViewModel.shared.firebaseFetch(docId: currentUser.uid)
//        }
        //MARK: - 자동로그인
        // 현재 사용자가 로그인 되어 있는지 확인
        if let currentUser = Auth.auth().currentUser {
            // 이미 로그인된 상태라면, 메인 화면으로 이동
            LoginViewModel.shared.firebaseFetch(docId: currentUser.uid)
            print("자동 로그인 완료")
            setRootViewController(MainPostListViewController())
        }
        else {
            // 로그인되지 않은 상태라면, 로그인 화면으로 이동
            setRootViewController(LoginViewController())
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
                
        // Profile
        let fourthNavigationController = UINavigationController(rootViewController: ProfileViewController())
        fourthNavigationController.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person.fill"), tag: 3)
        
        // Chat을 비동기적으로 로드
        if let currentUser = Auth.auth().currentUser {
            LoginViewModel.shared.firebaseFetch(docId: currentUser.uid) { [weak self] in
                guard let self = self else { return }
                let chatListViewController = ChatListViewController()
                let thirdNavigationController = UINavigationController(rootViewController: chatListViewController)
                thirdNavigationController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 2)
                
                self.setupTabBarController(with: [firstNavigationController, secondNavigationController, thirdNavigationController, fourthNavigationController])
            }
        } else {
            let chatListViewController = LoginViewController()
            let thirdNavigationController = UINavigationController(rootViewController: chatListViewController)
            thirdNavigationController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 2)

            setupTabBarController(with: [firstNavigationController, secondNavigationController, thirdNavigationController, fourthNavigationController])
        }
    }
    
    // TabBarController 설정 함수
    private func setupTabBarController(with viewControllers: [UIViewController]) {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = viewControllers
        
        tabBarController.tabBar.backgroundColor = .bgPrimary
        tabBarController.tabBar.isTranslucent = false
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    private func setRootViewController(_ viewController: UIViewController) {
        let navController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navController
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
}
