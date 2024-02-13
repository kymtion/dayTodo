

import SwiftUI

struct RoutineView: View {
    
    @EnvironmentObject var viewModel: CalendarViewModel
    @State private var showingWriteView = false
    @State private var selectedMemo: MemoData? = nil
    @State private var isEditing = false
    @State private var showingAlert = false
    
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
                    selectedMemo = nil
                    showingWriteView = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 5)
            
            
            if filteredMemosIsEmpty() {
                Spacer()
                Text("루틴을 등록하세요!")
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .regular))
                Spacer()
            } else {
                List {
                    Section(header: Text(todayDateString())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 5)
                    ) {
                        ForEach(viewModel.memos, id: \.id) { memo in
                            if Calendar.current.isDateInToday(memo.date) && memo.memoType == .routine {
                                HStack {
                                    Image(systemName: memo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(memo.isCompleted ? .orange : .gray)
                                        .font(.system(size: 19))
                                        .onTapGesture {
                                            viewModel.toggleMemoCompletion(memo)
                                        }
                                    
                                    Text(memo.title)
                                        .font(.system(size: 17, weight: memo.isCompleted ? .light : .medium))
                                        .opacity(memo.isCompleted ? 0.7 : 1)
                                        .strikethrough(memo.isCompleted, color: .primary)
                                    
                                    Spacer()
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(action: {
                                        selectedMemo = memo // 현재 스와이프한 메모를 selectedMemo에 할당
                                        showingAlert = true
                                    }) {
                                        Image(systemName: "note.text")
                                    }
                                    .tint(.orange) // 버튼 색상 설정
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // 아래 조건문 코드가 없으면 처음에 메모를 클릭하면 빈 메모만 나오는 오류가 생김!! 꼭필요함
                                    if selectedMemo == nil {
                                        viewModel.loadMemos()
                                    }
                                    self.selectedMemo = memo
                                    self.showingWriteView = true
                                }
                            }
                        }
                        .onMove(perform: viewModel.moveMemo)
                    }
                }
                .alert("<To do list>에 추가하시겠습니까?", isPresented: $showingAlert) {
                    Button("예") {
                        if let memoToAdd = selectedMemo {
                            viewModel.addToDoList(memo: memoToAdd) // 선택된 메모를 기반으로 함수 호출
                            selectedMemo = nil // 함수 호출 후 selectedMemo를 초기화
                        }
                    }
                    Button("아니요", role: .cancel) {
                        selectedMemo = nil // "아니요"를 선택했을 때 selectedMemo를 초기화
                    }
                }
                .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            }
        }
        .fullScreenCover(isPresented: $showingWriteView) {
            // 선택된 메모가 있으면 해당 메모와 함께 WriteView 표시, 없으면 새 메모 작성
            if let selectedMemo = selectedMemo {
                WriteView(viewModel: viewModel, memoType: .routine, memo: selectedMemo)
            } else {
                WriteView(viewModel: viewModel, memoType: .routine)
            }
        }
        
        .onAppear {
            viewModel.loadMemos()
            viewModel.routineUpdate1()
            viewModel.routineUpdate2()
        }
        .background(Color(UIColor.systemGray6))
    }
    

    
    // 메모 타입이 루틴이고 오늘 날짜에 해당하는 메모가 없는지 검사하는 함수
    private func filteredMemosIsEmpty() -> Bool {
        return !viewModel.memos.contains(where: { memo in
            Calendar.current.isDateInToday(memo.date) && memo.memoType == .routine
        })
    }
    
    
    // 오늘 날짜를 "M월 d일 EEEE" 형식으로 변환하는 함수
    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

//#Preview {
//    RoutineView()
//}
