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
    
    // https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/
    static let mainAttribute: String = "Indicates the top-level entry point for program flow"
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
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

    override func visit(_ node: AvailabilityArgumentSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    override func visit(_ node: InOutExprSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
        
    override func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    func summarize() -> String {
        var result = "A function named \(self.identifier?.text ?? "")"
        
        // "with inputs ..."
        
        if let attributes {
            for token in attributes.tokens(viewMode: .fixedUp) {
                switch token.tokenKind {
                case .identifier(let platform):
                    result += ", available on \(platform)"
                case .integerLiteral(let version), .floatingLiteral(let version):
                    result += version
                // Handle other argument types as needed.
                default:
                    break
                
            }
            result += ", "
        }
        
        /*
         example:
         A function named foo, available on macOS 13.0 and later, takes a string parameter named name, a variable number of integer values, and an optional integer parameter named age with a default value of 30, and returns a string.
         */
        
        if let returnTypeDescription = returnType?.description {
            result += "that returns \(returnTypeDescription)"
        } else {
            result += "that executes the function body and return no value"
        }
        
        return result
    }
    
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
