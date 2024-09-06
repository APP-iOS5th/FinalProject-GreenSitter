//
//  AppDelegate.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //MARK: - Firbase init
        FirebaseApp.configure()
        
        //MARK: - Google Login 유무 확인
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
          if error != nil || user == nil {
            // Show the app's signed-out state.
          } else {
            // Show the app's signed-in state.
          }
        }
        
        //MARK: - Push Notification
        // 알림 허용 권한 받음
        UNUserNotificationCenter.current().delegate = self
        
        // 원격 알림 등록
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    print("Permission not granted: \(error?.localizedDescription ?? "No error")")
                }
            }
        )
        
        application.registerForRemoteNotifications()
        
        // 등록 토큰 액세스
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // MARK: - 구글 로그인
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
    }
    
    
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

}

// MARK: - Push Notification 함수
extension AppDelegate: UNUserNotificationCenterDelegate {
    // APN 토큰과 등록 토큰 매핑
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APN TOKEN MAPPING")
        // Firebase에 디바이스 토큰 전달
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // 푸시 알림 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
      ) {
        let userInfo = notification.request.content.userInfo
        // 채팅방 내에서는 푸시 알림 오지 않음
        if let chatRoomId = userInfo["chatRoomId"] as? String,
           chatRoomId == ChatManager.shared.currentChatRoomId {
            completionHandler([])
            return
        } else {
            completionHandler([.banner, .badge, .sound, .list])
        }
          completionHandler([.banner, .badge, .sound, .list])
    }
    
    // 푸시 알림 클릭했을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let chatRoomId = userInfo["chatRoomId"] as? String {
            // Fetch chat room and navigate to it
            fetchChatRoom(chatRoomId: chatRoomId) { [weak self] chatRoom in
                guard let self = self else { return }
                if let chatRoom = chatRoom {
                    // Navigate to the chat room
                    self.navigateToChatRoom(chatRoom: chatRoom)
                } else {
                    print("No ChatRoom found with given ID.")
                }
                completionHandler()
            }
        } else {
            // Handle cases where chatRoomId is not present
            completionHandler()
        }
    }
    
    // ChatRoom 데이터 가져오기
    func fetchChatRoom(chatRoomId: String, completion: @escaping (ChatRoom?) -> Void) {
        let db = Firestore.firestore()
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
        
        chatRoomRef.getDocument { document, error in
            if let error = error {
                print("Error fetching chat room: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("ChatRoom does not exist.")
                completion(nil)
                return
            }
            
            do {
                let chatRoom = try document.data(as: ChatRoom.self)
                completion(chatRoom)
            } catch {
                print("Error parsing chat room data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // 푸시 알림 눌렀을 때 채팅방으로 이동
    func navigateToChatRoom(chatRoom: ChatRoom) {
        //메인 스레드에서 UI 업데이트
        DispatchQueue.main.async {
            let chatViewModel = ChatViewModel()
            let chatDetailViewController = ChatViewController(chatRoom: chatRoom)
            chatDetailViewController.chatViewModel = chatViewModel
            
            if let tabBarController = self.window?.rootViewController as? UITabBarController,
               let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
                navigationController.pushViewController(chatDetailViewController, animated: true)
                
                // Switch to the chat tab
                tabBarController.selectedIndex = 2
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken, let userId = Auth.auth().currentUser?.uid {
            saveFCMToken(userId: userId)
        }
    }
    
    // 디바이스 토큰 DB에 저장
    func saveFCMToken(userId: String) {
        guard let fcmToken = Messaging.messaging().fcmToken else {
            print("FCM Token is not available.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData(["fcmToken": fcmToken]) { error in
            if let error = error {
                print("Error updating FCM token: \(error.localizedDescription)")
            } else {
                print("FCM token successfully updated.")
            }
        }
    }
}
