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
            .padding(15)
            
            List {
                ForEach(viewModel.memos, id: \.id) { memo in
                    if Calendar.current.isDate(memo.date, inSameDayAs: viewModel.selectedDate) {
                        HStack {
                            Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(memo.isCompleted ? .gray : .gray)
                                .font(.system(size: 20))
                            
                            Text(memo.title)
                                .font(.system(size: 17, weight: .medium))
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
                .onMove(perform: viewModel.moveMemo)
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .fullScreenCover(isPresented: $showingWriteView) {
                if let selectedMemo = selectedMemo {
                    WriteView(viewModel: viewModel, memo: selectedMemo)
                } else {
                    WriteView(viewModel: viewModel)
                }
            }
        }
    }
}




#Preview {
    TodolistView2(viewModel: CalendarViewModel())
}


