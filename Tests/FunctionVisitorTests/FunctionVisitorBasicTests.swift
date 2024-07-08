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
        
        let summary = ParsedSummary {
            "function"
            functionDecl.name.text.backticked
            Conjunction {
                VerbPhrase(description: "takes") {
                        functionDecl.signature.parameterClause.parameters.count == 1 ? "input" : "inputs"
                        NounPhrase(functionDecl.signature.parameterClause)
                }
                Disjunction {
                    VerbPhrase(description: "returns") {
                        ""
                    }
                    VerbPhrase(description: "throws") {
                        ""
                    }
                }
                // if generics, RelativePhrase here
            }
        }.render()
        print(summary)
        
        XCTAssertFalse(summary.isEmpty)
    }
}

// Conjunction(functionDecl.signature.parameterClause)

