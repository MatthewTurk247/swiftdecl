//
//  GenericWhereVisitor.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

class GenericWhereVisitor: SyntaxVisitor {
    var requirementList: GenericRequirementListSyntax?
    
    override func visit(_ node: GenericWhereClauseSyntax) -> SyntaxVisitorContinueKind {
        self.requirementList = node.requirementList
        return .visitChildren
    }
}
