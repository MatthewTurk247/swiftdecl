//
//  FunctionVisitor.swift
//  swiftdecl
//
//  Created by Matthew Turk on 10/2/23.
//

import Foundation
import SwiftSyntax

class FunctionVisitor: SyntaxVisitor {
    // Attributes (optional): Attributes/property wrappers provide more information about the function's behavior or intended use, e.g., @discardableResult.
    var attributes: AttributeListSyntax?

    // Modifiers (optional): These adjust the function's behavior or accessibility, e.g., public, private, static, etc.
    var modifiers: ModifierListSyntax?
    
    var funcKeyword: TokenSyntax?
    
    // Function Name: This is the name by which you will call the function. It should be descriptive of what the function does.
    var identifier: TokenSyntax?
    
    // Generic Parameters (optional): Enclosed in angle brackets < >, these allow you to make functions that work with any type.
    var genericParameterClause: GenericParameterClauseSyntax?
    var genericWhereClause: GenericWhereClauseSyntax?
    
    /*
     Parameter List: Enclosed in parentheses (), this is a comma-separated list of zero or more parameters. Each parameter has a:

    Name (optional): For external use when calling the function.
    Local Name (used within the function body).
    Type: The data type of the parameter.
    Default Value (optional): You can provide a default value for a parameter.
    Variadic Parameter (optional): A parameter that accepts multiple values, denoted by ... after its type.
     */
    var parameterList: FunctionParameterListSyntax?
    var asyncOrReasyncKeyword: TokenSyntax?
    // Throwing Indicator (optional): If the function can throw an error, you use the throws keyword before the return arrow.
    var throwsOrRethrowsKeyword: TokenSyntax?
    // Return Type: If a function returns a value, you specify the type of the value after the return arrow.
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
   
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        // Is there a way to verify that this is a valid declaration before running all the way to completion?
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
}
