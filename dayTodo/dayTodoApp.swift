

import SwiftUI
import GoogleMobileAds
import FirebaseCore
import FirebaseRemoteConfig

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Remote Config 초기 설정 및 기본값 설정
        setupRemoteConfigDefaults()
        
        // Remote Config 값을 가져와서 처리하고, 필요시 업데이트 알림 표시
        fetchRemoteConfigAndShowUpdateAlertIfNeeded()
        
        // AdMob SDK 초기화
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
    
    // Remote Config 기본값 설정
    private func setupRemoteConfigDefaults() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let defaults: [String: NSObject] = [
            "latest_version": "1.5.2" as NSObject
        ]
        remoteConfig.setDefaults(defaults)
    }
    
    // Remote Config 값을 가져오고, 필요한 경우 업데이트 유도 알림 표시
    private func fetchRemoteConfigAndShowUpdateAlertIfNeeded() {
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetch(withExpirationDuration: 3600) { status, _ in
            if status == .success {
                remoteConfig.activate { _, _ in
                    let latestVersion = remoteConfig.configValue(forKey: "latest_version").stringValue ?? ""
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                    
                    if currentVersion < latestVersion {
                        DispatchQueue.main.async {
                            // 업데이트 유도 알림 표시
                            self.showUpdateAlert()
                        }
                    }
                }
            }
        }
    }
    
    // 사용자에게 업데이트 알림을 표시
    func showUpdateAlert() {
        // UIWindowScene을 통해 key window를 찾는 방식으로 수정
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(title: "새로운 업데이트가 있습니다", message: "더 나은 사용 경험을 위해 최신 버전으로 업데이트 해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "업데이트", style: .default, handler: { _ in
            // 여기에 앱 스토어로 이동하는 로직을 구현하세요.
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id6475683164"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "나중에", style: .cancel, handler: nil))
        
        topController.present(alert, animated: true, completion: nil)
    }

    
}

@main
struct dayTodoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // AdMob SDK 초기화
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(CalendarViewModel())
            
        }
    }
}
