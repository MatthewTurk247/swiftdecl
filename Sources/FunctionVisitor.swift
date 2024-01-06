//
//  FunctionVisitor.swift
//  swiftdecl
//
//  Created by Matthew Turk on 10/2/23.
//

import Foundation
import SwiftSyntax

class FunctionVisitor: SyntaxVisitor {
    /// Attributes (optional): Attributes/property wrappers provide more information about the function's behavior or intended use, e.g., @discardableResult.
    var attributes: AttributeListSyntax?

    /// Modifiers (optional): These adjust the function's behavior or accessibility (e.g., `public`, `private`, `static`).
    var modifiers: ModifierListSyntax?
    
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
    var parameterList: FunctionParameterListSyntax? // ditto
    var asyncOrReasyncKeyword: TokenSyntax?
    /// If the function can throw an error, you use the `throws` keyword before the return arrow to indicate that.
    var throwsOrRethrowsKeyword: TokenSyntax?
    /// If a function returns a value, you specify the type of the value after the return arrow.
    var returnType: TypeSyntax?
    
    var functionDecl: FunctionDeclSyntax?
    /*
     Function Keyword: Every function declaration starts with the func keyword.
     Return Arrow (optional): -> This symbol indicates that the function returns a value.

     Function Body: Enclosed in braces {}, this is where you write the series of statements that constitute the function's behavior.

     Access modifier
     func keyword
     Name
     Generic types
     Parameters
     Throwing specifier
     Return type
     Body
     Async specifier
     */
    private var summarizers: [FunctionDeclSyntax: FunctionSummarizer] = [:]
    var attributeDescriptions: [String] = []
    var genericRequirementDescriptions: [String] = []
    var parameterDescriptions: [String] = []
    // var reverseIndex: [String: Syntax] = [:]
    
    // https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/
    static let mainAttribute: String = "Indicates the top-level entry point for program flow"
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        // https://swiftpackageindex.com/apple/swift-syntax/509.0.2/documentation/swiftsyntax/attributesyntax
        self.functionDecl = node
        self.attributes = node.attributes
        self.modifiers = node.modifiers
        self.funcKeyword = node.funcKeyword
        self.identifier = node.identifier
        
        self.genericParameterClause = node.genericParameterClause
        self.genericWhereClause = node.genericWhereClause
        self.parameterList = node.signature.input.parameterList
        self.asyncOrReasyncKeyword = node.signature.asyncOrReasyncKeyword
        self.throwsOrRethrowsKeyword = node.signature.throwsOrRethrowsKeyword
        self.returnType = node.signature.output?.returnType

        return .visitChildren
    }
    
    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        guard node.parent?.parent?.kind == .functionDecl else { return .skipChildren }
        guard let functionDecl else { return .visitChildren }
        
        switch node.argument {
        case .token(let tokenSyntax):
            break
        case .stringExpr(let stringLiteralExprSyntax):
            break
        case .availability(let availabilitySpecListSyntax):
            // Is it possible to have multiple versions in this syntax?
            guard let spec = availabilitySpecListSyntax
                .first(where: { $0.entry.kind == .availabilityVersionRestriction }) else { break }
            summarizers[functionDecl, default: FunctionSummarizer()].attributeDescriptions.append("available on \(spec.entry.description)")
        case .specializeArguments(let specializeAttributeSpecListSyntax):
            break
        case .objCName(let objCSelectorSyntax):
            summarizers[functionDecl, default: FunctionSummarizer()].attributeDescriptions.append("exposed to Objective-C")
        case .implementsArguments(let implementsAttributeArgumentsSyntax):
            break
        case .differentiableArguments(let differentiableAttributeArgumentsSyntax):
            break
        case .derivativeRegistrationArguments(let derivativeRegistrationAttributeArgumentsSyntax):
            break
        case .namedAttributeString(let namedAttributeStringArgumentSyntax):
            break
        case .backDeployedArguments(let backDeployedAttributeSpecListSyntax):
            break
        case .conventionArguments(let conventionAttributeArgumentsSyntax):
            break
        case .conventionWitnessMethodArguments(let conventionWitnessMethodAttributeArgumentsSyntax):
            break
        case .opaqueReturnTypeOfAttributeArguments(let opaqueReturnTypeOfAttributeArgumentsSyntax):
            break
        case .tokenList(let tokenListSyntax):
            break
        case .none:
            break
        }
        
        return .visitChildren
    }
    
   /* override func visit(_ node: AvailabilityArgumentSyntax) -> SyntaxVisitorContinueKind {
        switch node.entry {
        case .availabilityVersionRestriction(let availabilityVersionRestrictionSyntax):
            var availabilityDescription = "available on \(availabilityVersionRestrictionSyntax.platform.text)"
            if let version = availabilityVersionRestrictionSyntax.version {
                availabilityDescription += " " + version.majorMinor.text
            }
        case .availabilityLabeledArgument(let availabilityLabeledArgumentSyntax):
            switch availabilityLabeledArgumentSyntax.value {
            case .string(let tokenSyntax):
                print(tokenSyntax.text)
            case .version(let versionTupleSyntax):
                print("available on \(versionTupleSyntax.majorMinor.text)")
            }
            print("(" + availabilityLabeledArgumentSyntax.value.description.trimmingCharacters(in: CharacterSet.init(charactersIn: "\"")) + ")")
        default:
            break
        }
                
        return .visitChildren
    }*/

    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        let isVariadic = node.tokens(viewMode: .fixedUp).contains { $0.tokenKind == .ellipsis }
        let isInOut = node.tokens(viewMode: .fixedUp).contains { $0.tokenKind == .inoutKeyword }
        
        if let firstName = node.firstName, let type = node.type {
            var parameterDescription = ""
            var typeDescription = type.description

            if isVariadic {
                parameterDescription += "an indefinite number of "
                typeDescription = String(typeDescription.dropLast(3))
            } else if isInOut {
                parameterDescription += "a non-constant "
                typeDescription = String(typeDescription.dropFirst(5))
            }
            parameterDescription += "`\(firstName.text.trimmingCharacters(in: .whitespacesAndNewlines))` of type `\(typeDescription.trimmingCharacters(in: .whitespacesAndNewlines))`"
            if let defaultArgument = node.defaultArgument {
                parameterDescription += " with default value of `\(defaultArgument.value)`"
            }
            
            if let functionDecl = self.functionDecl {
                summarizers[functionDecl, default: FunctionSummarizer()].parameterDescriptions.append(parameterDescription)
            }
        }
        
        return .visitChildren
    }
    
    override func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        if let functionDecl = self.functionDecl {
            if let inheritedType = node.inheritedType {
                summarizers[functionDecl, default: FunctionSummarizer()].genericRequirementDescriptions.append("`\(node.name.text)` conforms to `\(inheritedType)`")
            } else {
                summarizers[functionDecl, default: FunctionSummarizer()].genericRequirementDescriptions.append("`\(node.name.text)` can be any type")
            }
        }
        
        return .visitChildren
    }
    
    func summarize() -> String {
        var batches: [String] = []
        
        for (node, summarizer) in summarizers {
            var batch = summarizer.summarize(node)
            batch = String(batch.trimmingCharacters(in: CharacterSet(charactersIn: ",").union(.whitespacesAndNewlines)))
            batch += "."
            batches.append(batch.isEmpty ? batch : (batch.prefix(1).capitalized + batch.dropFirst()))
        }

        return batches.joined(separator: "\n\n")
    }
    
        /*
         example:
         A function named foo, available on macOS 13.0 and later, takes a string parameter named name, a variable number of integer values, and an optional integer parameter named age with a default value of 30, and returns a string.
         */
        
    // public func getAs<T: AnyObject>(_ objectType: T.Type) -> T?
    /*
     The public function named `getAs` takes a type parameter `T` that must be a class type. It takes one argument, which is the type of `T`, has no external name, and has an internal name of `objectType`. The function returns either an instance of type `T` or `nil`.
     */
    
    func explain() -> String {
        var result = "Given "
        let inputVerbiage = parameterList?.summarize() ?? "no external inputs"
        result += inputVerbiage
        
        if let returnTypeDescription = returnType?.description {
            result += "return \(returnTypeDescription)"
        } else {
            result += "execute the function body and return no value"
        }
        
        return "" // not implemented yet, could also return an explanation object or smth
    }
}
