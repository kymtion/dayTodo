

import SwiftUI
import GoogleMobileAds

@main
struct dayTodoApp: App {
    
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
