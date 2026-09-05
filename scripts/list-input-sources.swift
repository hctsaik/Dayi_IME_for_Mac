import Carbon
import Foundation

func cfString(_ src: TISInputSource, _ key: CFString) -> String {
    guard let raw = TISGetInputSourceProperty(src, key) else { return "" }
    return Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
}

let url = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Input Methods/myDayiMac.app")
print("TISRegisterInputSource=\(TISRegisterInputSource(url as CFURL))")

guard let cfList = TISCreateInputSourceList(nil, true)?.takeRetainedValue() else {
    print("list failed")
    exit(1)
}
let list = cfList as! [TISInputSource]
print("count=\(list.count)")
var hits = 0
for src in list {
    let id = cfString(src, kTISPropertyInputSourceID)
    let name = cfString(src, kTISPropertyLocalizedName)
    let bundle = cfString(src, kTISPropertyBundleID)
    let blob = (id + name + bundle).lowercased()
    if blob.contains("dayi") || blob.contains("mydayi") || bundle.contains("tw.mydayi") {
        print("HIT id=\(id) name=\(name) bundle=\(bundle)")
        hits += 1
    }
}
print("hits=\(hits)")
