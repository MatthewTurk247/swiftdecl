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
        switch Syntax(self).as(SyntaxEnum.self) {
        case .simpleTypeIdentifier(let simpleTypeIdentifierSyntax):
            return simpleTypeIdentifierSyntax.name.text
        case .memberTypeIdentifier(let memberTypeIdentifierSyntax):
            break
        case .classRestrictionType(let classRestrictionTypeSyntax):
            return "class-constrained type"
        case .arrayType(let arrayTypeSyntax):
            return "array of \(arrayTypeSyntax.elementType.recursiveNaturalLanguageDescription)"
        case .dictionaryType(let dictionaryTypeSyntax):
            return "dictionary mapping \(dictionaryTypeSyntax.keyType.recursiveNaturalLanguageDescription) to \(dictionaryTypeSyntax.valueType.recursiveNaturalLanguageDescription)"
        case .metatypeType(let metatypeTypeSyntax):
            break
        case .optionalType(let optionalTypeSyntax):
            return "\(optionalTypeSyntax.wrappedType.recursiveNaturalLanguageDescription) or nil"
        case .constrainedSugarType(let constrainedSugarTypeSyntax):
            return "\(constrainedSugarTypeSyntax.someOrAnySpecifier.text) \(constrainedSugarTypeSyntax.baseType.recursiveNaturalLanguageDescription)"
        case .implicitlyUnwrappedOptionalType(let implicitlyUnwrappedOptionalTypeSyntax):
            break
        case .compositionType(let compositionTypeSyntax):
            break
        case .packExpansionType(let packExpansionTypeSyntax):
            return "variadic expansion of \(packExpansionTypeSyntax.patternType.recursiveNaturalLanguageDescription)"
        case .packReferenceType(let packReferenceTypeSyntax):
            return "reference to variadic pack \(packReferenceTypeSyntax.packType.recursiveNaturalLanguageDescription)"
        case .tupleType(let tupleTypeSyntax):
            return "\(tupleTypeSyntax.elements.count)-tuple of \(tupleTypeSyntax.elements.map { $0.type.recursiveNaturalLanguageDescription }.itemized())"
        case .functionType(let functionTypeSyntax):
            return "\(functionTypeSyntax.throwsOrRethrowsKeyword == nil ? "" : "throwing ")function that returns \(functionTypeSyntax.returnType.recursiveNaturalLanguageDescription)"
        case .attributedType(let attributedTypeSyntax):
            var attributedTypeDescription = attributedTypeSyntax.baseType.recursiveNaturalLanguageDescription
            if (attributedTypeSyntax.attributes?.first { $0.description.trimmingCharacters(in: .whitespacesAndNewlines) == "@escaping" }) != nil {
                attributedTypeDescription += " (escaping closure)"
            }
            
            return attributedTypeDescription
        case .namedOpaqueReturnType(let namedOpaqueReturnTypeSyntax):
            return "opaque \(namedOpaqueReturnTypeSyntax.baseType.recursiveNaturalLanguageDescription)"
        default:
            break
        }
        
        return self.description
    }
}
