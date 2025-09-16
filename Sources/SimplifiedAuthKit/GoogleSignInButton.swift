import UIKit
@_exported import AuthenticationServices
import FirebaseAuth
import CryptoKit
import FirebaseCore
@_exported import GoogleSignIn

// Self-updating Google button that adapts to Light/Dark without recreation.
internal final class GoogleSignInButton: UIButton
{
    private let styled: Bool
    
    init(styled: Bool) {
        self.styled = styled
        super.init(frame: .zero)
        applyStyle(for: traitCollection.userInterfaceStyle)
    }
    
    required init?(coder: NSCoder) {
        self.styled = true
        super.init(coder: coder)
        applyStyle(for: traitCollection.userInterfaceStyle)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyStyle(for: traitCollection.userInterfaceStyle)
        }
    }
    
    private func applyStyle(for interfaceStyle: UIUserInterfaceStyle) {
        let isDark = (interfaceStyle == .dark)
        
        if styled {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = isDark ? .black : .white
            config.baseForegroundColor = isDark ? .white : .black
            config.title = "Sign in with Google"
            if let logo = UIImage(named: "googleLogo")?.withRenderingMode(.alwaysOriginal) {
                config.image = logo
            }
            config.imagePadding = 8
            config.cornerStyle = .medium
            self.configuration = config
            self.contentHorizontalAlignment = .center
            self.clipsToBounds = true
            self.layer.cornerRadius = 0 // config cornerStyle is used; keep layer neutral
        } else {
            // Plain, no-corner-radius variant
            self.configuration = .plain()
            self.setTitle("Sign in with Google", for: .normal)
            if let logo = UIImage(named: "googleLogo")?.withRenderingMode(.alwaysOriginal) {
                self.setImage(logo, for: .normal)
            }
            self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            self.backgroundColor = isDark ? .black : .white
            self.setTitleColor(isDark ? .white : .black, for: .normal)
            self.contentHorizontalAlignment = .center
            self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
            self.clipsToBounds = true
            self.layer.cornerRadius = 0
        }
        
        self.setNeedsLayout()
    }
}

