//
//  ParameterVisitor.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

class ParameterVisitor: SyntaxVisitor {
    var externalName: TokenSyntax?
    var localName: TokenSyntax?
    var typeAnnotation: TypeSyntax?
    var defaultArgument: InitializerClauseSyntax?
    
    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        self.externalName = node.firstName
        self.localName = node.secondName ?? node.firstName
        self.typeAnnotation = node.type
        self.defaultArgument = node.defaultArgument
        return .skipChildren
    }
}
