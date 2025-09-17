import UIKit
@_exported import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore
@_exported import GoogleSignIn

// Self-updating Google button that adapts to Light/Dark without recreation.
internal final class GoogleSignInButton: UIButton
{
    private let color: ButtonColor
    private let adaptive: Bool
    
    public init(color: ButtonColor = .black, adaptive: Bool = false)
    {
            self.color = color
            self.adaptive = adaptive
            super.init(frame: .zero)
            applyStyle(for: traitCollection.userInterfaceStyle)
        }
    
    required init?(coder: NSCoder) {
            self.color = .black
            self.adaptive = false
            super.init(coder: coder)
            applyStyle(for: traitCollection.userInterfaceStyle)
        }
        
        public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            if adaptive, traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyStyle(for: traitCollection.userInterfaceStyle)
            }
        }
        
        private func applyStyle(for interfaceStyle: UIUserInterfaceStyle) {
            var effectiveColor = color
            
            if adaptive {
                if interfaceStyle == .dark {
                    effectiveColor = (color == .black) ? .white : .black
                }
            }
            
            let background: UIColor = (effectiveColor == .black) ? .black : .white
            let foreground: UIColor = (effectiveColor == .black) ? .white : .black
            
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = background
            config.baseForegroundColor = foreground
            config.title = "Sign in with Google"
            if let logo = UIImage(named: "googleLogo") {
                config.image = logo
            }
            config.imagePadding = 8
            config.cornerStyle = .medium
            
            self.configuration = config
            self.contentHorizontalAlignment = .center
            self.clipsToBounds = true
        }
    }


