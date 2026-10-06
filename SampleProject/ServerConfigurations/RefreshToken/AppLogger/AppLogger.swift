//
//  AppLogger.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import Foundation

enum Log {
    enum level {
        case error, warning, info
        
        fileprivate var prefix: String {
            switch self {
            case .error:
                "ERROR ❌"
            case .warning:
                "WARNING ⚠️"
            case .info:
                "INFO ℹ️"
            }
        }
    }
    
    struct Context {
        let file: String
        let function: String
        let line: Int
        var fileName: String {
            return "\((file as NSString).lastPathComponent)"
        }
        var description: String {
            return "\(fileName): \(line) \(function)"
        }
    }
    
    static func info(_ message: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        self.handleLog(level: .info, message: message, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func warning(_ message: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        self.handleLog(level: .warning, message: message, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func error(_ message: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        self.handleLog(level: .error, message: message, shouldLogContext: shouldLogContext, context: context)
    }
    
    fileprivate static func handleLog(level: level, message: String, shouldLogContext: Bool, context: Context) {
        let messageWithPrefix = ["[\(level.prefix)]", message]
        var fullLogString = messageWithPrefix.joined(separator: " ")
        if shouldLogContext {
            fullLogString += " → \(context.description)"
        }
        
        debugPrint(fullLogString)
    }
}
