//
//  SummaryComposer.swift
//
//
//  Created by Matthew Turk on 3/20/24.
//

import Foundation
import SwiftSyntax

class SummaryComposer {
    /// Attributes (optional): Attributes/property wrappers provide more information about the function's behavior or intended use (e.g., `@discardableResult`).
    var attributes: AttributeListSyntax?

    /// Modifiers (optional): These adjust the function's behavior or accessibility (e.g., `public`, `private`, `static`).
    var modifiers: DeclModifierListSyntax?
    
    /// Swift functions are declared using the `func` keyword.
    var funcKeyword: TokenSyntax?
    
    /// The name by which you will call the function. It should be descriptive of what the function does.
    var identifier: TokenSyntax?
    
    /// Enclosed in angle brackets `< >`, these allow you to make functions that work with any type.
    var genericParameterClause: GenericParameterClauseSyntax?
    var genericWhereClause: GenericWhereClauseSyntax?
    
    /// Enclosed in parentheses `()`, this is a comma-separated list of zero or more parameters.
    ///
    /// Each parameter may have any of the following properties:
    /// - Name (optional) for external use when calling the function.
    /// - Local name, used within the function body.
    /// - Data type.
    /// - Default value (optional).
    /// - Variadic parameter (optional), which accepts multiple values, denoted by `...` after its type.
    var parameterList: FunctionParameterClauseSyntax? // ditto
    var asyncOrReasyncKeyword: TokenSyntax?
    /// If the function can throw an error, you use the `throws` keyword before the return arrow to specify/indicate that.
    var throwsOrRethrowsKeyword: TokenSyntax?
    /// If a function returns a value, you specify the type of the value after the return arrow.
    var returnType: TypeSyntax?
    
    var textSegments: [String] = []
    
    init(_ node: FunctionDeclSyntax) {
        self.attributes = node.attributes
        self.modifiers = node.modifiers
        self.funcKeyword = node.funcKeyword
        self.identifier = node.name
        
        self.genericParameterClause = node.genericParameterClause
        self.genericWhereClause = node.genericWhereClause
        self.parameterList = node.signature.parameterClause
        self.asyncOrReasyncKeyword = node.signature.effectSpecifiers?.asyncSpecifier
        self.throwsOrRethrowsKeyword = node.signature.effectSpecifiers?.throwsSpecifier
        self.returnType = node.signature.returnClause?.type
        // node.genericParameterClause?.genericParameterList.first?.inheritedType
    }
    
    /*func compose() -> Summary {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key("data-tooltip-target"): "syntax node id here or smth"
        ]
        // annotatedText: NSAttributedString(string: "")
        // https://forums.developer.apple.com/forums/thread/682431
        
        return Summary(text: "", tooltips: [])
    }*/
    
    func compose() -> Summary {
        var text = ""
        var html = ""
        
        if self.asyncOrReasyncKeyword != nil {
            textSegments.append("asynchronous")
        }
        
        if let modifiers {
            textSegments.append(contentsOf: modifiers.compactMap { $0.detail?.detail.text })
        }
        
        textSegments.append("function")
        
        if let parameterList {
            if parameterList.parameters.isEmpty {
                textSegments.append("takes no inputs")
            } else {
                textSegments.append(contentsOf: parameterList.parameters.compactMap { $0.phrase })
            }
        }
        
        if let genericWhereRequirements = genericWhereClause?.requirements {
            
        }
        
        if let genericParameterList = genericParameterClause?.parameters {
            genericParameterList.first
            
        }
        
        if let genericParameterClause {
            var conformances: [TokenSyntax: TypeSyntax?] = [:]
            var requirements: [TokenSyntax: GenericRequirementSyntax.Requirement?] = [:]
            
            for generic in genericParameterClause.parameters {
                conformances[generic.name] = generic.inheritedType
                generic
            }
            
//            if let requirementList = genericParameterClause.genericWhereClause?.requirementList {
//                for element in requirementList {
//                    element.requirement
//                }
//            }
//            
//            genericParameterClause.genericParameterList.first?.inheritedType
//            genericParameterClause.genericWhereClause?.requirementList.first
        }
        
        if let requirementList = genericParameterClause?.genericWhereClause?.requirements {
            
        }
                
        if let throwsOrRethrowsKeyword {
            switch throwsOrRethrowsKeyword.tokenKind {
            case .keyword(.throws):
                textSegments.append("throws an error")
            case .keyword(.rethrows):
                textSegments.append("throws an error if its input closure throws an error")
            default:
                break
            }
        }
        
        if let attributes {
            for attribute in attributes {
                switch attribute {
                case .attribute(let attributeSyntax):
                    self.phrase(attributeSyntax)
                case .ifConfigDecl(let ifConfigDeclSyntax):
                    break
                }
            }
        }
        
        return Summary(text: text, tooltips: [])
    }
    
    var mainClause: String {
        var result = ""
        if self.asyncOrReasyncKeyword != nil {
            result += "asynchronous"
        }
        
        return result
    }
    
    func phrase(_ node: AttributeSyntax) {
        // can also add tooltips at relevant points
        switch node.arguments {
        case .argumentList(let labeledExprListSyntax):
            break
        case .availability(let availabilitySpecListSyntax):
            // add sentence to description
            break
        case .backDeployedArguments(let backDeployedAttributeSpecListSyntax):
            break
        case .conventionArguments(let conventionAttributeArgumentsSyntax):
            break
        case .conventionWitnessMethodArguments(let conventionWitnessMethodAttributeArgumentsSyntax):
            break
        case .derivativeRegistrationArguments(let derivativeRegistrationAttributeArgumentsSyntax):
            break
        case .differentiableArguments(let differentiableAttributeArgumentsSyntax):
            break
        case .implementsArguments(let implementsAttributeArgumentsSyntax):
            break
        case .documentationArguments(let documentationAttributeArgumentListSyntax):
            break
        case .dynamicReplacementArguments(let dynamicReplacementAttributeArgumentsSyntax):
            break
        case .effectsArguments(let effectsAttributeArgumentListSyntax):
            break
        case .exposeAttributeArguments(let exposeAttributeArgumentsSyntax):
            break
        case .implementsArguments(let implementsAttributeArgumentsSyntax):
            break
        case .objCName(let objCSelectorSyntax):
            break
        case .opaqueReturnTypeOfAttributeArguments(let opaqueReturnTypeOfAttributeArgumentsSyntax):
            break
        case .originallyDefinedInArguments(let originallyDefinedInAttributeArgumentsSyntax):
            break
        case .specializeArguments(let specializeAttributeSpecListSyntax):
            break
        case .string(let stringExprSyntax):
            break
        case .token(let tokenSyntax):
            break
        case .none:
            break
        case .some(.underscorePrivateAttributeArguments(_)):
            break
        case .some(.unavailableFromAsyncArguments(_)):
            break
        }
    }
}

extension AttributeSyntax {
    
}

extension IfConfigDeclSyntax {
    
}
