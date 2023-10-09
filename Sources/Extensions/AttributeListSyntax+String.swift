//
//  AttributeListSyntax+String.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

extension AttributeListSyntax {
    func summarize() -> String {
        var result = ""
        
        for element in self {
            let attribute = element.cast(AttributeSyntax.self)
            // What about AvailabilityEntrySyntax, etc.?
            // Can we write some explicit code for various kinds of attributes and then have default fallback for everything else? Something like that?
            switch attribute.attributeName.text {
            case "available":
                guard let availableArgument = attribute.argument else { break }
                result += availableArgument.summarize()
            case "main":
                result += AttributeVisitor.mainAttribute
                // Case statements do not fall through by default, so the `break` keyword is not necessary.
            default:
                result += "Unknown token explanation goes here"
            }
        }
        
        return result
    }
}

extension AttributeSyntax.Argument {
    func summarize() -> String {
        var result = "@available: Indicates the platform and version on which the declaration is available.\n"
        
        // Parse the arguments to extract platform and version details.
        for token in self.tokens(viewMode: .fixedUp) {
            switch token.tokenKind {
            case .identifier(let platform):
                result += "Platform: \(platform)\n"
            case .integerLiteral(let version), .floatingLiteral(let version):
                result += "Version: \(version)\n"
            // Handle other argument types as needed.
            default:
                break
            }
        }
        
        return result
    }
}
