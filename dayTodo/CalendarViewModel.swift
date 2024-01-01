

import Foundation
import SwiftUI
import FSCalendar

class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var memos: [MemoData] = []
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
    
    init() {
        loadMemos()
    }
    
    func deleteMemo(id: UUID) {
        if let index = memos.firstIndex(where: { $0.id == id }) {
            memos.remove(at: index)
            saveAllMemos()
        }
    }
    
    
    private func saveAllMemos() {
        if let encoded = try? JSONEncoder().encode(memos) {
            UserDefaults.standard.set(encoded, forKey: "memos")
        }
    }
    
    
    func loadMemos() {
        if let savedMemos = UserDefaults.standard.object(forKey: "memos") as? Data {
            if let decodedMemos = try? JSONDecoder().decode([MemoData].self, from: savedMemos) {
                self.memos = decodedMemos
                print("Memos loaded successfully")  // 로드 성공 메시지 출력
            }
        } else {
            print("No saved memos to load")  // 저장된 메모가 없음을 나타내는 메시지 출력
        }
    }
    
    func saveMemo(title: String, content: String, id: UUID? = nil) {
        if let id = id {
            // 기존 메모 업데이트 또는 새 메모 추가
            if let index = memos.firstIndex(where: { $0.id == id }) {
                memos[index] = MemoData(id: id, title: title, content: content, date: selectedDate)
            } else {
                memos.append(MemoData(title: title, content: content, date: selectedDate))
            }
            saveAllMemos()
        } else {
            // 새 메모 추가
            memos.append(MemoData(title: title, content: content, date: selectedDate))
            saveAllMemos()
        }
    }
}
