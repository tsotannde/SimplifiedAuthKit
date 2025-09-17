//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Adebayo Sotannde on 9/15/25.
//

import FirebaseAuth
import FirebaseCore

class GoogleProvider
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

       
           let kit = GoogleProvider()
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
   public static func makeGoogleButton(
    color: ButtonColor = .black,
    adaptive: Bool = false
) -> UIButton {
       
       return GoogleSignInButton(color: color, adaptive: adaptive)
   }
       
       @MainActor
       private func startGoogleSignIn(
           from presentingVC: UIViewController,
           completion: @escaping (Result<SimplifiedAuthUser, Error>) -> Void
       ) {
           do {
               try GlobalAuthentification().ensureFirebaseConfigured()
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
