

import SwiftUI
import FSCalendar

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack {
            FSCalendarWrapper(selectedDate: $viewModel.selectedDate)
                .frame(height: 310)
            
            Rectangle()
                .fill(Color.black.opacity(0.2))  // 색상 변경
                .frame(height: 1) // 두께 변경
                .frame(width: UIScreen.main.bounds.width * 0.9)
              
                TodolistView2(viewModel: viewModel)
            
        }
        .padding(10)
    }
}

struct FSCalendarWrapper: UIViewRepresentable {
    @Binding var selectedDate: Date
    

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerDateFormat = "⟨    yyyy년 MM월    ⟩"
        calendar.headerHeight = 50 // 헤더 높이 조정
        
        // 달력 제목 스타일 변경
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: .medium)
        calendar.appearance.headerTitleColor = UIColor.black
        
        // 요일 헤더 폰트 스타일을 살짝 두껍게 변경
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        calendar.appearance.weekdayTextColor = UIColor.systemOrange

      
        
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)

        // 현재 날짜 표시 색상 변경
        calendar.appearance.todayColor = UIColor.systemOrange
        calendar.appearance.selectionColor = UIColor.systemGray
    
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // 여기에 FSCalendar를 업데이트하는 코드를 작성할 수 있습니다.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate {
        var parent: FSCalendarWrapper

        init(_ parent: FSCalendarWrapper) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            self.parent.selectedDate = date
            
        }
    }
}

#Preview {
    CalendarView(viewModel: CalendarViewModel())
}
