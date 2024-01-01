
import Foundation

struct MemoData: Codable, Hashable, Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
}
