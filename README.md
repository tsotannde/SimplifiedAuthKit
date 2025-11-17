<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Swift-5.9_5.10_5.11-orange?style=for-the-badge&logo=swift" />
  <img src="https://img.shields.io/badge/Platforms-iOS_14+-blue?style=for-the-badge&logo=apple" />
  <img src="https://img.shields.io/badge/Firebase-Auth-yellow?style=for-the-badge&logo=firebase" />
</p>

<h2 align="center">SimplifiedAuthKit</h2>
<h4 align="center">A lightweight Swift package that makes Firebase Authentication easier — Google & Apple Sign-In with minimal boilerplate.</h4>

---
## ✨ Why SimplifiedAuthKit?

Firebase Authentication usually requires a lot of setup:

- Configuring Firebase
- Generating and hashing nonces for Apple
- Constructing OAuth credentials
- Handling delegate callbacks
- Creating sign-in buttons
- Validating Info.plist URL schemes
- Logging and debugging

SimplifiedAuthKit wraps that into:

- **One call to sign in**
- **One call to create provider-specific buttons**  [oai_citation:0‡authkit.txt](sediment://file_00000000c35871f591b4871b4270b8f4)

---

## 🚀 Features

### Authentication Providers

| Provider | Status | Notes |
|---------|--------|-------|
| 🍎 **Sign in with Apple** | ✅ Implemented | Nonce generation, SHA256, Firebase OAuth |
| 🔵 **Sign in with Google** | ✅ Implemented | Validates reversed client ID URL scheme |
| 🔒 **Anonymous** | ⏳ Planned | |
| 🟣 **Email / Password** | ⏳ Planned | |

---

## 📦 Installation (Swift Package Manager)

1. In Xcode, go to **File → Add Packages…**
2. Enter the package URL:

   ```swift
   https://github.com/tsotnande/SimplifiedAuthKit.git
```
3.	Add the package to your app target.

⸻

⚙️ Required Setup

1. Firebase iOS Setup
	1.	Create a Firebase project and add an iOS app.
	2.	Download GoogleService-Info.plist from the Firebase console.
	3.	Add GoogleService-Info.plist to your Xcode project:
	•	Drag it into the project navigator.
	•	Make sure it is included in your app’s main target.

You can either:
	•	Call FirebaseApp.configure() yourself in AppDelegate, or
	•	Let SimplifiedAuthKit auto-configure Firebase using GoogleService-Info.plist when you call sign-in.

⸻

2. Enable Providers in Firebase Console

In the Firebase Console:
	1.	Go to Authentication → Sign-in method.
	2.	Enable the providers you plan to use:
	•	Google
	•	Apple

Follow the on-screen instructions for each provider (bundle ID, service ID, etc.).

⸻

3. iOS Configuration for Google Sign-In
	1.	Open GoogleService-Info.plist.
	2.	Copy the value of REVERSED_CLIENT_ID.
	3.	In Xcode:
	•	Select your app target → Info → URL Types.
	•	Add a new URL Type.
	•	Paste the REVERSED_CLIENT_ID into URL Schemes.
	•	Leave the other fields blank.

SimplifiedAuthKit performs a runtime check and will log a clear error if this URL scheme is missing.

⸻

4. iOS Configuration for Sign in with Apple (Optional)

If you plan to use .apple:
	1.	In Xcode, select your app target → Signing & Capabilities.
	2.	Click “+ Capability” and add “Sign in with Apple”.
	3.	Make sure the app is correctly configured in your Apple Developer account for Sign in with Apple.

If you don’t use Apple Sign-In, you don’t need this capability.

⸻

🧑‍💻 Quick Start

Create a Button (UIKit)
```swift
import SimplifiedAuthKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let googleButton = SimplifiedAuthKit.makeAuthButton(
            for: .google,
            color: .white,
            adaptive: true
        )

        googleButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        view.addSubview(googleButton)
        // Add layout constraints here…
    }

    @objc private func handleGoogleSignIn() {
        SimplifiedAuthKit.signIn(with: .google, from: self) { result in
            switch result {
            case .success(let user):
                print("Signed in:", user.email ?? "no email")
            case .failure(let error):
                print("Google sign-in failed:", error.localizedDescription)
            }
        }
    }
}
```
**Sign in with Apple**

```swift
let appleButton = SimplifiedAuthKit.makeAuthButton(
    for: .apple,
    color: .black,
    adaptive: true
)

SimplifiedAuthKit.signIn(with: .apple, from: self) { result in
    switch result {
    case .success(let user):
        print("Signed in with Apple:", user.email ?? "no email")
    case .failure(let error):
        print("Apple sign-in failed:", error.localizedDescription)
    }
}

```
⸻

🔍 API Overview

**Sign In**
```swift
SimplifiedAuthKit.signIn(  with: .google, from: viewController)
{ result in
    // Result<SimplifiedAuthUser, Error>
}
```

Create Provider Button
```swift
let button = SimplifiedAuthKit.makeAuthButton(
    for: .google,   // or .apple
    color: .black,  // .black or .white
    adaptive: true  // adapt to light/dark mode
)
```
Session Helpers
```swift
let isLoggedIn = SimplifiedAuthKit.isSignedIn()
let user = SimplifiedAuthKit.currentUser()
let uid = SimplifiedAuthKit.currentUserID()
let email = SimplifiedAuthKit.currentUserEmail()
let photoURL = SimplifiedAuthKit.currentUserPhotoURL()

_ = SimplifiedAuthKit.signOut()

Observe Auth Changes
```swift
SimplifiedAuthKit.observeAuthChanges { user in
    if let user = user {
        print("User signed in:", user.email ?? "")
    } else {
        print("User signed out")
    }
}
```

⸻

🧪 Logging
```swift
You can control how noisy logging is:
```swift
SimplifiedAuthKitLogger.level = .info     // default
// .warning
// .error
// .none
```

⸻

📄 License - MIT license.

⸻

Author - Adebayo Sotannde

