//
//  FunctionVisitorBasicTests.swift
//
//
//  Created by Matthew Turk on 1/26/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser
import XCTest
@testable import swiftdecl

class FunctionVisitorBasicTests: XCTestCase {
    func testSimpleFunctionParsing() {
        let source = """
                     func simpleFunction() {
                     }
                     """
        let functionVisitor = FunctionVisitor()
        let parsedSyntax = try! SyntaxParser.parse(source: source)
        functionVisitor.walk(parsedSyntax)
        
        // Check if the `functionVisitor` correctly identified the function.
        XCTAssertNotNil(functionVisitor.functionDecl, "Function declaration was not identified")
        XCTAssertEqual(functionVisitor.identifier?.text, "simpleFunction", "Function name does not match")
    }
    
    func testFunctionWithReturnTypeParsing() {
        let source = """
                     func functionWithReturnType() -> Int {
                         return 0
                     }
                     """
        let functionVisitor = FunctionVisitor(viewMode: .fixedUp)
        let parsedSyntax = try! SyntaxParser.parse(source: source)
        functionVisitor.walk(parsedSyntax)
        
        XCTAssertNotNil(functionVisitor.returnType, "Return type was not identified")
        XCTAssertEqual(functionVisitor.returnType?.description.trimmingCharacters(in: .whitespacesAndNewlines), "Int", "Return type does not match")
    }

    func testFunctionWithAttributes() {
        let source = """
                     @discardableResult
                     func functionWithAttributes() -> Int {
                         return 0
                     }
                     """
        let functionVisitor = FunctionVisitor(viewMode: .fixedUp)
        let parsedSyntax = try! SyntaxParser.parse(source: source)
        functionVisitor.walk(parsedSyntax)
        
        XCTAssertNotNil(functionVisitor.attributes, "Attributes were not identified")
    }
    
    func testSmallSourceParsingPerformance() {
        let source = """
        @available(macOS 13.0, *) public func foo<T: Numeric>(name: T, values: Int..., age: Int = 30) async throws -> String?

        func authenticateUser(method: (String) throws -> Bool) rethrows

        func tableView(
            _ tableView: UITableView,
            cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell

        func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry

        func reduce<T>(
            _ initialResult: T,
            _ nextPartialResult: @escaping (T, Self.Output) -> T
        ) -> Publishers.Reduce<Self, T>

        private func getAs<T: AnyObject>(_ objectType: T.Type) -> T?

        func foo<T: Codable, R: Codable>(_ bar: inout [T]) -> R
        """

        measure {
            /*let parsedSyntax = try! SyntaxParser.parse(source: """
                     @discardableResult
                     func functionWithAttributes() -> Int {
                         return 0
                     }
                     """)
            let functionVisitor = FunctionVisitor(viewMode: .fixedUp)
            functionVisitor.walk(parsedSyntax)
            // Optionally, measure summarization performance as well
            _ = functionVisitor.summarize()*/
            SwiftDecl.main([source])
        }
    }
}
