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
        let syntaxTree = Parser.parse(source: "static func buildLimitedAvailability<W, C1, C2>(_ component: some RegexComponent) -> Regex<(Substring, C1?, C2?)>")
        visitor.walk(syntaxTree)
        XCTAssertNotNil(visitor.functionDecl)
        guard let functionDecl = visitor.functionDecl else { return }
        
        let summary = ParsedSummary {
            "function"
            functionDecl.name.text.backticked
            Conjunction {
                InputPhrase(functionDecl.signature.parameterClause.parameters) { parameter in
                    parameter.type.naturalLanguageDescription(includeChildren: false, preferredName: parameter.firstName.text)
                }
                Disjunction {
                    if let returnClause = functionDecl.signature.returnClause {
                        OutputPhrase(returnClause)
                    } else {
                        // Executes the function body and does not return anything.
                        "returns no output"
                    }
                    
                    if let throwsSpecifier = functionDecl.signature.effectSpecifiers?.throwsSpecifier {
                        switch throwsSpecifier.tokenKind {
                        case .keyword(.rethrows):
                            "throws an error if its input closure throws an error"
                        default:
                            "throws an error"
                        }
                    }
                    ErrorPhrase(description: "") {
                        "smth"
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

