import Carbon
import Foundation

func str(_ src: TISInputSource, _ key: CFString) -> String {
    guard let raw = TISGetInputSourceProperty(src, key) else { return "" }
    return Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
}

let url = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Input Methods/myDayiMac.app")
print("register=\(TISRegisterInputSource(url as CFURL))")

guard let cfList = TISCreateInputSourceList(nil, true)?.takeRetainedValue() else {
    print("no list")
    exit(1)
}
let list = cfList as! [TISInputSource]
print("total=\(list.count)")
for src in list {
    let kind = str(src, kTISPropertyInputSourceType)
    let cat = str(src, kTISPropertyInputSourceCategory)
    if kind.contains("InputMethod") || cat.contains("InputMethod") || kind.contains("Mode") {
        let id = str(src, kTISPropertyInputSourceID)
        let name = str(src, kTISPropertyLocalizedName)
        let bundle = str(src, kTISPropertyBundleID)
        print("IM kind=\(kind) id=\(id) name=\(name) bundle=\(bundle)")
    }
}
