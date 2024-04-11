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
            result += element.summarize()
        }
        
        return result // return self.reduce("") { $0 + $1.cast(FunctionParameterSyntax.self).summarize() }
    }
}

extension FunctionParameterSyntax {
    func summarize() -> String {
        var result = ""
        
        let externalName = self.firstName.text
        if let localName = self.secondName?.text {
            result += "- \(externalName) (\(localName)): "
        } else if let localName = self.secondName?.text {
            result += "- \(localName): "
        }
        
        result += "\(self.type.description)"
                
        // TODO: Handle variadic arguments.
        
        if let defaultArg = self.defaultValue {
            result += " (Default: \(defaultArg.description))"
        }
        
        result += "\n"
        
        return result
    }
}
