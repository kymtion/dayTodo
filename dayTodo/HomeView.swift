
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: CalendarViewModel
    @State private var showingWriteView = false
    @State private var selectedMemo: MemoData?
    @State private var isEditing = false
    
    
    var body: some View {
        
        VStack {
            HStack {
                if isEditing {
                    Button("완료") {
                        isEditing = false
                    }
                } else {
                    Button("편집") {
                        isEditing = true
                    }
                }
                
                Spacer()
                
                
                Button {
                    showingWriteView = true
                    selectedMemo = nil
                    viewModel.isDateSelected = false  // 선택된 날짜가 없음으로 초기화해서 나중에 저장할때 현재날짜로 저장되도록 하기 위함!
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
               
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            if hasFutureMemos() {
                List {
                    Section(header: Text("today")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.black)
                            
                    ) {
                        ForEach(viewModel.memos, id: \.id) { memo in
                            if Calendar.current.isDate(memo.date, inSameDayAs: Date()) {
                                memoRow(memo)
                            }
                        }
                        .onMove(perform: viewModel.moveMemo)
                    }
                    
                    
                    Section(header: Text("tomorrow")) {
                        ForEach(viewModel.memos, id: \.id) { memo in
                            if Calendar.current.isDate(memo.date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) {
                                memoRow(memo)
                            }
                        }
                    }
                    
                    Section(header: Text("2 days later ~")) {
                        ForEach(viewModel.memos, id: \.id) { memo in
                            if memo.date >= Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 2, to: Date())!) {
                                memoRow(memo)
                            }
                        }
                    }
                }
                .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            } else {
                Spacer ()
                Text("새로운 일정을 추가해 보세요!")
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .regular))
                Spacer ()
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
            viewModel.updatePastIncompleteMemos()
            
        }
        .background(Color(UIColor.systemGray6))
    }
    
    private func hasFutureMemos() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return viewModel.memos.contains(where: { $0.date >= today })
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

