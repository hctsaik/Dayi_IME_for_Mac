import Foundation

public enum KeyboardProfile: String, Codable {
    case windowsCompatible = "windows-compatible"
    case macOptional = "mac-optional"
}

public enum MappedKey: Equatable {
    case dayi(Character)
    case space
    case enter
    case escape
    case backspace
    case delete
    case tab
    case shiftTab
    case shiftTap
    case shiftEnter
    case shiftSpace
    case selectIndex(Int)
    case up, down, left, right, home, end, pageUp, pageDown
    case passToHost
}

public struct EngineSnapshot: Equatable {
    public var composing: String
    public var commit: String
    public var candidates: [String]
    public var highlighted: Int
    public var pageIndex: Int
    public var asciiMode: Bool
    public var consumed: Bool
    public var insertNewline: Bool
    public var tabToHost: Bool

    public static let idle = EngineSnapshot(
        composing: "",
        commit: "",
        candidates: [],
        highlighted: 0,
        pageIndex: 0,
        asciiMode: false,
        consumed: false,
        insertNewline: false,
        tabToHost: false
    )
}

public final class FakeEngine {
    public static let alphabet = Set("0123456789/.,;abcdefghijklmnopqrstuvwxyz")
    public static let pageSize = 8

    public private(set) var profile: KeyboardProfile
    public private(set) var snapshot: EngineSnapshot = .idle
    public private(set) var generation: UInt64 = 0
    public private(set) var compositionId: UInt64 = 0
    public private(set) var candidateEpoch: UInt64 = 0

    public init(profile: KeyboardProfile = .windowsCompatible) {
        self.profile = profile
    }

    public func setProfile(_ profile: KeyboardProfile) {
        cancel(commit: false)
        self.profile = profile
    }

    @discardableResult
    public func handle(_ key: MappedKey) -> EngineSnapshot {
        var next = snapshot
        next.commit = ""
        next.insertNewline = false
        next.tabToHost = false
        next.consumed = false

        if next.asciiMode {
            return handleAscii(key, next)
        }

        switch key {
        case .passToHost:
            next.consumed = false
            snapshot = next
            return snapshot
        case .dayi(let ch):
            appendCode(ch, into: &next)
        case .space:
            if next.composing.isEmpty {
                next.consumed = false
            } else {
                commitCurrent(from: &next)
            }
        case .enter:
            if next.composing.isEmpty {
                next.consumed = false
            } else {
                commitCurrent(from: &next)
                next.insertNewline = false
            }
        case .shiftEnter:
            if profile == .windowsCompatible, !next.composing.isEmpty, next.candidates.isEmpty {
                next.commit = next.composing
                clearComposition(&next)
                next.consumed = true
            } else if next.composing.isEmpty {
                next.consumed = false
            } else {
                commitCurrent(from: &next)
            }
        case .escape:
            if next.composing.isEmpty {
                next.consumed = false
            } else {
                cancel(into: &next)
            }
        case .backspace:
            if next.composing.isEmpty {
                next.consumed = false
            } else {
                next.composing.removeLast()
                next.consumed = true
                refreshCandidates(&next)
                if next.composing.isEmpty {
                    clearComposition(&next)
                }
            }
        case .delete:
            if next.composing.isEmpty {
                next.consumed = false
            } else {
                next.composing.removeLast()
                next.consumed = true
                refreshCandidates(&next)
                if next.composing.isEmpty {
                    clearComposition(&next)
                }
            }
        case .tab:
            handleTab(into: &next)
        case .shiftTab:
            next.consumed = false
        case .shiftTap:
            if profile == .windowsCompatible {
                next.asciiMode = true
                if !next.composing.isEmpty {
                    commitCurrent(from: &next)
                } else {
                    next.consumed = true
                }
            } else {
                next.consumed = false
            }
        case .shiftSpace:
            next.consumed = false
        case .selectIndex(let index):
            selectCandidate(index, into: &next)
        case .up:
            moveHighlight(-1, into: &next)
        case .down:
            moveHighlight(1, into: &next)
        case .pageUp:
            page(-1, into: &next)
        case .pageDown:
            page(1, into: &next)
        case .left, .right, .home, .end:
            next.consumed = !next.composing.isEmpty
        }

        snapshot = next
        return snapshot
    }

    public func cancelComposition() -> EngineSnapshot {
        var next = snapshot
        cancel(into: &next)
        snapshot = next
        return snapshot
    }

    public func deactivateClient() -> EngineSnapshot {
        generation &+= 1
        return cancelComposition()
    }

    private func handleAscii(_ key: MappedKey, _ state: EngineSnapshot) -> EngineSnapshot {
        var next = state
        next.commit = ""
        switch key {
        case .tab, .shiftTap:
            next.asciiMode = false
            next.consumed = true
        default:
            next.consumed = false
        }
        snapshot = next
        return snapshot
    }

    private func appendCode(_ ch: Character, into state: inout EngineSnapshot) {
        if state.composing.isEmpty {
            compositionId &+= 1
        }
        state.composing.append(ch)
        state.consumed = true
        refreshCandidates(&state)
    }

    private func refreshCandidates(_ state: inout EngineSnapshot) {
        candidateEpoch &+= 1
        if state.composing.isEmpty {
            state.candidates = []
            state.highlighted = 0
            state.pageIndex = 0
            return
        }
        // Fake engine: first candidate is the raw composition so TextEdit can prove round-trip.
        state.candidates = [state.composing]
        state.highlighted = 0
        state.pageIndex = 0
    }

    private func commitCurrent(from state: inout EngineSnapshot) {
        if let first = state.candidates.first, !first.isEmpty {
            state.commit = first
        } else if !state.composing.isEmpty {
            state.commit = state.composing
        }
        clearComposition(&state)
        state.consumed = true
    }

    private func selectCandidate(_ index: Int, into state: inout EngineSnapshot) {
        guard !state.composing.isEmpty else {
            state.consumed = false
            return
        }
        let start = state.pageIndex * FakeEngine.pageSize
        let absolute = start + index
        if absolute >= 0, absolute < state.candidates.count {
            state.commit = state.candidates[absolute]
            clearComposition(&state)
            state.consumed = true
        } else {
            state.consumed = true
            state.commit = ""
        }
    }

    private func moveHighlight(_ delta: Int, into state: inout EngineSnapshot) {
        guard !state.candidates.isEmpty else {
            state.consumed = !state.composing.isEmpty
            return
        }
        let maxIndex = state.candidates.count - 1
        state.highlighted = min(maxIndex, max(0, state.highlighted + delta))
        state.consumed = true
    }

    private func page(_ delta: Int, into state: inout EngineSnapshot) {
        guard !state.composing.isEmpty else {
            state.consumed = false
            return
        }
        let pages = max(1, (state.candidates.count + FakeEngine.pageSize - 1) / FakeEngine.pageSize)
        state.pageIndex = min(pages - 1, max(0, state.pageIndex + delta))
        state.consumed = true
    }

    private func handleTab(into state: inout EngineSnapshot) {
        switch profile {
        case .windowsCompatible:
            state.asciiMode = !state.asciiMode
            if !state.composing.isEmpty {
                commitCurrent(from: &state)
            } else {
                state.consumed = true
            }
        case .macOptional:
            if state.composing.isEmpty {
                state.consumed = false
                state.tabToHost = true
            } else {
                cancel(into: &state)
                state.tabToHost = true
                state.consumed = false
            }
        }
    }

    private func cancel(into state: inout EngineSnapshot) {
        if state.composing.isEmpty {
            state.consumed = false
            return
        }
        clearComposition(&state)
        state.commit = ""
        state.consumed = true
        generation &+= 1
    }

    private func cancel(commit: Bool) {
        var next = snapshot
        if commit {
            commitCurrent(from: &next)
        } else {
            cancel(into: &next)
        }
        snapshot = next
    }

    private func clearComposition(_ state: inout EngineSnapshot) {
        state.composing = ""
        state.candidates = []
        state.highlighted = 0
        state.pageIndex = 0
        candidateEpoch &+= 1
    }
}
