//
//  TypeSyntaxProtocol+String.swift
//
//
//  Created by Matthew Turk on 1/22/24.
//

import Foundation
import SwiftSyntax

// SyntaxProtocol or just TypeSyntaxProtocol?
// Could also do SyntaxProtocol and write specific natural language functions for all the kinds of nodes that could possibly be encountered in the function decl
// Some of that code is already written in other files and would just need to be brought here
// https://swiftpackageindex.com/apple/swift-syntax/508.0.1/documentation/swiftsyntax/typesyntax

extension TypeSyntaxProtocol {
    var recursiveNaturalLanguageDescription: String {
        // This computed property could have been implemented recursively, but the implementation would be almost identitcal to the function below.
        naturalLanguageDescription(includeChildren: true)
    }
    
    func naturalLanguageDescription(includeChildren: Bool, preferredName: String? = nil) -> String {
        // let functionParameter = Syntax(self.parent)?.as(FunctionParameterSyntax.self)
        
        switch Syntax(self).as(SyntaxEnum.self) {
        case .simpleTypeIdentifier(let simpleTypeIdentifierSyntax):
            return "`\(simpleTypeIdentifierSyntax.name.text)`"
        case .memberTypeIdentifier(let memberTypeIdentifierSyntax):
            return "`\(memberTypeIdentifierSyntax.description)`"
        case .classRestrictionType(let classRestrictionTypeSyntax):
            return "class-constrained type"
        case .arrayType(let arrayTypeSyntax):
            return "array of \(includeChildren ? arrayTypeSyntax.elementType.naturalLanguageDescription(includeChildren: true) : arrayTypeSyntax.elementType.description)"
        case .dictionaryType(let dictionaryTypeSyntax):
            return "dictionary mapping \(includeChildren ? dictionaryTypeSyntax.keyType.naturalLanguageDescription(includeChildren: true) : dictionaryTypeSyntax.keyType.description) to \(includeChildren ? dictionaryTypeSyntax.valueType.naturalLanguageDescription(includeChildren: true) : dictionaryTypeSyntax.valueType.description)"
        case .metatypeType(let metatypeTypeSyntax):
            return "`\(metatypeTypeSyntax.description)`"
        case .optionalType(let optionalTypeSyntax):
            return "\(includeChildren ? optionalTypeSyntax.wrappedType.naturalLanguageDescription(includeChildren: true) : optionalTypeSyntax.wrappedType.description) or nil"
        case .constrainedSugarType(let constrainedSugarTypeSyntax):
            return "\(constrainedSugarTypeSyntax.someOrAnySpecifier.text) \(includeChildren ? constrainedSugarTypeSyntax.baseType.naturalLanguageDescription(includeChildren: true) : constrainedSugarTypeSyntax.baseType.description)"
        case .implicitlyUnwrappedOptionalType(let implicitlyUnwrappedOptionalTypeSyntax):
            return "implicitly unwrapped optional of \(includeChildren ? implicitlyUnwrappedOptionalTypeSyntax.wrappedType.description : implicitlyUnwrappedOptionalTypeSyntax.wrappedType.naturalLanguageDescription(includeChildren: true))"
        case .compositionType(let compositionTypeSyntax):
            return includeChildren ? compositionTypeSyntax.description : "type composition"
        case .packExpansionType(let packExpansionTypeSyntax):
            var parametersName = "parameters"
            if let preferredName {
                parametersName = "`\(preferredName)`"
            }
            return "an indefinite number of \(parametersName) of type \(packExpansionTypeSyntax.patternType.naturalLanguageDescription(includeChildren: includeChildren))"
        case .packReferenceType(let packReferenceTypeSyntax):
            return "reference to variadic pack \(includeChildren ? packReferenceTypeSyntax.packType.naturalLanguageDescription(includeChildren: true) : packReferenceTypeSyntax.packType.description)"
        case .tupleType(let tupleTypeSyntax):
            return "\(tupleTypeSyntax.elements.count)-tuple of \(includeChildren ? tupleTypeSyntax.elements.map { $0.type.naturalLanguageDescription(includeChildren: true) }.itemized() : tupleTypeSyntax.elements.map { $0.type.description }.itemized())"
        case .functionType(let functionTypeSyntax):
            var functionDescription = ""
            
            // Describe the arity of the function specified in the node.
            switch functionTypeSyntax.arguments.count {
            case 0:
                functionDescription += "nullary"
            case 1:
                functionDescription += "unary"
            case 2:
                functionDescription += "binary"
            case 3:
                functionDescription += "ternary"
            default:
                functionDescription += "\(functionTypeSyntax.arguments.count)-ary"
            }

            functionDescription += " \(functionTypeSyntax.throwsOrRethrowsKeyword == nil ? "" : "throwing ")function that returns"
            
            return "\(functionDescription) \(includeChildren ? functionTypeSyntax.returnType.naturalLanguageDescription(includeChildren: true) : "`\(functionTypeSyntax.returnType.description)`")"
        case .attributedType(let attributedTypeSyntax):
            var attributedTypeDescription = includeChildren ? attributedTypeSyntax.baseType.naturalLanguageDescription(includeChildren: true) : "`\(attributedTypeSyntax.baseType.description)`"
            if (attributedTypeSyntax.attributes?.first { $0.description.trimmingCharacters(in: .whitespacesAndNewlines) == "@escaping" }) != nil {
                attributedTypeDescription += " escaping closure"
            }
            return attributedTypeDescription
        case .namedOpaqueReturnType(let namedOpaqueReturnTypeSyntax):
            return "opaque \(includeChildren ? namedOpaqueReturnTypeSyntax.baseType.naturalLanguageDescription(includeChildren: true) : namedOpaqueReturnTypeSyntax.baseType.description)"
        default:
            return self.description
        }
    }
}

extension FunctionParameterSyntax {
    var phrase: String? {
        self.type?.naturalLanguageDescription(includeChildren: false, preferredName: secondName?.text ?? firstName?.text)
    }
    
    var recursivePhrase: String? {
        self.type?.naturalLanguageDescription(includeChildren: true, preferredName: secondName?.text ?? firstName?.text)
    }
}
