
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    @State private var showingWriteView = false
    @State private var selectedMemo: MemoData?
    
    var body: some View {
        List {
            Section(header: Text("오늘")) {
                ForEach(memosForSpecificDay(Date())) { memo in
                    memoRow(memo)
                }
            }
            
            Section(header: Text("내일")) {
                ForEach(memosForSpecificDay(Calendar.current.date(byAdding: .day, value: 1, to: Date())!)) { memo in
                    memoRow(memo)
                }
            }
            Section(header: Text("2일 뒤 이후")) {
                ForEach(memosFromDayOnwards(Calendar.current.date(byAdding: .day, value: 2, to: Date())!)) { memo in
                    memoRow(memo)
                }
            }
        }
        .sheet(isPresented: $showingWriteView) {
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
    
    private func memosForSpecificDay(_ date: Date) -> [MemoData] {
        viewModel.memos.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func memosFromDayOnwards(_ date: Date) -> [MemoData] {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        return viewModel.memos.filter { $0.date >= startDate }
    }
    
    
    private func memoRow(_ memo: MemoData) -> some View {
        HStack {
            if Calendar.current.isDate(memo.date, inSameDayAs: Date()) {
                Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(memo.isCompleted ? .orange : .gray)
                    .onTapGesture {
                        viewModel.toggleMemoCompletion(memo)
                    }
            }
            VStack(alignment: .leading) {
                Text(memo.title)
                    .font(.system(size: 17, weight: memo.isCompleted ? .light : .medium))
                    .opacity(memo.isCompleted ? 0.7 : 1) // 완료된 경우 투명도 적용
                    .strikethrough(memo.isCompleted, color: .black) // 완료된 경우 빗금 적용
                Text(CalendarViewModel.dateFormatter.string(from: memo.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
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



#Preview {
    HomeView()
        .environmentObject(CalendarViewModel())
}
