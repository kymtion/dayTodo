

import SwiftUI

@main
struct dayTodoApp: App {
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(CalendarViewModel())
          
        }
    }
}
