//
//  FunctionSummarizer.swift
//
//
//  Created by Matthew Turk on 1/5/24.
//

import Foundation
import SwiftSyntax

struct FunctionSummarizer {
    var attributeDescriptions: [String] = []
    var parameterDescriptions: [String] = []
    var genericRequirementDescriptions: [String] = []
    var footnotes: [Footnote] = []
    // var node: FunctionDeclSyntax
    // and then this will be initializer
    
    func summarize(_ node: FunctionDeclSyntax) -> String {
        var batch = ""

        if node.signature.asyncOrReasyncKeyword != nil {
            batch += "asynchronous "
        }

        if let modifiers = node.modifiers {
            batch += modifiers.map { $0.description }.joined(separator: " ")
        }

        // Add function name
        batch += "function named `\(node.identifier.text)`"

        if self.parameterDescriptions.isEmpty {
            batch += " takes no inputs"
        } else {
            batch += " takes input"
            if self.parameterDescriptions.count > 1 {
                batch += "s"
            }
            
            batch += " \(self.parameterDescriptions.itemized())"
        }
        
        if let output = node.signature.output {
            batch += " and returns output of "
            if output.returnType.kind == .optionalType {
                batch += "`\(output.returnType.description.dropLast())` or `nil`"
            } else {
                batch += "`\(output.returnType)`"
            }
            // batch += "`\(output.returnType.recursiveNaturalLanguageDescription)`"
        } else {
            // Executes the function body and does not return anything.
            batch += " and returns no output"
        }
        
        // Add generic requirements
        if !self.genericRequirementDescriptions.isEmpty {
            batch += ", where \(self.genericRequirementDescriptions.itemized()),"
        }
        
        if let throwsKeyword = node.signature.throwsOrRethrowsKeyword {
            switch throwsKeyword.tokenKind {
            case .throwsKeyword:
                batch += " or throws an error"
            case .rethrowsKeyword:
                batch += " or throws an error if its input function throws an error"
            default:
                break
            }
        }
        
        // in the future, in addition to collecting tooltips for attributes and interesting keywords, collect tooltips for complicated parameter types like @escaping closures, generics inside generics, etc.
        if !attributeDescriptions.isEmpty {
            batch += ". It is \(attributeDescriptions.joined(separator: ", "))"
        }
        
        return batch
    }
}
