import AppKit

enum EventMapper {
    static func map(_ event: NSEvent, profile: KeyboardProfile, composing: Bool) -> MappedKey {
        if event.type == .flagsChanged {
            return mapFlagsChanged(event)
        }
        guard event.type == .keyDown else {
            return .passToHost
        }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.command) || flags.contains(.control) {
            return .passToHost
        }
        if flags.contains(.option) {
            return .passToHost
        }

        if flags.contains(.shift), composing, let letterIndex = shiftLetterIndex(event) {
            return .selectIndex(letterIndex)
        }

        if flags.contains(.shift), event.keyCode == 36 {
            return .shiftEnter
        }
        if flags.contains(.shift), event.keyCode == 49 {
            return .shiftSpace
        }

        switch event.keyCode {
        case 48:
            return flags.contains(.shift) ? .shiftTab : .tab
        case 36:
            return .enter
        case 53:
            return .escape
        case 51:
            return .backspace
        case 117:
            return .delete
        case 123:
            return .left
        case 124:
            return .right
        case 125:
            return .down
        case 126:
            return .up
        case 115:
            return .home
        case 119:
            return .end
        case 116:
            return .pageUp
        case 121:
            return .pageDown
        default:
            break
        }

        if let chars = event.charactersIgnoringModifiers?.lowercased(),
           chars.count == 1,
           let ch = chars.first,
           FakeEngine.alphabet.contains(ch) {
            return .dayi(ch)
        }

        return .passToHost
    }

    private static func mapFlagsChanged(_ event: NSEvent) -> MappedKey {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let shiftDown = flags.contains(.shift)
        if !shiftDown && (event.keyCode == 56 || event.keyCode == 60) {
            return .shiftTap
        }
        return .passToHost
    }

    private static func shiftLetterIndex(_ event: NSEvent) -> Int? {
        guard let chars = event.charactersIgnoringModifiers?.uppercased(),
              chars.count == 1,
              let ch = chars.first,
              let ascii = ch.asciiValue,
              ascii >= 65, ascii <= 72 else {
            return nil
        }
        return Int(ascii - 65)
    }
}
