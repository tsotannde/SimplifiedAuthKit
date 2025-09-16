////
////  File.swift
////  SimplifiedAuthKit
////
////  Created by Developer on 9/14/25.
////
//
//import UIKit
//import AuthenticationServices
//import FirebaseAuth
//import CryptoKit
//import FirebaseCore
//
//public struct SimplifiedAuthUser
//{
//    public let uid: String?
//    public let email: String?
//    public let displayName: String?
//    public let photoURL: URL?
//}
//
//
//// MARK: - Session Helpers
//extension SimplifiedAuthKit
//{
//    @MainActor private static var authHandle: AuthStateDidChangeListenerHandle?
//    
//    /// Checks if a user is currently signed in
//    /// - Returns: `Bool` indicating whether a user is signed in.
//    public static func isSignedIn() -> Bool {
//        return Auth.auth().currentUser != nil
//    }
//
//    /// Signs out the current user
//    public static func signOut() -> Bool {
//        do {
//            try Auth.auth().signOut()
//            print("✅ Successfully signed out")
//            return true
//        } catch {
//            print("❌ Sign out failed: \(error.localizedDescription)")
//            return false
//        }
//    }
//    
//   
//
//    public static func currentUser() -> SimplifiedAuthUser?
//    {
//        guard let user = Auth.auth().currentUser else { return nil }
//        return SimplifiedAuthUser(
//            uid: user.uid,
//            email: user.email,
//            displayName: user.displayName,
//            photoURL: user.photoURL
//        )
//    }
//    
//    
//    /// Returns the current Firebase user ID (UID), or nil if not signed in.
//    public static func currentUserID() -> String? {
//        return Auth.auth().currentUser?.uid
//    }
//    
//    /// Returns the current Firebase user's email, or nil if not available.
//    public static func currentUserEmail() -> String? {
//        return Auth.auth().currentUser?.email
//    }
//    
//    /// Returns the current Firebase user's display name, or nil if not available.
//    public static func currentUserDisplayName() -> String? {
//        return Auth.auth().currentUser?.displayName
//    }
//    
//    /// Returns the current Firebase user's profile photo URL, or nil if not available.
//    public static func currentUserPhotoURL() -> URL? {
//        return Auth.auth().currentUser?.photoURL
//    }
//    
//    
//    
//    @MainActor @discardableResult
//    /// Observe Firebase auth state changes without requiring the caller to store a handle.
//        /// - Parameter completion: Closure called whenever auth state changes.
//        public static func observeAuthChanges(_ completion: @escaping (User?) -> Void) {
//            // Clean up old handle if already set
//            if let handle = authHandle {
//                Auth.auth().removeStateDidChangeListener(handle)
//            }
//            
//            authHandle = Auth.auth().addStateDidChangeListener { _, user in
//                if let user = user {
//                    print("🔄 Auth state changed: User signed in (\(user.uid))")
//                } else {
//                    print("🔄 Auth state changed: User signed out")
//                }
//                completion(user)
//            }
//        }
//    
//    /// Removes a previously added auth state change listener
//    public func removeAuthObserver(_ handle: AuthStateDidChangeListenerHandle) {
//        Auth.auth().removeStateDidChangeListener(handle)
//        print("🧹 Removed auth state listener")
//    }
//}
