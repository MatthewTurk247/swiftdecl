//
//  AttributeVisitor.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

class AttributeVisitor: SyntaxVisitor {
    var attributeName: TokenSyntax?
    var argument: AttributeSyntax.Argument?

    // https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/
    static let mainAttribute: String = "Indicates the top-level entry point for program flow"
    
    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        self.attributeName = node.attributeName
        self.argument = node.argument
        return .skipChildren
    }
}
