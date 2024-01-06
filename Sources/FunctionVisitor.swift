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
            // @available: Indicates the platform and version on which the declaration is available.
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
            // Will add a tooltip (the data structure is yet to be updated).
            // These tokens will be mapped to pre-written, one-line explanations of what the attribute means.
            // summarizers[functionDecl, default: FunctionSummarizer()].tooltips.append(tooltip)
            break
        }
        
        return .visitChildren
    }

    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        let ellipsisToken = node.tokens(viewMode: .fixedUp).first { $0.tokenKind == .ellipsis }
        let inoutToken = node.tokens(viewMode: .fixedUp).first { $0.tokenKind == .inoutKeyword }
        guard let firstName = node.firstName, let type = node.type, let functionDecl else { return .visitChildren }
        var parameterDescription = ""
        var typeDescription = type.description

        if let ellipsisToken {
            // Parameter is variadic.
            parameterDescription += "an indefinite number of "
            typeDescription = String(typeDescription.dropLast(ellipsisToken.text.count))
        } else if let inoutToken {
            parameterDescription += "a non-constant "
            typeDescription = String(typeDescription.dropFirst(inoutToken.text.count))
        }
        parameterDescription += "`\(firstName.text.trimmingCharacters(in: .whitespacesAndNewlines))` of type `\(typeDescription.trimmingCharacters(in: .whitespacesAndNewlines))`"
        if let defaultArgument = node.defaultArgument {
            parameterDescription += " with default value of `\(defaultArgument.value)`"
        }
        
        summarizers[functionDecl, default: FunctionSummarizer()].parameterDescriptions.append(parameterDescription)
        
        return .visitChildren
    }
    
    override func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        guard let functionDecl else { return .visitChildren }
        
        if let inheritedType = node.inheritedType {
            summarizers[functionDecl, default: FunctionSummarizer()].genericRequirementDescriptions.append("`\(node.name.text)` conforms to `\(inheritedType)`")
        } else {
            summarizers[functionDecl, default: FunctionSummarizer()].genericRequirementDescriptions.append("`\(node.name.text)` can be any type")
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
}
