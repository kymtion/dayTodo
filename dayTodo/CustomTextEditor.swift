
import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var lineSpacing: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
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
    }
}
