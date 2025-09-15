//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Developer on 9/14/25.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore


// MARK: - Session Helpers
extension SimplifiedAuthKit
{
    
    /// Checks if a user is currently signed in
    /// - Parameter completion: Optional. If provided, the result will be passed asynchronously.
    /// - Returns: `Bool` if called synchronously.
    @discardableResult
    public func isSignedIn(completion: ((Bool) -> Void)? = nil) -> Bool {
        let signedIn = Auth.auth().currentUser != nil
        
        if signedIn {
            print("✅ User is signed in")
        } else {
            print("⚠️ No user is signed in")
        }
        
        // Fire completion if provided
        completion?(signedIn)
        
        return signedIn
    }
//    public func isSignedIn(completion: ((Bool) -> Void)? = nil) -> Bool {
//        let signedIn = Auth.auth().currentUser != nil
//        
//        if signedIn {
//            print("✅ User is signed in")
//        } else {
//            print("⚠️ No user is signed in")
//        }
//        
//        // Call completion if one was provided
//        completion?(signedIn)
//        
//        return signedIn
//    }
//    

    /// Signs out the current user
    @discardableResult
    public func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            print("✅ Successfully signed out")
            return true
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
            return false
        }
    }
    
    //
    
    
    @discardableResult
    public func observeAuthChanges(completion: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        let handle = Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                print("🔄 Auth state changed: User signed in (\(user.uid))")
            } else {
                print("🔄 Auth state changed: User signed out")
            }
            completion(user)
        }
        return handle
    }
    
    /// Removes a previously added auth state change listener
    public func removeAuthObserver(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
        print("🧹 Removed auth state listener")
    }
}
