import InputMethodKit

@objc(MyDayiInputController)
final class MyDayiInputController: IMKInputController {
    private let engine = FakeEngine(profile: .windowsCompatible)
    private var clientGeneration: UInt64 = 0

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event else { return false }
        let client = sender as? IMKTextInput
        let composing = !engine.snapshot.composing.isEmpty
        let mapped = EventMapper.map(event, profile: engine.profile, composing: composing)
        let result = engine.handle(mapped)
        apply(result, to: client)
        if result.tabToHost {
            return false
        }
        return result.consumed
    }

    override func commitComposition(_ sender: Any!) {
        let client = sender as? IMKTextInput
        if !engine.snapshot.composing.isEmpty {
            let result = engine.handle(.enter)
            apply(result, to: client)
        }
    }

    override func cancelComposition() {
        let client = client() as? IMKTextInput
        let result = engine.cancelComposition()
        apply(result, to: client, allowCommit: false)
        super.cancelComposition()
    }

    override func deactivateServer(_ sender: Any!) {
        let client = sender as? IMKTextInput
        clientGeneration &+= 1
        let result = engine.deactivateClient()
        apply(result, to: client, allowCommit: false)
        super.deactivateServer(sender)
    }

    private func apply(_ result: EngineSnapshot, to client: IMKTextInput?, allowCommit: Bool = true) {
        let notFound = NSRange(location: NSNotFound, length: 0)
        if allowCommit, !result.commit.isEmpty {
            client?.insertText(result.commit, replacementRange: notFound)
        }
        if result.composing.isEmpty {
            client?.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: notFound)
        } else {
            let marked = NSAttributedString(string: result.composing)
            let caret = NSRange(location: result.composing.utf16.count, length: 0)
            client?.setMarkedText(marked, selectionRange: caret, replacementRange: notFound)
        }
    }
}
