//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Adebayo Sotannde on 9/15/25.
//
import UIKit
@_exported import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore
@_exported import GoogleSignIn


//MARK: - Apple Sigin
class AppleProvider
{
    internal var currentNonce: String?
    internal weak var presentingWindow: UIWindow?
    internal weak var presentingViewController: UIViewController?
    internal var activeDelegate: AppleSignInDelegate?
    
    var globalAuth = GlobalAuthentification()
    
    @MainActor
    internal static func signInWithApple(from viewController: UIViewController,
        completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void = { _ in })
    {
        let kit = AppleProvider()
        kit.startAppleSignIn(from: viewController, completion: completion)
    }
    
    @MainActor
    private func startAppleSignIn(from presentingVC: UIViewController,
        completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) {
        print("Starting Apple Sign-In")
        do {
            try globalAuth.ensureFirebaseConfigured()
        } catch {
            completion(.failure(error))
            return
        }
        
        self.presentingViewController = presentingVC
        self.presentingWindow = presentingVC.view.window
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate(kit: self, completion: completion)
        self.activeDelegate = delegate
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
        
        objc_setAssociatedObject(controller, "appleSignInDelegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(controller, "appleSignInKit", self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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

    
    @MainActor
    public static func makeAppleButton(
        color: ButtonColor = .black,
        adaptive: Bool = false
    ) -> UIButton {
        return AppleSignInButton(color: color, adaptive: adaptive)
    }

    internal func handleAppleAuthorization(authorization: ASAuthorization, completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) {
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
}

internal final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let completion: (Result<SimplifiedAuthUser, Error>) -> Void
    private weak var kit: AppleProvider?
    
    init(kit: AppleProvider, completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) {
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
