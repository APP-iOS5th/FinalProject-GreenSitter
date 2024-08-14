//
//  SceneDelegate.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

//import KakaoMapsSDK
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
//        // Kakao SDK 초기화
//        SDKInitializer.InitSDK(appKey: Bundle.main.kakaoNativeAppKey)

        // UIWindow 및 루트 뷰 컨트롤러 설정
        window = UIWindow(windowScene: windowScene)
        
        // Home(커뮤니티)
        let firstViewController = MainPostListViewController()
        let firstNavigationController = UINavigationController(rootViewController: firstViewController)
        firstNavigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), tag: 0)
        
        // Map
        let secondViewController = CareFinderMapViewController()
        let secondNavigationController = UINavigationController(rootViewController: secondViewController)
        secondNavigationController.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 1)
        
        // Chat
        let thirdViewController = ChatListViewController()
        let thirdNavigationController = UINavigationController(rootViewController: thirdViewController)
        thirdNavigationController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 2)
        
        // Profile
        let fourthViewController = LoginViewController()
        let fourthNavigationController = UINavigationController(rootViewController: fourthViewController)
        fourthNavigationController.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person.fill"), tag: 3)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [firstNavigationController, secondNavigationController, thirdNavigationController, fourthNavigationController]
        
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
}


