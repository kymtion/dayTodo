

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("To do list")
                    
                }
            
            CalendarView(viewModel: CalendarViewModel())
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            RecordView()
                .tabItem {
                    Image(systemName: "magazine")
                    Text("Record")
                }
            
        }
        .accentColor(.orange)
    }
}

#Preview {
    TabBarView()
}
