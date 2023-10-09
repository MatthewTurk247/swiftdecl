//
//  FunctionParameterListSyntax+String.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

extension FunctionParameterListSyntax {
    func summarize() -> String {
        var result = "Parameters:\n"
        for parameter in self {
            let visitor = ParameterVisitor(viewMode: .fixedUp)
            visitor.walk(parameter)
            result += summarizeParameter(visitor)
        }
        
        return result
    }
    
    private func summarizeParameter(_ visitor: ParameterVisitor) -> String {
        var description = ""
        
        if let externalName = visitor.externalName?.text,
           let localName = visitor.localName?.text {
            description += "- \(externalName) (\(localName)): "
        } else if let localName = visitor.localName?.text {
            description += "- \(localName): "
        }
        
        if let type = visitor.typeAnnotation {
            description += "\(type.description)"
        }
                
        // TODO: Handle variadic arguments.
        
        if let defaultArg = visitor.defaultArgument {
            description += " (Default: \(defaultArg.description))"
        }
        
        description += "\n"
        
        return description
    }
}
