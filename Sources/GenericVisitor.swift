//
//  GenericVisitor.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

class GenericVisitor: SyntaxVisitor {
    var genericParameters: GenericParameterListSyntax?
    
    override func visit(_ node: GenericParameterClauseSyntax) -> SyntaxVisitorContinueKind {
        self.genericParameters = node.genericParameterList
        return .visitChildren
    }
}
