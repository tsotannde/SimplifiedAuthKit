//
//  AuthButtonStyle.swift
//  SimplifiedAuthKit
//
//  Created by Developer on 9/15/25.
//


public enum AuthButtonStyle 
{
    case apple(color: ButtonColor, adaptiveToDarkMode: Bool)
    case google(color: ButtonColor, adaptiveToDarkMode: Bool)
}

public enum ButtonColor 
{
    case black
    case white
}
