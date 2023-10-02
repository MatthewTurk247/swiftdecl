//
//  ANSI.swift
//  swiftdecl
//
//  Created by Matthew Turk on 10/2/23.
//

import Foundation

enum ANSI: String {
    case red = "\u{001B}[31m" // \\001B[31m
    case blue = "\u{001B}[34m"
    case green = "\u{001B}[32m"
    // Add more colors as needed
    
    static let reset = "\u{001B}[0m"
    
    func wrap(_ text: any StringProtocol) -> String {
        return "\(self.rawValue)\(text)\(ANSI.reset)"
    }
}
