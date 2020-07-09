//
//  TextView.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 08.07.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import SwiftUI

struct TextView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.autoresizingMask = [.width]
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.isEditable = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.textContainerInset.height = 4
        textView.font = NSFont.monospacedSystemFont(
            ofSize: NSFont.systemFontSize,
            weight: .regular
        )
        let textStorage = HighlightedTextStorage()
        textStorage.addLayoutManager(textView.layoutManager!)
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        let parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

// MARK: - Preview

struct TextView_Previews: PreviewProvider {
    private static let text = Binding.constant(Payload.preview.rawValue)

    static var previews: some View {
        Group {
            TextView(text: text).colorScheme(.light)
            TextView(text: text).colorScheme(.dark)
        }
        .frame(width: 400, height: 200)
        .padding()
    }
}

// MARK: - Highlight

final class HighlightedTextStorage: NSTextStorage {
    private let text = NSMutableAttributedString()
    private let regex = try! NSRegularExpression(pattern: #""(?:[^"\\]|\\.)*""#)

    override var string: String { text.string }

    override func attributes(
        at location: Int,
        effectiveRange range: NSRangePointer?
    ) -> [NSAttributedString.Key: Any] {
        text.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()

        text.replaceCharacters(in: range, with: str)
        let length = str.utf16.count - range.length
        edited(.editedCharacters, range: range, changeInLength: length)

        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        beginEditing()

        text.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)

        endEditing()
    }

    override func processEditing() {
        super.processEditing()

        let paragaphRange = (string as NSString).paragraphRange(for: editedRange)
        removeAttribute(.foregroundColor, range: paragaphRange)
        addAttribute(.foregroundColor, value: NSColor.controlTextColor, range: paragaphRange)

        regex.enumerateMatches(in: string, range: paragaphRange) { result, _, _ in
            addAttribute(.foregroundColor, value: NSColor.systemRed, range: result!.range)
        }
    }
}
