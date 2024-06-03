//
//  FunctionVisitorBasicTests.swift
//
//
//  Created by Matthew Turk on 1/26/24.
//

import Foundation
import SwiftSyntax
import SwiftParser
import XCTest
@testable import swiftdecl

class FunctionVisitorBasicTests: XCTestCase {
    func testSimpleFunctionParsing() {
        let visitor = FunctionVisitor(viewMode: .fixedUp)
        let syntaxTree = Parser.parse(source: "func foo(n: Int) -> Int")
        visitor.walk(syntaxTree)
        XCTAssertNotNil(visitor.functionDecl)
        guard let functionDecl = visitor.functionDecl else { return }
        
        let rendered = ParsedSummary {
            NounPhrase(functionDecl.signature.parameterClause)
        }.render()
        
        XCTAssertFalse(rendered.isEmpty)
    }
}
