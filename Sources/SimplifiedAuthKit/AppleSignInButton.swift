//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Developer on 9/17/25.
//

import UIKit

public final class AppleSignInButton: UIButton 
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
        if adaptive, interfaceStyle == .dark {
            effectiveColor = (color == .black) ? .white : .black
        }

        let background: UIColor = (effectiveColor == .black) ? .black : .white
        let foreground: UIColor = (effectiveColor == .black) ? .white : .black

        self.backgroundColor = background
        self.setTitle("Sign in with Apple", for: .normal)
        self.setTitleColor(foreground, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)

       
        let logo = UIImage(systemName: "apple.logo")?.withRenderingMode(.alwaysTemplate)

        self.setImage(logo, for: .normal)
        self.tintColor = foreground
        self.imageView?.tintColor = foreground
        self.imageView?.contentMode = .scaleAspectFit

        // Manual spacing
        self.semanticContentAttribute = .forceLeftToRight
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)

        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }
    }
