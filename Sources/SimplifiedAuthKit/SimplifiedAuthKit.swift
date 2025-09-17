import UIKit
@_exported import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore
@_exported import GoogleSignIn


public final class SimplifiedAuthKit
{
    public init() {}
    
    @MainActor
    public static func signIn(with provider: Provider,from viewController: UIViewController,completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) 
    {
        switch provider 
        {
        case .apple:
            AppleProvider.signInWithApple(from: viewController, completion: completion)
        case .google:
            GoogleProvider.signInWithGoogle(from: viewController, completion: completion)
        }
    }
    
    
    @MainActor
    public static func makeAuthButton(
        for provider: Provider,
        color: ButtonColor = .black,
        adaptive: Bool = false
    ) -> UIButton {
        switch provider {
        case .apple:
            return AppleProvider.makeAppleButton(color: color, adaptive: adaptive)
        case .google:
            return GoogleProvider.makeGoogleButton(color: color, adaptive: adaptive)
        default:
            fatalError("❌ Invalid style for provider \(provider). Use the correct AuthButtonStyle case.")
        }
    }
    
    
        public static func isSignedIn() -> Bool {
            return GlobalAuthentification.isSignedIn()
        }
        
        public static func currentUser() -> SimplifiedAuthUser? {
            return GlobalAuthentification.currentUser()
        }
    
    public static func signOut() -> Bool {
        return GlobalAuthentification.signOut()
    }
    
    
    
    
   
    
  
    
   
   
    
    
    
   
 
    
    
}

extension ASAuthorizationAppleIDButton {
    /// Initiates Apple Sign-In when the button is tapped.
    /// - Parameters:
    ///   - vc: The view controller presenting the sign-in UI.
    ///   - completion: Closure called with the sign-in result, providing a `SimplifiedAuthUser` on success.
    public func startAppleSignIn(from vc: UIViewController, completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void) {
        AppleProvider.signInWithApple(from: vc, completion: completion)
    }
}


