//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Developer on 9/14/25.
//
import FirebaseAuth
import FirebaseCore


internal class  GlobalAuthentification
{
    // MARK: - Firebase Configuration Helper
    @MainActor
    internal func ensureFirebaseConfigured() throws
    {
        if FirebaseApp.app() == nil {
            guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let options = FirebaseOptions(contentsOfFile: filePath) else {
                SimplifiedAuthKitLogger.log(SimplifiedAuthKitMessages.firebasePlistMissing, level: .error)
                throw NSError(
                    domain: "SimplifiedAuthKit",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "GoogleService-Info.plist is missing."]
                )
            }
            FirebaseApp.configure(options: options)
            SimplifiedAuthKitLogger.log(SimplifiedAuthKitMessages.firebaseConfigured, level: .info)
        }
    }
    
    // MARK: - Session Helpers
    @MainActor
    private static var authHandle: AuthStateDidChangeListenerHandle?
    
    /// Checks if a user is currently signed in.
    /// - Returns: `true` if a user is signed in, `false` otherwise.
    public static func isSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// Signs out the current user.
    /// - Returns: `true` if sign-out succeeds, `false` otherwise.
    public static func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            print("✅ Successfully signed out")
            return true
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Returns the current Firebase user as a `SimplifiedAuthUser`.
    public static func currentUser() -> SimplifiedAuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return SimplifiedAuthUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL
        )
    }
    
    /// Returns the current Firebase user ID, or nil if not signed in.
    public static func currentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// Returns the current Firebase user's email, or nil if not available.
    public static func currentUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }
    
    /// Returns the current Firebase user's display name, or nil if not available.
    public static func currentUserDisplayName() -> String? {
        return Auth.auth().currentUser?.displayName
    }
    
    /// Returns the current Firebase user's profile photo URL, or nil if not available.
    public static func currentUserPhotoURL() -> URL? {
        return Auth.auth().currentUser?.photoURL
    }
    
    /// Observes Firebase auth state changes.
    /// - Parameter completion: Closure called whenever auth state changes.
    @MainActor
    public static func observeAuthChanges(_ completion: @escaping (User?) -> Void) {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        authHandle = Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                print("🔄 Auth state changed: User signed in (\(user.uid))")
            } else {
                print("🔄 Auth state changed: User signed out")
            }
            completion(user)
        }
    }
    
    /// Removes a previously added auth state change listener.
    public func removeAuthObserver(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
        print("🧹 Removed auth state listener")
    }
}
