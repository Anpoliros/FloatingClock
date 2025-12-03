import SwiftUI

@main
struct FloatingClockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 强制横屏
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                    // 锁定横屏
                    AppDelegate.orientationLock = .landscape
                }
        }
    }
}

// MARK: - App Delegate for Orientation Lock
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
