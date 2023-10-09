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
        for element in self {
            let parameter = element.cast(FunctionParameterSyntax.self)
            result += parameter.summarize()
        }
        
        return result
    }
}

extension FunctionParameterSyntax {
    func summarize() -> String {
        var result = ""
        
        if let externalName = self.firstName?.text,
           let localName = self.secondName?.text {
            result += "- \(externalName) (\(localName)): "
        } else if let localName = self.secondName?.text {
            result += "- \(localName): "
        }
        
        if let type = self.type {
            result += "\(type.description)"
        }
                
        // TODO: Handle variadic arguments.
        
        if let defaultArg = self.defaultArgument {
            result += " (Default: \(defaultArg.description))"
        }
        
        result += "\n"
        
        return result
    }
}
