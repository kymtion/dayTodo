
import Foundation

enum MemoType: String, Codable {
    case todo = "Todo"
    case routine = "Routine"
}

struct MemoData: Codable, Hashable, Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
    var isCompleted: Bool = false
    var memoType: MemoType
}
