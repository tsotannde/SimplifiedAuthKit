import UIKit
@_exported import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore
@_exported import GoogleSignIn


public final class SimplifiedAuthKit {
    internal var currentNonce: String?
    internal weak var presentingWindow: UIWindow?
    internal weak var presentingViewController: UIViewController?
    internal var activeDelegate: AppleSignInDelegate?
    
    public init() {}
    
    // MARK: - Firebase Configuration Helper
    @MainActor
    internal func ensureFirebaseConfigured() throws {
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
    
    @MainActor
    public static func signIn(
        with provider: Provider,
        from viewController: UIViewController,
        completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void
    ) {
        switch provider {
        case .apple:
            Self.signInWithApple(from: viewController, completion: completion)
            
        case .google:
            Self.signInWithGoogle(from: viewController, completion: completion)
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
    
  
    
   
    private func handleAppleAuthorization(authorization: ASAuthorization, completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) {
        print("Handling Apple authorization")
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let idTokenString = String(data: identityToken, encoding: .utf8) else {
            let error = NSError(
                domain: "SimplifiedAuthKit",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential."]
            )
            completion(.failure(error))
            return
        }
        
        guard let nonce = currentNonce else {
            let error = NSError(
                domain: "SimplifiedAuthKit",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid state: No nonce available."]
            )
            completion(.failure(error))
            return
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                SimplifiedAuthKitLogger.log(
                    """
                    [SimplifiedAuthKit] ❌ Login Rejected — Firebase sign-in failed.
                    Reason: \(error.localizedDescription)
                    Action: Ensure Apple Sign-In is enabled in your Firebase Console (Authentication → Sign-in Method → Apple).
                    """,
                    level: .error
                )
                let firebaseError = NSError(
                    domain: "SimplifiedAuthKit",
                    code: 4,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Firebase authentication failed: \(error.localizedDescription)",
                        NSUnderlyingErrorKey: error
                    ]
                )
                completion(.failure(firebaseError))
                return
            }
            guard let authResult = authResult else {
                let error = NSError(
                    domain: "SimplifiedAuthKit",
                    code: 5,
                    userInfo: [NSLocalizedDescriptionKey: "No authentication result returned."]
                )
                completion(.failure(error))
                return
            }
            let user = SimplifiedAuthUser(
                uid: authResult.user.uid,
                email: authResult.user.email,
                displayName: authResult.user.displayName,
                photoURL: authResult.user.photoURL
            )
            SimplifiedAuthKitLogger.log(
                "✅ Signed in with Apple and Firebase: \(authResult.user.email)",
                level: .info
            )
            completion(.success(user))
        }
    }
    
    
    
    // MARK: - Google Sign-In Helper Functions
 
    
    internal final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        private let completion: (Result<SimplifiedAuthUser, Error>) -> Void
        private weak var kit: SimplifiedAuthKit?
        
        init(kit: SimplifiedAuthKit, completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) {
            self.kit = kit
            self.completion = completion
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            print("Passing data to Firebase")
            kit?.handleAppleAuthorization(authorization: authorization, completion: completion)
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            completion(.failure(error))
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow
            }
            return UIWindow()
        }
    }
}

extension ASAuthorizationAppleIDButton {
    /// Initiates Apple Sign-In when the button is tapped.
    /// - Parameters:
    ///   - vc: The view controller presenting the sign-in UI.
    ///   - completion: Closure called with the sign-in result, providing a `SimplifiedAuthUser` on success.
    public func startAppleSignIn(from vc: UIViewController, completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) {
        SimplifiedAuthKit.signInWithApple(from: vc, completion: completion)
    }
}

extension SimplifiedAuthKit
{
     @MainActor
        public static func signInWithGoogle(
            from viewController: UIViewController,
            completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void = { _ in }
        )
    {
        // Pre-check reversed client ID
            guard hasGoogleURLScheme() else {
                let error = NSError(
                    domain: "SimplifiedAuthKit",
                    code: 10,
                    userInfo: [NSLocalizedDescriptionKey: "Google Sign-In skipped: missing reversed client ID in Info.plist > URL Types."]
                )
                // Fetch the Client ID for the user
                if let requiredScheme = requiredGoogleScheme() {
                    SimplifiedAuthKitLogger.log(
                        "⚠️ Google Sign-In skipped — missing reversed client ID.\n➡️ Please add this to Info.plist > URL Types > URL Schemes: \(requiredScheme)",
                        level: .error
                    )
                } else {
                    SimplifiedAuthKitLogger.log(
                        "⚠️ Google Sign-In skipped — missing GoogleService-Info.plist or REVERSED_CLIENT_ID.",
                        level: .error
                    )
                }
                
                
                completion(.failure(error))
                return
            }

        
            let kit = SimplifiedAuthKit()
            kit.startGoogleSignIn(from: viewController, completion: completion)
        }
    
    private static func requiredGoogleScheme() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let clientID = dict["REVERSED_CLIENT_ID"] as? String else {
            return nil
        }
        return clientID
    }
    
    private static func hasGoogleURLScheme() -> Bool {
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
            return false
        }
        
        for type in urlTypes {
            if let schemes = type["CFBundleURLSchemes"] as? [String] {
                if schemes.contains(where: { $0.contains("googleusercontent.apps") }) {
                    return true
                }
            }
        }
        return false
    }
    
    @MainActor
    public static func styleGIDSignInButton() -> GIDSignInButton {
        
        let button = GIDSignInButton()
            button.style = .standard   //
            button.colorScheme = .light
            return button
    }
    

    @MainActor
    public static func makeGoogleButton(styled: Bool = true) -> UIButton {
        // Returns a self-updating button that adapts to Light/Dark mode automatically.
        return GoogleSignInButton(styled: styled)
    }
        
        @MainActor
        private func startGoogleSignIn(
            from presentingVC: UIViewController,
            completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void
        ) {
            do {
                try ensureFirebaseConfigured()
            } catch {
                completion(.failure(error))
                return
            }

            guard let clientID = FirebaseApp.app()?.options.clientID else {
                let error = NSError(
                    domain: "SimplifiedAuthKit",
                    code: 6,
                    userInfo: [NSLocalizedDescriptionKey: "Missing Firebase clientID"]
                )
                completion(.failure(error))
                return
            }

            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    let error = NSError(
                        domain: "SimplifiedAuthKit",
                        code: 7,
                        userInfo: [NSLocalizedDescriptionKey: "No Google user or token"]
                    )
                    print("Firebase Login Failed badly1")
                    completion(.failure(error))
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                              
                               
                               SimplifiedAuthKitLogger.log(
                                   """
                                    ❌ Login Rejected — Firebase sign-in with Google failed.
                                   Reason: \(error.localizedDescription)
                                   Action: Ensure Google Sign-In is enabled in your Firebase Console 
                                           (Authentication → Sign-in Method → Google) 
                                   """,
                                   level: .error
                               )
                               
                               completion(.failure(error))
                               return
                           }

                    guard let authResult = authResult else {
                        let error = NSError(
                            domain: "SimplifiedAuthKit",
                            code: 8,
                            userInfo: [NSLocalizedDescriptionKey: "No Firebase auth result"]
                        )
                        print("Firebase Login Failed badly3")
                        completion(.failure(error))
                        return
                    }

                    let simplifiedUser = SimplifiedAuthUser(
                        uid: authResult.user.uid,
                        email: authResult.user.email,
                        displayName: authResult.user.displayName,
                        photoURL: authResult.user.photoURL
                    )
                    SimplifiedAuthKitLogger.log(
                        "✅ Signed in with Google and Firebase: \(authResult.user.email)",
                        level: .info
                    )
                    completion(.success(simplifiedUser))
                }
            }
        }
    
    
}



