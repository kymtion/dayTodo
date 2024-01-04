

import Foundation
import SwiftUI
import FSCalendar

class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var memos: [MemoData] = []
    @Published var dataChanged = false
    @Published var isDateSelected = false
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    init() {
        loadMemos()
    }
    // 날짜의 시간 개념을 제외하고 년, 월, 일 만 고려하게 만드는 함수
    func sortMemosByDateIgnoringTime() {
        let calendar = Calendar.current
        memos.sort { (memo1, memo2) -> Bool in
            let date1 = calendar.startOfDay(for: memo1.date)
            let date2 = calendar.startOfDay(for: memo2.date)
            return date1 < date2
        }
    }
    
    func updatePastIncompleteMemos() {
        let todayStart = Calendar.current.startOfDay(for: Date())
        
        for index in memos.indices {
            if memos[index].date < todayStart && !memos[index].isCompleted {
                memos[index].date = todayStart
            }
        }
        sortMemosByDateIgnoringTime()
        saveAllMemos() // 변경된 내용 저장
    }
    
    func moveMemo(from source: IndexSet, to destination: Int) {
        memos.move(fromOffsets: source, toOffset: destination)
        saveAllMemos()
    }
    
    func toggleMemoCompletion(_ memo: MemoData) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            memos[index].isCompleted.toggle()
            saveAllMemos()
        }
    }
    
    func hasEvent(on date: Date) -> Bool {
        let hasEvent = memos.contains { memo in
            Calendar.current.isDate(memo.date, inSameDayAs: date)
        }
        return hasEvent
    }
    
    func saveMemo(title: String, content: String, isCompleted: Bool, id: UUID? = nil) {
        let dateToSave = isDateSelected ? selectedDate : Calendar.current.startOfDay(for: Date())
        
        if let id = id {
            // 기존 메모 업데이트
            if let index = memos.firstIndex(where: { $0.id == id }) {
                let originalDate = memos[index].date  // 원래 날짜를 보존
                memos[index] = MemoData(id: id, title: title, content: content, date: originalDate, isCompleted: isCompleted)
            } else {
                // 새 메모 추가
                memos.append(MemoData(title: title, content: content, date: dateToSave, isCompleted: isCompleted))
            }
        } else {
            // 새 메모 추가
            memos.append(MemoData(title: title, content: content, date: dateToSave, isCompleted: isCompleted))
        }
        sortMemosByDateIgnoringTime()
        saveAllMemos()
        self.dataChanged = true
    }
    
    
    
    
    func deleteMemo(id: UUID) {
        if let index = memos.firstIndex(where: { $0.id == id }) {
            memos.remove(at: index)
            saveAllMemos()
        }
        self.dataChanged = true
    }
    
    func acknowledgeDataChange() {
        self.dataChanged = false
    }
    
    
    
    func saveAllMemos() {
        if let encoded = try? JSONEncoder().encode(memos) {
            UserDefaults.standard.set(encoded, forKey: "memos")
        }
    }
    
    
    func loadMemos() {
        if let savedMemos = UserDefaults.standard.object(forKey: "memos") as? Data {
            if let decodedMemos = try? JSONDecoder().decode([MemoData].self, from: savedMemos) {
                self.memos = decodedMemos
                sortMemosByDateIgnoringTime()
                print("Memos loaded successfully")
            }
        } else {
            print("No saved memos to load")
        }
    }
    
    
    
}
