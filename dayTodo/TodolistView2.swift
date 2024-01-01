import SwiftUI

struct TodolistView2: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var showingWriteView = false
    @State private var selectedMemo: MemoData?
    
    var body: some View {
        VStack {
            HStack {
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
        
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(viewModel.memos.filter { Calendar.current.isDate($0.date, inSameDayAs: viewModel.selectedDate) }, id: \.id) { memo in
                    Button(action: {
                        if selectedMemo == nil {
                            viewModel.loadMemos()
                        }
                        showingWriteView = true
                        selectedMemo = memo
                    }) {
                        HStack {
                            Text(memo.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .opacity(0.75)
                                .padding(.vertical, 10)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 1))
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                }
            }
            .padding(.top, 5)
            .padding(.horizontal, UIScreen.main.bounds.width * 0.1)
        }
        .sheet(isPresented: $showingWriteView) {
            if let selectedMemo = selectedMemo {
                WriteView(viewModel: viewModel, memo: selectedMemo)
            } else {
                WriteView(viewModel: viewModel)
            }
        }
        
    }
}








#Preview {
    TodolistView2(viewModel: CalendarViewModel())
}


