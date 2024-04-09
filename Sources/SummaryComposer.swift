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
    /// If the function can throw an error, you use the `throws` keyword before the return arrow to specify/indicate that.
    var throwsOrRethrowsKeyword: TokenSyntax?
    /// If a function returns a value, you specify the type of the value after the return arrow.
    var returnType: TypeSyntax?
    
    init(_ node: FunctionDeclSyntax) {
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
        // node.genericParameterClause?.genericParameterList.first?.inheritedType
    }
    
    func compose() -> Summary {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key("data-tooltip-target"): "syntax node id here or smth"
        ]
        // annotatedText: NSAttributedString(string: "")
        // https://forums.developer.apple.com/forums/thread/682431
        
        return Summary(text: "", tooltips: [])
    }
    
    var mainClause: String {
        var result = ""
        if self.asyncOrReasyncKeyword != nil {
            result += "asynchronous"
        }
        
        return result
    }
    
    var throwingDescription: String {
        //self.throwsOrRethrowsKeyword?.tokenKind == .throwsKeyword ? "throws an error" : "throws "
        switch self.throwsOrRethrowsKeyword?.tokenKind {
        case .throwsKeyword:
            "throws an error"
        case .rethrowsKeyword:
            "throws an error if its input closure throws an error"
        default:
            ""
        }
    }
}
