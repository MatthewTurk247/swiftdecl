//
//  FunctionTranslator.swift
//
//
//  Created by Matthew Turk on 2/18/24.
//

import Foundation
import SwiftSyntax

struct FunctionTranslator {
    var footnotes: [Footnote]
    let node: FunctionDeclSyntax
    
    init(_ node: FunctionDeclSyntax, footnotes: [Footnote] = []) {
        self.footnotes = footnotes
        self.node = node
        print(self.node.signature.input.parameterList.compactMap { $0.phrase }.itemized())
    }
    
    var summary: String {
        var result = [
            node.signature.effectSpecifiers?.asyncSpecifier?.text != nil ? "asynchronous" : nil,
            node.modifiers.compactMap { $0.description }.joined(separator: " "),
            "function named",
            "`\(node.identifier.text)`",
        ]
        
        if node.signature.input.parameterList.isEmpty {
            result.append("takes no inputs")
        } else {
            let inputDescriptions = node.signature.input.parameterList.compactMap { $0.phrase }.itemized()
            result.append("takes input\(node.signature.input.parameterList.count > 1 ? "s" : "")")
            result.append(inputDescriptions)
        }
        
        // remember plural
        
        result.append("and returns output")
        result.append(node.signature.output?.returnType.recursiveNaturalLanguageDescription)
        
        return result.compactMap { $0 }.joined(separator: " ")
    }
}
