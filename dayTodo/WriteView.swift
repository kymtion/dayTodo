
import SwiftUI
import Combine

struct WriteView: View {
    
    @ObservedObject var viewModel: CalendarViewModel
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var memoDate: Date?
    
    @State private var showingDetailOptions = false
    @State private var showingDatePicker = false
    @State private var newDate = Date()
    @State private var showingChangeDateMessage = false
    
    
    @FocusState private var focusedField: Field?
    var memoId: UUID?
    
    
    @Environment(\.presentationMode) var presentationMode
    @State private var alertType: AlertType?
    
    enum Field {
        case title
        case content
    }
    
    enum AlertType: Identifiable {
        case deleteConfirmation
        case emptyTitle
        
        var id: Int {
            switch self {
            case .deleteConfirmation:
                return 0
            case .emptyTitle:
                return 1
            }
        }
    }
    
    init(viewModel: CalendarViewModel, memo: MemoData? = nil) {
        self.viewModel = viewModel
        if let memo = memo {
            // 기존 메모 데이터로 초기화
            self._title = State(initialValue: memo.title)
            self._content = State(initialValue: memo.content)
            self._memoDate = State(initialValue: memo.date)
        } else {
            // 새 메모 작성을 위한 초기화
            self._title = State(initialValue: "")
            self._content = State(initialValue: "")
            self._memoDate = State(initialValue: viewModel.isDateSelected ? viewModel.selectedDate : Date())
        }
        self.memoId = memo?.id
    }
    
    var body: some View {
        VStack {
            ZStack {
                Text(CalendarViewModel.dateFormatter.string(from: memoDate ?? Date()))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
                HStack {
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                            Text("닫기")
                            
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingDetailOptions = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 20, weight: .light))
                            .opacity(0.8)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 5)
                    .actionSheet(isPresented: $showingDetailOptions) {
                        ActionSheet(
                            title: Text("옵션 선택"),
                            buttons: [
                                .default(Text("날짜 변경")) {
                                    showingDatePicker = true
                                },
                                .destructive(Text("메모 삭제")) {
                                    alertType = .deleteConfirmation
                                },
                                .cancel()
                            ]
                        )
                    }
                    
                    Button {
                        if title.isEmpty {
                            alertType = .emptyTitle
                        } else {
                            // 현재 날짜의 0시 0분을 계산
                            let todayStart = Calendar.current.startOfDay(for: Date())
                            
                            // 선택된 날짜가 todayStart보다 이전인 경우에만 메모 상태를 완료로 설정
                            if viewModel.selectedDate < todayStart {
                                viewModel.saveMemo(title: title, content: content, isCompleted: true, id: memoId)
                            } else {
                                // todayStart보다 이전이 아니라면 기존의 완료/미완료 상태 유지
                                if let id = memoId, let existingMemo = viewModel.memos.first(where: { $0.id == id }) {
                                    viewModel.saveMemo(title: title, content: content, isCompleted: existingMemo.isCompleted, id: memoId)
                                } else {
                                    // 새 메모의 경우 기본적으로 미완료 상태로 설정
                                    viewModel.saveMemo(title: title, content: content, isCompleted: false, id: memoId)
                                }
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("저장")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.orange)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 15)
                .alert(item: $alertType) { type in
                    switch type {
                    case .deleteConfirmation:
                        return Alert(
                            title: Text("메모 삭제"),
                            message: Text("메모를 삭제하시겠습니까?"),
                            primaryButton: .destructive(Text("예")) {
                                deleteMemo()
                                presentationMode.wrappedValue.dismiss()
                            },
                            secondaryButton: .cancel()
                        )
                    case .emptyTitle:
                        return Alert(
                            title: Text("알림"),
                            message: Text("제목을 입력하세요!"),
                            dismissButton: .default(Text("확인"))
                        )
                    }
                }
            }
            
            VStack {
                TextField("제목", text: $title)
                    .focused($focusedField, equals: .title)
                    .font(.system(size: 25, weight: .semibold))
                    .onSubmit {
                        focusedField = .content
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.89)
                
                
                TextEditor(text: $content)
                    .focused($focusedField, equals: .content)
                    .font(.system(size: 17)) // TextEditor에 폰트 크기 설정
                    .lineSpacing(6)
                    .foregroundColor(Color.primary.opacity(0.8))
                    .padding(.bottom, 10) // TextEditor에 패딩 설정
                    .frame(maxHeight: .infinity)
                    .frame(width: UIScreen.main.bounds.width * 0.91)
                    
            }
            .padding()
            .onAppear {
                focusedField = .title
            }
            Spacer()
        }
        .sheet(isPresented: $showingDatePicker) {
            VStack {
                DatePicker("날짜 선택", selection: $newDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(.orange)
                    .padding()
                Button {
                    if memoId == nil {
                        showingChangeDateMessage = true
                    } else {
                        if let id = memoId, let index = viewModel.memos.firstIndex(where: { $0.id == id }) {
                            let todayStart = Calendar.current.startOfDay(for: Date())
                            let isCompleted = newDate < todayStart // 과거 날짜인 경우 완료로 처리
                            
                            viewModel.memos[index].date = newDate
                            viewModel.memos[index].isCompleted = isCompleted ? true : viewModel.memos[index].isCompleted
                            viewModel.saveAllMemos()
                            memoDate = newDate
                            showingDatePicker = false
                        }
                    }
                } label: {
                    Text("날짜 변경")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .opacity(0.7)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange.opacity(0.8), lineWidth: 1))
                }
                .padding()
                if showingChangeDateMessage {
                    Text("새로 작성하는 메모의 날짜는 변경할 수 없습니다.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .padding()
                }
                
            }
        }
        
    }
    
    
    private func deleteMemo() {
        if let id = memoId {
            viewModel.deleteMemo(id: id)
            presentationMode.wrappedValue.dismiss()
        }
    }
}



#Preview {
    WriteView(viewModel: CalendarViewModel())
}
