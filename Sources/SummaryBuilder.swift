//
//  SummaryBuilder.swift
//
//
//  Created by Matthew Turk on 5/26/24.
//

import Foundation
import SwiftSyntax

protocol SummaryProtocol { //CustomStringConvertible {
    var tooltips: [Tooltip]  { get }
    func render() -> String
}

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

struct ParsedSummary: SummaryProtocol {
    var tooltips: [Tooltip] = []
    @TextSegmentBuilder
    var content: () -> [any SummaryProtocol]
    
    func render() -> String {
        content().map { $0.render() }.joined(separator: " ")
    }
}

struct NounPhrase: SummaryProtocol {
    var tooltips: [Tooltip] = []
    var node: FunctionParameterClauseSyntax
    
    init(_ node: FunctionParameterClauseSyntax) {
        self.node = node
    }
    
    func render() -> String {
        node.parameters.itemized()
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

extension String: SummaryProtocol {
    func render() -> String {
        self
    }
    
    var tooltips: [Tooltip] {
        []
    }
}

// FunctionDeclSyntax.Summary

