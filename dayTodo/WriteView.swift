
import SwiftUI
import Combine

struct WriteView: View {
    
    @ObservedObject var viewModel: CalendarViewModel
    @State private var title: String = ""
    @State private var content: String = ""
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
        } else {
            // 새 메모 작성을 위한 초기화
            self._title = State(initialValue: "")
            self._content = State(initialValue: "")
        }
        self.memoId = memo?.id
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    alertType = .deleteConfirmation
                } label: {
                    Image(systemName: "trash")
                }
                .foregroundColor(.orange)
                
                
                
                Spacer()
                Button("저장") {
                    if title.isEmpty {
                        alertType = .emptyTitle
                    } else {
                        // 현재 날짜의 0시 0분을 계산
                        let todayStart = Calendar.current.startOfDay(for: Date())
                        
                        // 선택된 날짜가 todayStart보다 이전이라면, 메모 상태를 완료로 설정
                        if viewModel.selectedDate < todayStart {
                            viewModel.saveMemo(title: title, content: content, isCompleted: true, id: memoId)
                        } else {
                            viewModel.saveMemo(title: title, content: content, isCompleted: false, id: memoId)
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(.orange)
            }
            .padding(20)
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
                    .font(.system(size: 18, weight: .regular))
                    .opacity(0.8)
                    .background(Color(UIColor.systemBackground))
                    .frame(maxHeight: .infinity)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
            }
            .padding()
            .onAppear {
                focusedField = .title
            }
            Spacer()
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
