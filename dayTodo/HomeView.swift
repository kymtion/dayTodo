
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    
    var body: some View {
            Text("home")
      
    }
}

#Preview {
    HomeView()
        .environmentObject(CalendarViewModel())
}
