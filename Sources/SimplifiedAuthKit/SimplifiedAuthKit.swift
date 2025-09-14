// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore

public final class SimplifiedAuthKit 
{
    
    fileprivate var currentNonce: String?
    private weak var presentingWindow: UIWindow?
    private weak var presentingViewController: UIViewController?
    public typealias AppleSignInResult = Result<ASAuthorization, Error>
    private var activeDelegate: AppleSignInDelegate?   //keep delegate alive
   
    @MainActor public static var sharedKit: SimplifiedAuthKit?
    
    
    
    // MARK: - Firebase Configuration Helper 
    private func ensureFirebaseConfigured() {
        if FirebaseApp.app() == nil {
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
                print("⚡️ [SimplifiedAuthKit] Firebase was not configured. SimplifiedAuthKit has configured it for you.\n👉 Best practice: call FirebaseApp.configure() inside AppDelegate.application(_:didFinishLaunchingWithOptions:) to customize behavior.")
            } else {
                print("⚠️ Warning: GoogleService-Info.plist is missing. Firebase will not be configured.")
            }
        }
    }
    

    /// Creates a fully configured **Sign in with Apple** button.
    ///
    /// - Automatically applies Apple’s official styling.
    /// - Optionally wires up the tap event to start the Apple sign-in flow.
    /// - Handles all delegate boilerplate and surfaces results via a completion handler.
    ///
    /// Usage:
    /// ```swift
    /// // Simple: just a styled button, no sign-in action
    /// let button = SimplifiedAuthKit.makeAppleButton(from: self)
    ///
    /// // Full flow: styled button + sign-in with completion
    /// let button = SimplifiedAuthKit.makeAppleButton(from: self) { result in
    ///     switch result {
    ///     case .success(let authorization):
    ///         print("✅ Signed in: \(authorization)")
    ///     case .failure(let error):
    ///         print("❌ Error: \(error.localizedDescription)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - vc: The presenting view controller for the sign-in flow.
    ///   - completion: Optional. If provided, the button will automatically
    ///     initiate Apple sign-in and call this handler with success or failure.
    /// - Returns: A ready-to-use `ASAuthorizationAppleIDButton`.


    // 1. Full version (with completion)

//    public static func makeAppleButton(
//        from vc: UIViewController,
//        completion: ((AppleSignInResult) -> Void)? = nil
//    ) -> ASAuthorizationAppleIDButton {
//        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
//
//        if let completion = completion {
//            button.addAction(UIAction { _ in
//                SimplifiedAuthKit().startAppleSignIn(from: vc, completion: completion)
//            }, for: .touchUpInside)
//        }
//
//        return button
//    }
    
//    @MainActor
//    public static func makeAppleButton(  f
//        from vc: UIViewController,
//        completion: @escaping (AppleSignInSimpleResult) -> Void
//    ) -> ASAuthorizationAppleIDButton {
//        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
//
//        button.addAction(UIAction { _ in
//            SimplifiedAuthKit().startAppleSignIn(from: vc) { result in
//                switch result {
//                case .success(let authorization):
//                    completion(.success("✅ Signed in: \(authorization)"))
//    
//                case .failure(let error):
//                    completion(.failure("❌ Sign in failed: \(error.localizedDescription)", error))
//                }
//            }
//        }, for: .touchUpInside)
//
//        return button
//    }
//   

    
    @MainActor
    public static func makeAppleButton(
        from vc: UIViewController,
        completion: ((AppleSignInResult) -> Void)? = nil
    ) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

        if let completion = completion {
            button.addAction(UIAction { _ in
                SimplifiedAuthKit().startAppleSignIn(from: vc, completion: completion)
            }, for: .touchUpInside)
        }

        return button
    }
    
  
    //
    
    private final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
        private let completion: (SimplifiedAuthKit.AppleSignInResult) -> Void
            private weak var kit: SimplifiedAuthKit?

            init(kit: SimplifiedAuthKit, completion: @escaping (SimplifiedAuthKit.AppleSignInResult) -> Void) 
        {
                self.kit = kit
                self.completion = completion
            }
        
        func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithAuthorization authorization: ASAuthorization) {
               // Tell the caller
               completion(.success(authorization))
               // 🔑 Also sign into Firebase
            print("Passing data to firebase")
               kit?.handleAppleAuthorization(authorization: authorization)
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

//MARK: - Apple Sigin in Helper Functions
extension SimplifiedAuthKit
{
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func handleAppleAuthorization(authorization: ASAuthorization) {
        print("Someone Called me not you!")
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken,
           let idTokenString = String(data: identityToken, encoding: .utf8) {
            
            guard let nonce = currentNonce else
            {
                fatalError("Invalid state: No login request was sent.")
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            Auth.auth().signIn(with: credential)
            { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    return
                }
                print("✅ Signed in with Apple and Firebase: \(String(describing: authResult?.user.uid))")
                
                
            }
        }
    }
    
    
    @MainActor 
    func startAppleSignIn(
        from presentingVC: UIViewController,
        completion: @escaping (AppleSignInResult) -> Void
    )
    {
        print("Latest Varson")
        ensureFirebaseConfigured()  //Checking if Firebase is Configured
        
        self.presentingViewController = presentingVC
        self.presentingWindow = presentingVC.view.window
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate(kit: self, completion: completion)
        self.activeDelegate = delegate   // retained by the kit
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
        
        // Keep delegate alive during sign-in
        objc_setAssociatedObject(controller, "appleSignInDelegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(controller, "appleSignInKit", self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
   
}

//





extension ASAuthorizationAppleIDButton 
{
    public func startAppleSignIn(from vc: UIViewController,
                                 completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        SimplifiedAuthKit().startAppleSignIn(from: vc, completion: completion)
    }
}
