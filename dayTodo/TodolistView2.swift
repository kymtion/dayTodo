import SwiftUI

struct TodolistView2: View {
    @ObservedObject var viewModel: CalendarViewModel
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
                    
                    Spacer()
                    Text(CalendarViewModel.dateFormatter.string(from: viewModel.selectedDate))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                    Spacer()
                    
                    Button {
                        showingWriteView = true
                        selectedMemo = nil // 새 메모 작성
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 10)
            
            List {
                ForEach(viewModel.memos, id: \.id) { memo in
                    // 오늘 날짜인지 확인
                    let isToday = Calendar.current.isDateInToday(viewModel.selectedDate)
                    
                    // 선택된 날짜에 해당하는 메모인지 확인
                    let isSelectedDate = Calendar.current.isDate(memo.date, inSameDayAs: viewModel.selectedDate)
                    
                    // 오늘 날짜와 선택된 날짜가 동일할 때 todo 타입의 메모만 표시
                    if isToday && isSelectedDate && memo.memoType == .todo {
                        memoRow(memo)
                    } else if !isToday && isSelectedDate {
                        // 다른 날짜인 경우 모든 메모 타입 표시
                        memoRow(memo)
                    }
                }
                .onMove(perform: viewModel.moveMemo)
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .fullScreenCover(isPresented: $showingWriteView) {
                if let selectedMemo = selectedMemo {
                    WriteView(viewModel: viewModel, memoType: .todo, memo: selectedMemo)
                } else {
                    WriteView(viewModel: viewModel, memoType: .todo)
                }
            }
        }
    }
    
    private func memoRow(_ memo: MemoData) -> some View {
        HStack {
            Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(memo.isCompleted ? .gray : .gray)
                .font(.system(size: 20))
            
            Text(memo.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.primary)
                .padding(.vertical, 7)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 17))
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            
            if selectedMemo == nil {
                viewModel.loadMemos()
            }
            showingWriteView = true
            selectedMemo = memo
            
        }
    }
    
}




#Preview {
    TodolistView2(viewModel: CalendarViewModel())
}


