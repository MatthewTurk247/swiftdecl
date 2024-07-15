//
//  TextSegmentBuilder.swift
//
//
//  Created by Matthew Turk on 5/26/24.
//

import Foundation
import SwiftSyntax

@resultBuilder
struct TextSegmentBuilder {
    static func buildBlock(_ components: [any SummaryProtocol]...) -> [any SummaryProtocol] {
        components.flatMap { $0 }
    }
    
    static func buildExpression(_ expression: any SummaryProtocol) -> [any SummaryProtocol] {
        [expression]
    }
    
    static func buildOptional(_ component: [any SummaryProtocol]?) -> [any SummaryProtocol] {
        component ?? []
    }
    
    static func buildEither(first component: [any SummaryProtocol]) -> [any SummaryProtocol] {
        component
    }
    
    static func buildEither(second component: [any SummaryProtocol]) -> [any SummaryProtocol] {
        component
    }
}

extension TokenSyntax: SummaryProtocol {
    func render() -> String {
        self.text
    }
    
    var tooltips: [Tooltip] {
        []
    }
}

extension TokenSyntax {
    struct Summary: SummaryProtocol {
        var description: String = "smth"
        var tooltips: [Tooltip] = []
        
        @TextSegmentBuilder
        var content: () -> [any SummaryProtocol]
        
        func render() -> String {
            content().map { $0.render() }.joined(separator: " ")
        }
        
        static subscript(_ content: any SummaryProtocol) -> String {
            ""
        }
    }
}

struct ErrorPhrase: SummaryProtocol, CustomStringConvertible {
    var tooltips: [Tooltip] = []
    
    func render() -> String {
        ""
    }
    
    var description: String
    
    @TextSegmentBuilder
    var content: () -> [any SummaryProtocol]
    
    init(description: String, @TextSegmentBuilder content: @escaping () -> [any SummaryProtocol]) {
        self.description = description
        self.content = content
    }
}

struct VerbPhrase: SummaryProtocol, CustomStringConvertible {
    var tooltips: [Tooltip] = []
    var description: String
    
    init(_ node: FunctionSignatureSyntax) {
        self.description = "takes input"
        
        if node.parameterClause.parameters.count != 1 {
            self.description += "s"
        }
    }
    
    func render() -> String {
        description
    }
}

// FunctionDeclSyntax.Summary

