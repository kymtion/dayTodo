

import Foundation
import SwiftUI
import FSCalendar
import WidgetKit

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
    
    struct YearMonth: Hashable {
        var year: Int
        var month: Int
    }
    
    // 사용 가능한 연월 목록을 반환하는 함수
        var availableYearMonths: [String] {
            let today = Date()
            let currentYear = Calendar.current.component(.year, from: today)
            let currentMonth = Calendar.current.component(.month, from: today)

            let yearMonths = memos.map { memo -> YearMonth in
                let year = Calendar.current.component(.year, from: memo.date)
                let month = Calendar.current.component(.month, from: memo.date)
                return YearMonth(year: year, month: month)
            }

            let filteredYearMonths = yearMonths.filter {
                $0.year < currentYear || ($0.year == currentYear && $0.month <= currentMonth)
            }

            // 중복 제거 후 내림차순 정렬
            let uniqueYearMonths = Set(filteredYearMonths)
            let sortedYearMonths = uniqueYearMonths.sorted { $0.year > $1.year || ($0.year == $1.year && $0.month > $1.month) }
            return sortedYearMonths.map { "\($0.year)년 \($0.month)월" }
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
    //  과거의 완료되지 않은 todo 타입의 메모들의 날짜를 오늘 날짜로 업데이트함.
    func updatePastIncompleteMemos() {
        let todayStart = Calendar.current.startOfDay(for: Date())
        for index in memos.indices where memos[index].memoType == .todo && memos[index].date < todayStart && !memos[index].isCompleted {
            memos[index].date = todayStart
        }
        sortMemosByDateIgnoringTime()
        saveAllMemos()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func moveMemo(from source: IndexSet, to destination: Int) {
        memos.move(fromOffsets: source, toOffset: destination)
        saveAllMemos()
    }
    
    func toggleMemoCompletion(_ memo: MemoData) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            memos[index].isCompleted.toggle()
            saveAllMemos()
            WidgetCenter.shared.reloadAllTimelines() // 위젯 새로고침
        }
    }
    // 켈린더에 점표시를 체크해 표시 유무를 결정해주는 함수
    func hasEvent(on date: Date) -> Bool {
        let hasEvent = memos.contains { memo in
            Calendar.current.isDate(memo.date, inSameDayAs: date)
        }
        return hasEvent
    }
    
    func saveMemo(title: String, content: String, isCompleted: Bool, memoType: MemoType, id: UUID? = nil) {
        let dateToSave = isDateSelected ? selectedDate : Calendar.current.startOfDay(for: Date())
        
        if let id = id {
            // 기존 메모 업데이트
            if let index = memos.firstIndex(where: { $0.id == id }) {
                let originalDate = memos[index].date  // 원래 날짜를 보존
                memos[index] = MemoData(id: id, title: title, content: content, date: originalDate, isCompleted: isCompleted, memoType: memoType)
            } else {
                // 새 메모 추가
                memos.append(MemoData(title: title, content: content, date: dateToSave, isCompleted: isCompleted, memoType: memoType))
            }
        } else {
            // 새 메모 추가
            memos.append(MemoData(title: title, content: content, date: dateToSave, isCompleted: isCompleted, memoType: memoType))
        }
        sortMemosByDateIgnoringTime()
        saveAllMemos()
        self.dataChanged = true
        WidgetCenter.shared.reloadAllTimelines() // 위젯 새로고침
    }
    
    
    
    
    func deleteMemo(id: UUID) {
        if let index = memos.firstIndex(where: { $0.id == id }) {
            memos.remove(at: index)
            saveAllMemos()
        }
        self.dataChanged = true
        WidgetCenter.shared.reloadAllTimelines() // 위젯 새로고침
    }
    
    func acknowledgeDataChange() {
        self.dataChanged = false
    }
    
    
    
    func saveAllMemos() {
        if let encoded = try? JSONEncoder().encode(memos) {
            if let userDefaults = UserDefaults(suiteName: "group.kr.com.daytodo") {
                userDefaults.set(encoded, forKey: "memos")
            }
        }
    }
    
    
    func loadMemos() {
        if let userDefaults = UserDefaults(suiteName: "group.kr.com.daytodo") {
            if let savedMemos = userDefaults.object(forKey: "memos") as? Data {
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
    
    // 밤 12시가 지나고 완료된 루틴 메모를 오늘날짜로 업데이트 하고 해당 메모들을 todo 타입, 어제 날짜로 복사 및 생성해주는 함수
    func routineUpdate1() {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        // 과거이고, 완료 상태이며, 루틴 타입인 메모 찾기
        var updatedMemos: [MemoData] = []
        for index in memos.indices {
            let memo = memos[index]
            if memo.date < today && memo.isCompleted && memo.memoType == .routine {
                // 날짜를 오늘로 업데이트
                memos[index].date = today
                memos[index].isCompleted = false
                updatedMemos.append(memos[index])
            }
        }
        
        // 업데이트된 메모들을 기반으로 새로운 todo 타입의 메모 생성
        for memo in updatedMemos {
            let copiedMemo = MemoData(id: UUID(), title: memo.title, content: memo.content, date: yesterday, isCompleted: true, memoType: .todo)
            memos.append(copiedMemo)
        }
        
        saveAllMemos() // 변경사항 저장
    }

    
    // 밤 12시가 지나고 미완료된 루틴 메모를 오늘날짜로 업데이트 해주는 함수.
    func routineUpdate2() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // 조건에 맞는 메모 찾기: routine 타입, 미완료 상태, 오늘 날짜보다 과거
        for index in memos.indices {
            let memo = memos[index]
            if memo.memoType == .routine && !memo.isCompleted && memo.date < today {
                memos[index].date = today // 해당 메모의 날짜를 오늘로 업데이트
            }
        }
        
        saveAllMemos() // 변경사항 저장
    }
    
    // 선택된 메모를 Todo 타입으로 복사하여 추가하는 함수 (즉, 루틴 메모를 오늘의 투두 메모로 복사해서 생성해줌)
       func addToDoList(memo: MemoData) {
           // 새로운 메모 생성: 내용은 동일하지만 MemoType만 Todo로 변경
           let newMemo = MemoData(title: memo.title, content: memo.content, date: Date(), isCompleted: false, memoType: .todo)
           
           // 생성된 새 메모를 memos 배열에 추가
           memos.append(newMemo)
           
           // 변경사항 저장 및 위젯 업데이트
           saveAllMemos()
           WidgetCenter.shared.reloadAllTimelines()
       }

    
    
    
}
