//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Developer on 9/14/25.
//

struct SimplifiedAuthKitMessages 
{
    static let firebaseConfigured = """
    ⚡️ [SimplifiedAuthKit] Firebase was not configured. SimplifiedAuthKit has configured it for you using GoogleService-Info.plist.
    👉 Best practice: Call FirebaseApp.configure() in AppDelegate.application(_:didFinishLaunchingWithOptions:) to customize behavior.
    📖 Setup guide: https://firebase.google.com/docs/ios/setup
    💡 Ensure GoogleService-Info.plist is named exactly as downloaded from the Firebase Console and included in your Xcode project’s main bundle and build target.
    """

    static let firebasePlistMissing = """
    Unable to resolve GoogleService-Info.plist. SimplifiedAuthKit attempted to configure Firebase using Google’s default file name (GoogleService-Info.plist) but was unsuccessful.
    If you haven’t added the file, download it from the Firebase Console: https://console.firebase.google.com.
    If you intentionally renamed the file, configure Firebase manually with the updated file path.
    Ensure the file is included in your Xcode project’s main bundle and build target.
    """
}
