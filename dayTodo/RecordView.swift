
import SwiftUI

struct RecordView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    @State private var selectedYearMonth: String = "\(Calendar.current.component(.year, from: Date()))년 \(Calendar.current.component(.month, from: Date()))월"
    @State private var selectedMemo: MemoData? = nil // 선택된 메모를 관리하는 상태 변수
    @State private var showingWriteView = false  // WriteView 표시 여부
    
    var body: some View {
        VStack {
            // 연월 선택 드롭다운 메뉴
            Picker("연월", selection: $selectedYearMonth) {
                ForEach(viewModel.availableYearMonths, id: \.self) { yearMonth in
                    Text(yearMonth).tag(yearMonth)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // 선택된 연월에 해당하는 완료된 메모 목록 표시
            List {
                ForEach(groupedMemosByDate(), id: \.key) { date, memos in
                    Section(header: Text(CalendarViewModel.dateFormatter.string(from: date))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.bottom, 5)
                    ) {
                        ForEach(memos, id: \.id) { memo in
                            HStack {
                                Image(systemName: "checkmark") // 체크 표시
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange) // 오렌지색 지정
                                Text(memo.title)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.primary.opacity(0.9))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedMemo == nil {
                                    viewModel.loadMemos()
                                }
                                self.selectedMemo = memo
                                self.showingWriteView = true
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingWriteView) {
            if let selectedMemo = selectedMemo {
                WriteView(viewModel: viewModel, memo: selectedMemo)
            } else {
                WriteView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadMemos()
        }
    }
    
    private func groupedMemosByDate() -> [(key: Date, value: [MemoData])] {
        let memos = filteredMemosForYearMonth(selectedYearMonth)
        let grouped = Dictionary(grouping: memos, by: { Calendar.current.startOfDay(for: $0.date) })
        return grouped.sorted { $0.key > $1.key } // 가장 최근 날짜가 상단에 배치
    }
    
    
    // 선택된 연월에 해당하고 완료된 메모를 필터링하는 함수
    private func filteredMemosForYearMonth(_ yearMonth: String) -> [MemoData] {
        let components = yearMonth.components(separatedBy: " ")
        guard let year = Int(components[0].dropLast()), let month = Int(components[1].dropLast()) else {
            return []
        }
        
        return viewModel.memos.filter {
            let memoYear = Calendar.current.component(.year, from: $0.date)
            let memoMonth = Calendar.current.component(.month, from: $0.date)
            return memoYear == year && memoMonth == month && $0.isCompleted
        }
    }
}

#Preview {
    RecordView()
}
