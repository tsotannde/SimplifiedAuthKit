//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Adebayo Sotannde on 9/15/25.
//

/// A lightweight struct containing user information after sign-in.
public struct SimplifiedAuthUser
{
    public let uid: String?
    public let email: String?
    public let displayName: String?
    public let photoURL: URL?
}
