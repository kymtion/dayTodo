

import SwiftUI
import GoogleMobileAds
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
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
