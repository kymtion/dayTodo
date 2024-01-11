

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func loadMemos() -> [MemoData] {
        if let userDefaults = UserDefaults(suiteName: "group.kr.com.daytodo") {
            if let savedMemos = userDefaults.object(forKey: "memos") as? Data {
                if let decodedMemos = try? JSONDecoder().decode([MemoData].self, from: savedMemos) {
                    return decodedMemos
                }
            }
        }
        return []
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), memoData: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), memoData: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // 오늘 날짜의 시작 시간을 구합니다.
        let todayStart = Calendar.current.startOfDay(for: Date())
        
        // 메모를 불러와 오늘 이후의 메모만 필터링합니다.
        let futureMemos = loadMemos().filter { $0.date >= todayStart }
        let displayedMemos = Array(futureMemos.prefix(6))
        
        if !displayedMemos.isEmpty {
            let entry = SimpleEntry(date: todayStart, memoData: displayedMemos)
            entries.append(entry)
        }
        
        
        // 타임라인을 생성하고, 다음 업데이트 시간을 자정으로 설정합니다.
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let memoData: [MemoData] // 여러 메모를 저장하기 위해 배열로 변경
}

struct todolistEntryView : View {
    var entry: SimpleEntry
    
    // DateFormatter 선언
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.orange)
                Text ("To Do List")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                Spacer ()
            }
            .padding(.horizontal)
            ForEach(entry.memoData, id: \.id) { memo in
                HStack {
                    if memo.isCompleted {
                        Image(systemName: "checkmark.circle.fill") // 완료된 메모에는 체크 아이콘을 표시
                            .foregroundColor(.orange) // 완료된 메모의 체크 아이콘 색상
                    } else {
                        Image(systemName: "circle") // 미완료 메모에는 빈 원을 표시
                            .foregroundColor(.gray) // 미완료 메모의 빈 원 색상
                    }
                    
                    VStack(alignment: .leading) {
                        Text(memo.title)
                            .font(.system(size: 15, weight: memo.isCompleted ? .light : .regular))
                            .opacity(memo.isCompleted ? 0.7 : 1) // 완료된 경우 투명도 적용
                            .strikethrough(memo.isCompleted, color: .black) // 완료된 경우 빗금 적용
                        Text(dateFormatter.string(from: memo.date))
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    Spacer ()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange.opacity(0.8), lineWidth: 1))
                .opacity(Calendar.current.isDateInToday(memo.date) ? 1.0 : 0.3)
                
            }
            Spacer()
        }
    }
}


struct todolist: Widget {
    let kind: String = "todolist"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            todolistEntryView(entry: entry)
                .widgetBackground(Color(UIColor.white))
        }
        .configurationDisplayName("To-Do List")
        .description("Displays your to-do list items.")
    }
}

extension View {
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                color
            }
        } else {
            return background(color)
        }
    }
}


//
//#Preview(as: .systemSmall) {
//    todolist()
//} timeline: {
//    SimpleEntry(date: .now, title: "Memo 1")
//    SimpleEntry(date: .now.addingTimeInterval(3600), title: "Memo 2")
//}
