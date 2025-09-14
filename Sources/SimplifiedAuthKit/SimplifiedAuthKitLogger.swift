//
//  File.swift
//  SimplifiedAuthKit
//
//  Created by Developer on 9/14/25.
//

import Foundation
import os

public enum SimplifiedAuthKitLogLevel: Int {
    case none      // No logs
    case error     // Only errors
    case warning   // Errors + warnings
    case info      // Everything
}


public struct SimplifiedAuthKitLogger 
{
    
    nonisolated(unsafe) public static var level: SimplifiedAuthKitLogLevel = .info
    
    private static let logger = Logger(subsystem: "com.simplifiedauthkit", category: "general")
    
    static func log(_ message: String, level: SimplifiedAuthKitLogLevel) 
    {
        guard level.rawValue <= Self.level.rawValue else { return }
        let prefixedMessage = "[SimplifiedAuthKit] \(message)"
        switch level {
        case .error:
            logger.error("\(prefixedMessage, privacy: .public)")
        case .warning:
            logger.warning("\(prefixedMessage, privacy: .public)")
        case .info:
            logger.info("\(prefixedMessage, privacy: .public)")
        case .none:
            break
        }
    }
}
