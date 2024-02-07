

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
        SimpleEntry(date: Date(), memoData: [], family: context.family)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), memoData: [], family: context.family)
           completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // 오늘 날짜의 시작 시간을 구합니다.
        let todayStart = Calendar.current.startOfDay(for: Date())
        
        // 메모를 불러와 오늘 이후의 메모만 필터링합니다.
        let futureMemos = loadMemos().filter { $0.date >= todayStart }.sorted { $0.date < $1.date }
        let displayedMemos = Array(futureMemos.prefix(6))
        
        if !displayedMemos.isEmpty {
            let entry = SimpleEntry(date: todayStart, memoData: displayedMemos, family: context.family) // family 추가
                entries.append(entry)
        }
        
        // 다음 날 자정 시간 계산 -> 아직 아래 코드는 테스트 안해봄! 테스트 해보고 판단하자, 밤 12시에 날짜가 변경될지! 보자!
           var nextDayComponent = DateComponents()
           nextDayComponent.day = 1
           let nextMidnight = Calendar.current.date(byAdding: nextDayComponent, to: todayStart)!

           // 다음 날 자정에 대한 엔트리 추가
           let nextDayEntry = SimpleEntry(date: nextMidnight, memoData: displayedMemos, family: context.family)
           entries.append(nextDayEntry)

           // 타임라인 생성, 다음 업데이트 시간을 다음 날 자정으로 설정
           let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
           completion(timeline)
       }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let memoData: [MemoData] // 여러 메모를 저장하기 위해 배열로 변경
    let family: WidgetFamily // WidgetFamily 정보 추가
}

struct todolistEntryView : View {
    var entry: SimpleEntry
    var family: WidgetFamily  // 위젯 크기 정보 추가
    
    @Environment(\.colorScheme) var colorScheme
    
    // DateFormatter 선언
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    // DateFormatter 선언2
    let dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        // "M월 d일 EEEE" 형식 설정 (예: "3월 17일 화요일")
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 설정
        return formatter
    }()
    
    var body: some View {
        VStack {
            
            // 위젯 크기에 따른 조건적 레이아웃
            if family == .systemSmall {
                // 작은 크기 위젯에 대한 뷰
                smallWidgetView
            } else if family == .systemMedium {
                // 중간 크기 위젯에 대한 뷰
                mediumWidgetView
            } else if family == .systemLarge {
                // 큰 크기 위젯에 대한 뷰
                largeWidgetView
            }
        }
    }
    var smallWidgetView: some View {
        VStack {
            ForEach(entry.memoData.prefix(3), id: \.id) { memo in
                memoRow(memo)
            }
        }
    }
    
    var mediumWidgetView: some View {
        HStack {
                // 왼쪽에 메모 목록
                VStack {
                    ForEach(entry.memoData.prefix(3), id: \.id) { memo in
                        memoRow(memo)
                    }
                }

                // 오른쪽에 메모 목록
                VStack {
                    ForEach(entry.memoData.dropFirst(3).prefix(3), id: \.id) { memo in
                        memoRow(memo)
                    }
                }
            }
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.white)
        }
    
    private func memoRow(_ memo: MemoData) -> some View {
        HStack {
            Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(memo.isCompleted ? .orange : .gray)
            VStack(alignment: .leading) {
                Text(memo.title)
                    .font(.system(size: 13, weight: memo.isCompleted ? .light : .regular))
                    .foregroundColor(Color.primary) // 다크 모드 적응 텍스트 색상
                    .opacity(memo.isCompleted ? 0.7 : 1)
                    .strikethrough(memo.isCompleted, color: .primary)
                Text(dateFormatter.string(from: memo.date))
                    .font(.system(size: 8, weight: .regular))
                    .foregroundColor(Color.secondary)
            }
            
            
            Spacer()
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.orange.opacity(0.8), lineWidth: 1))
        .opacity(Calendar.current.isDateInToday(memo.date) ? 1.0 : 0.3)
    }
    
    var largeWidgetView: some View {
        VStack {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.orange)
                Text(dateFormatter2.string(from: Date()))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.primary)
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
                            .strikethrough(memo.isCompleted, color: .primary) // 완료된 경우 빗금 적용
                        Text(dateFormatter.string(from: memo.date))
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    Spacer ()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange.opacity(0.8), lineWidth: 1))
                .opacity(Calendar.current.isDateInToday(memo.date) ? 1.0 : 0.3)
                
            }
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
}


struct todolist: Widget {
    let kind: String = "todolist"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            todolistEntryView(entry: entry, family: entry.family)
                .widgetBackground(Color(UIColor.systemBackground))
        }
        .configurationDisplayName("dayTodo")
        .description("오늘의 할 일만 정리해서 보여드려요.")
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
