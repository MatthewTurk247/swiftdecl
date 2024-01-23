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
    var tooltips: [Tooltip] = []
    
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

extension SyntaxProtocol {
    
//    private func naturalLanguageWrite<Target: TextOutputStream>(to target: inout Target, indentLevel: Int) {
//            if let simpleType = Syntax(self).as(SimpleTypeIdentifierSyntax.self) {
//                // Base case: SimpleTypeIdentifierSyntax
//                target.write("Type: \(simpleType.name.text)")
//            } else {
//                // Constructing sentence for other syntax types
//                let typeName = self.description
//                target.write("This is a \(typeName) which contains: ")
//                
//                let allChildren = children(viewMode: .all)
//                if !allChildren.isEmpty {
//                    for (num, child) in allChildren.enumerated() {
//                        if num > 0 { target.write(", ") }
//                        child.naturalLanguageWrite(to: &target, indentLevel: indentLevel + 1)
//                    }
//                } else {
//                    target.write("no significant elements")
//                }
//            }
//
//            // Handle indentation and new lines for readability
//            if indentLevel > 0 {
//                target.write("\n")
//                target.write(String(repeating: " ", count: indentLevel * 2))
//            }
//        }
    // self.debugDescription
    
    /*var tooltip: Tooltip {
        // ...
    }*/
}

extension TypeSyntax {
    var naturalLanguageDescription: String {
        // SimpleTypeIdentifierSyntax(self)
        //https://swiftpackageindex.com/apple/swift-syntax/508.0.1/documentation/swiftsyntax/typesyntax
        switch self.kind {
        case .simpleTypeIdentifier:
            self.description
        case .arrayType:
            guard let arrayTypeSyntax = ArrayTypeSyntax(self) else { break }
            arrayTypeSyntax.recursiveDescription
            return "array of \(arrayTypeSyntax.elementType.naturalLanguageDescription)"
        case .dictionaryType:
            guard let dictionaryTypeSyntax = DictionaryTypeSyntax(self) else { break }
            return "dictionary mapping \(dictionaryTypeSyntax.keyType.naturalLanguageDescription) to \(dictionaryTypeSyntax.valueType.naturalLanguageDescription)"
        case .tupleType:
            guard let tupleTypeSyntax = TupleTypeSyntax(self) else { break }
            return "tuple of \(tupleTypeSyntax.elements.map { $0.type.naturalLanguageDescription }.itemized())"
        case .optionalType:
            guard let optionalTypeSyntax = OptionalTypeSyntax(self) else { break }
            return "\(optionalTypeSyntax.wrappedType.naturalLanguageDescription) or nil"
        case .functionType:
            guard let functionTypeSyntax = FunctionTypeSyntax(self) else { break }
            return "function mapping \(functionTypeSyntax.arguments.map { $0.type.naturalLanguageDescription }) to \(functionTypeSyntax.returnType.naturalLanguageDescription)"
        case .attributedType:
            guard let attributedTypeSyntax = AttributedTypeSyntax(self) else { break }
            return "\(attributedTypeSyntax.attributes.map { $0.description })"
        default:
            return self.description
        }
        
        return self.description
    }
}

/*extension ArrayTypeSyntax {
    var naturalLanguageDescription: String {
        "array of \(self.elementType.na)"
    }
}*/

class TypeVisitor: SyntaxVisitor {
    override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    override func visit(_ node: DictionaryTypeSyntax) -> SyntaxVisitorContinueKind {
        print("dictionary mapping \(node.keyType) to \(node.valueType)")
        return .visitChildren
    }
}
