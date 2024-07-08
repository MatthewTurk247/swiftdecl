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
                InputPhrase(functionDecl.signature.parameterClause)
                Disjunction {
                    if let returnClause = functionDecl.signature.returnClause {
                        OutputPhrase(returnClause)
                    } else {
                        // Executes the function body and does not return anything.
                        "returns no output"
                    }
                    
                    if let throwsSpecifier = functionDecl.signature.effectSpecifiers?.throwsSpecifier {
                        // ErrorPhrase(throwsSpecifier)
                    }
                }
                // if generics, RelativePhrase here
                if let genericParameterClause = functionDecl.genericParameterClause,
                   let genericWhereClause = functionDecl.genericWhereClause {
                    
                } else if let genericParameterClause = functionDecl.genericParameterClause {
                    
                }
                
                // or maybe RelativePhrase has initializer with genericParameterClause and optional genericWhereClause
            }
        }.render()
        print(summary)
        
        XCTAssertFalse(summary.isEmpty)
    }
}

// Conjunction(functionDecl.signature.parameterClause)

