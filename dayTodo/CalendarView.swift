

import SwiftUI
import FSCalendar

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    
    var body: some View {
        VStack {
            FSCalendarWrapper(selectedDate: $viewModel.selectedDate, viewModel: viewModel)
                .frame(height: 310)
            
            TodolistView2(viewModel: viewModel)
            
        }
        .onAppear {
            viewModel.loadMemos()
        }
        .padding(10)
    }
}

struct FSCalendarWrapper: UIViewRepresentable {
    @Binding var selectedDate: Date
    var viewModel: CalendarViewModel
    
    
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerDateFormat = "⟨    yyyy년 MM월    ⟩"
        calendar.headerHeight = 50 // 헤더 높이 조정
        calendar.appearance.titlePlaceholderColor = UIColor.clear
        
        // 달력 제목 스타일 변경
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: .medium)
        calendar.appearance.headerTitleColor = UIColor.label
        
        // 요일 헤더 폰트 스타일을 살짝 두껍게 변경
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        calendar.appearance.weekdayTextColor = UIColor.systemOrange
        
        // 날짜 숫자 부분
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        calendar.appearance.titleDefaultColor = UIColor.label.withAlphaComponent(0.85) 
        calendar.appearance.titleWeekendColor = UIColor.label.withAlphaComponent(0.4)
        
        // 현재 날짜 표시 색상 변경
        calendar.appearance.todayColor = UIColor.systemOrange
        calendar.appearance.selectionColor = UIColor.systemGray
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        if viewModel.dataChanged {
            uiView.reloadData()
            DispatchQueue.main.async {
                self.viewModel.acknowledgeDataChange()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDelegateAppearance, FSCalendarDataSource {
        var parent: FSCalendarWrapper
        
        init(_ parent: FSCalendarWrapper) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            DispatchQueue.main.async {
                self.parent.viewModel.selectedDate = date
                self.parent.viewModel.isDateSelected = true  // 날짜 선택 플래그 설정
            }
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            return parent.viewModel.hasEvent(on: date) ? 1 : 0
        }
        
    }
}

#Preview {
    CalendarView(viewModel: CalendarViewModel())
}
