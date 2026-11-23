import SwiftUI

@main
struct BirthdayReminderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Request authorization for local notifications
        NotificationManager.shared.requestAuthorization { granted in
            print("Notifications granted: \(granted)")
        }
        return true
    }
}
