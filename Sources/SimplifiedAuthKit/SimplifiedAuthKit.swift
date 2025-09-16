import UIKit
@_exported import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore
@_exported import GoogleSignIn


public final class SimplifiedAuthKit
{
    public init() {}
    
    let appleAuth = AppleAuthProvider()
   
    
    @MainActor
    public static func signIn(
        with provider: Provider,
        from viewController: UIViewController,
        completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void
    ) {
        switch provider {
        case .apple:
            AppleAuthProvider.signInWithApple(from: viewController, completion: completion)
           
            
        case .google:
            GoogleProvider.signInWithGoogle(from: viewController, completion: completion)
        }
    }
    
//    //✅
//    @MainActor
//    public static func makeAuthButton(for provider: Provider,style: AuthButtonStyle) -> UIView
//    {
//        switch (provider, style)
//        {
//        case (.apple, .apple(let appleStyle)):
//            return ASAuthorizationAppleIDButton(type: .signIn, style: appleStyle)
//
//        case (.google, .google(let styled)):
//            return GoogleProvider.makeGoogleButton(styled: styled)
//            
//        default:
//            fatalError("❌ Invalid style for provider \(provider). Use the correct AuthButtonStyle case.")
//        }
//    }
    
    @MainActor
    public static func makeAuthButton(for provider: Provider, style: AuthButtonStyle) -> UIButton {
        switch (provider, style) {
        case (.apple, .apple(let appleStyle)):
            return ASAuthorizationAppleIDButton(type: .signIn, style: appleStyle)

        case (.google, .google(let styled)):
            return GoogleProvider.makeGoogleButton(styled: styled)

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
        AppleAuthProvider.signInWithApple(from: vc, completion: completion)
    }
}


