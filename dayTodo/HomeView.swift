
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
                        .foregroundColor(.primary)
                            
                    ) {
                        ForEach(viewModel.memos, id: \.id) { memo in
                            if Calendar.current.isDate(memo.date, inSameDayAs: Date()) && memo.memoType == .todo {
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
            BannerAdView()
                .frame(width: 320, height: 50, alignment: .center)
                .cornerRadius(10)
                .padding(.bottom, 10)
            
        }
        .fullScreenCover(isPresented: $showingWriteView) {
            if let selectedMemo = selectedMemo {
                WriteView(viewModel: viewModel, memoType: .todo, memo: selectedMemo)
            } else {
                WriteView(viewModel: viewModel, memoType: .todo)
            }
        }
        
        .onAppear {
            viewModel.loadMemos()
            viewModel.updatePastIncompleteMemos()
            viewModel.routineUpdate1()
            viewModel.routineUpdate2()
            
        }
        .background(Color(UIColor.systemGray6))
    }
    
    private func hasFutureMemos() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return viewModel.memos.contains(where: { $0.date >= today })
    }
    
    
    
    private func memoRow(_ memo: MemoData) -> some View {
        HStack {
            if Calendar.current.isDate(memo.date, inSameDayAs: Date()) {
                Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(memo.isCompleted ? .orange : .gray)
                    .font(.system(size: 19))
                    .onTapGesture {
                        viewModel.toggleMemoCompletion(memo)
                    }
            }
            VStack(alignment: .leading) {
                Text(memo.title)
                    .font(.system(size: 17, weight: memo.isCompleted ? .light : .medium))
                    .opacity(memo.isCompleted ? 0.7 : 1) // 완료된 경우 투명도 적용
                    .strikethrough(memo.isCompleted, color: .primary) // 완료된 경우 빗금 적용
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

