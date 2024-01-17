
import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var lineSpacing: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        // 툴바와 '닫기' 버튼 생성
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // 키보드 아이콘 설정
        let keyboardIcon = UIImage(systemName: "keyboard.chevron.compact.down")?.withTintColor(.black, renderingMode: .alwaysOriginal) // 색상 변경
        let doneButton = UIBarButtonItem(
            image: keyboardIcon,
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let selectedRange = uiView.selectedRange
        
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        
        // 텍스트 스타일 설정
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .font: UIFont.systemFont(ofSize: 17, weight: .regular), // 크기와 두께 설정
            .foregroundColor: UIColor.black.withAlphaComponent(0.8) // 색상과 투명도 설정
        ]
        
        uiView.attributedText = NSAttributedString(string: text, attributes: attributes)
        uiView.selectedRange = selectedRange
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor
        
        init(_ textView: CustomTextEditor) {
            self.parent = textView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
        
        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
    }
}
