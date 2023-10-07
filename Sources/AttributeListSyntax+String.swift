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
        
        for attribute in self {
            let visitor = AttributeVisitor(viewMode: .fixedUp)
            visitor.walk(attribute)
            guard let attributeName = visitor.attributeName else { continue }

            switch attributeName.text {
            case "available":
                guard let availableArgument = visitor.argument else { break }
                result += summarizeAvailableAttribute(availableArgument)
            case "main":
                result += AttributeVisitor.mainAttribute
                // Case statements do not fall through by default, so the `break` keyword is not necessary.
            default:
                result += "Unknown token explanation goes here"
            }
        }
        
        return result
    }
    
    private func summarizeAvailableAttribute(_ argument: AttributeSyntax.Argument) -> String {
        var description = "@available: Indicates the platform and version on which the declaration is available.\n"
        
        // Parse the arguments to extract platform and version details.
        for token in argument.tokens(viewMode: .fixedUp) {
            switch token.tokenKind {
            case .identifier(let platform):
                description += "Platform: \(platform)\n"
            case .integerLiteral(let version), .floatingLiteral(let version):
                description += "Version: \(version)\n"
            // Handle other argument types as needed.
            default:
                break
            }
        }
        
        return description
    }
}
