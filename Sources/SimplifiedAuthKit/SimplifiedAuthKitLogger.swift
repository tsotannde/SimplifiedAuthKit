//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Developer on 9/14/25.
//

import Foundation

public enum SimplifiedAuthKitLogLevel: Int {
    case none      // No logs
    case error     // Only errors
    case warning   // Errors + warnings
    case info      // Everything
}


public struct SimplifiedAuthKitLogger 
{
    
    nonisolated(unsafe) public static var level: SimplifiedAuthKitLogLevel = .info
    
    static func log(_ message: String, level: SimplifiedAuthKitLogLevel) 
    {
        guard level.rawValue <= Self.level.rawValue else { return }
        print("[SimplifiedAuthKit] \(message)")
    }
}
