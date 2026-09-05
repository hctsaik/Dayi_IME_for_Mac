import Foundation

@inline(__always)
func expect(_ cond: Bool, _ message: String) {
    if !cond {
        fputs("FAIL \(message)\n", stderr)
        exit(1)
    }
}

@main
struct FakeEngineTests {
static func main() {
    let idle = FakeEngine()
    expect(!idle.handle(.space).consumed, "G01 idle space")
    expect(!idle.handle(.enter).consumed, "G02 idle enter")
    expect(!idle.handle(.escape).consumed, "G03 idle escape")
    expect(!idle.handle(.backspace).consumed, "G04 idle backspace")
    expect(!idle.handle(.passToHost).consumed, "G05 pass to host")

    let typeA = FakeEngine()
    let afterA = typeA.handle(.dayi("a"))
    expect(afterA.consumed, "G06 consumed")
    expect(afterA.composing == "a", "G06 composing")
    expect(afterA.candidates.contains("a"), "G06 candidate")

    let v5 = FakeEngine()
    _ = v5.handle(.dayi("v"))
    let afterV5 = v5.handle(.dayi("5"))
    expect(afterV5.composing == "v5", "G07 composing v5")

    let phrase = FakeEngine()
    for ch in "v5e5" {
        _ = phrase.handle(.dayi(ch))
    }
    expect(phrase.snapshot.composing == "v5e5", "G08 composing v5e5")

    let esc = FakeEngine()
    for ch in "qqqq" {
        _ = esc.handle(.dayi(ch))
    }
    let afterEsc = esc.handle(.escape)
    expect(afterEsc.composing.isEmpty, "G15 cleared")
    expect(afterEsc.commit.isEmpty, "G15 no commit")

    let bs = FakeEngine()
    _ = bs.handle(.dayi("a"))
    let afterBs = bs.handle(.backspace)
    expect(afterBs.composing.isEmpty, "G16 empty after backspace")
    expect(!bs.handle(.space).consumed, "G16 next space to host")

    let enter = FakeEngine()
    _ = enter.handle(.dayi("a"))
    let afterEnter = enter.handle(.enter)
    expect(afterEnter.commit == "a", "G17 commit")
    expect(!afterEnter.insertNewline, "G17 no newline")

    let winTab = FakeEngine(profile: .windowsCompatible)
    let afterTab = winTab.handle(.tab)
    expect(afterTab.asciiMode, "G18 ascii")
    expect(afterTab.consumed, "G18 consumed")

    let winComposeTab = FakeEngine(profile: .windowsCompatible)
    _ = winComposeTab.handle(.dayi("a"))
    let afterComposeTab = winComposeTab.handle(.tab)
    expect(afterComposeTab.asciiMode, "G19 ascii after tab")
    expect(afterComposeTab.commit == "a", "G19 engine commit not frontend cancel")

    let macTab = FakeEngine(profile: .macOptional)
    _ = macTab.handle(.dayi("a"))
    let afterMacTab = macTab.handle(.tab)
    expect(afterMacTab.commit.isEmpty, "G20 no commit")
    expect(afterMacTab.composing.isEmpty, "G20 cancelled")
    expect(afterMacTab.tabToHost, "G20 tab to host")
    expect(!afterMacTab.consumed, "G20 not consumed")

    let winShift = FakeEngine(profile: .windowsCompatible)
    expect(winShift.handle(.shiftTap).asciiMode, "G21 shift tap ascii")

    let macShift = FakeEngine(profile: .macOptional)
    expect(!macShift.handle(.shiftTap).asciiMode, "G22 mac shift no toggle")

    let select = FakeEngine()
    _ = select.handle(.dayi("a"))
    let afterSelect = select.handle(.selectIndex(0))
    expect(afterSelect.commit == "a", "G23 select first")

    let emptySlot = FakeEngine()
    _ = emptySlot.handle(.dayi("a"))
    let afterEmpty = emptySlot.handle(.selectIndex(1))
    expect(afterEmpty.commit.isEmpty, "G24 empty slot no commit")
    expect(afterEmpty.composing == "a", "G24 keep composing")

    let digit = FakeEngine()
    _ = digit.handle(.dayi("a"))
    let afterDigit = digit.handle(.dayi("1"))
    expect(afterDigit.composing == "a1", "G25 digit is code")

    fputs("PASS FakeEngineTests\n", stdout)
}
}
