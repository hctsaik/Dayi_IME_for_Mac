import AppKit
import Carbon
import InputMethodKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var server: IMKServer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let bundleId = Bundle.main.bundleIdentifier ?? "tw.mydayi.mac.dev"
        let connection = (Bundle.main.object(forInfoDictionaryKey: "InputMethodConnectionName") as? String)
            ?? "\(bundleId)_Connection"
        server = IMKServer(name: connection, bundleIdentifier: bundleId)
        _ = MyDayiInputController.self
        let registered = TISRegisterInputSource(Bundle.main.bundleURL as CFURL)
        NSLog("myDayiMac IMKServer ready name=%@ bundle=%@ tisRegister=%d", connection, bundleId, registered)
    }
}

let delegate = AppDelegate()
let app = NSApplication.shared
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
