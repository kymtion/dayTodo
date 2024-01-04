//
//
//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//           SimpleEntry(date: Date(), memoData: MemoData(title: "Placeholder", content: "", date: Date()))
//       }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//            let entry = SimpleEntry(date: Date(), memoData: MemoData(title: "Snapshot", content: "", date: Date()))
//            completion(entry)
//        }
//    
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//            var entries: [SimpleEntry] = []
//
//            // 여기서 실제 MemoData를 로드합니다.
//            let memos = [MemoData(title: "Memo 1", content: "Content 1", date: Date()),
//                         MemoData(title: "Memo 2", content: "Content 2", date: Date().addingTimeInterval(3600))]
//
//            for memo in memos {
//                let entry = SimpleEntry(date: memo.date, memoData: memo)
//                entries.append(entry)
//            }
//
//            let timeline = Timeline(entries: entries, policy: .atEnd)
//            completion(timeline)
//        }
//    }
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let memoData: MemoData
//}
//
//struct todolistEntryView : View {
//    var entry: SimpleEntry
//    
//    var body: some View {
//            VStack {
//                Text(entry.memoData.title)
//                    .font(.headline)
//                Text(entry.memoData.date, style: .time)
//                    .font(.caption)
//            }
//            .background(Color.clear)
//        }
//    }
//struct todolist: Widget {
//    let kind: String = "todolist"
//    
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            todolistEntryView(entry: entry)
//        }
//        .configurationDisplayName("To-Do List")
//        .description("Displays your to-do list items.")
//    }
//}
//
//
//
//#Preview(as: .systemSmall) {
//    todolist()
//} timeline: {
//    SimpleEntry(date: .now, title: "Memo 1")
//    SimpleEntry(date: .now.addingTimeInterval(3600), title: "Memo 2")
//}
