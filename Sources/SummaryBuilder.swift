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
//    var node: FunctionParameterClauseSyntax
    var description: String
    
    init(_ node: FunctionParameterClauseSyntax) {
//        self.node = node
        self.description = "[placeholder]"
    }
    
    init(_ node: FunctionParameterListSyntax) {
        self.description = "takes input"
        
        if node.count > 1 {
            self.description += "s"
        }
    }
    
    init(_ node: ReturnClauseSyntax) {
        self.description = "returns"
    }
    
    func render() -> String {
//        node.parameters.itemized()
        description
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

struct Conjunction: SummaryProtocol {
    var tooltips: [Tooltip] = []
    
    @TextSegmentBuilder
    var content: () -> [any SummaryProtocol]
    
//    init(tooltips: [Tooltip] = [], content: @escaping () -> [any SummaryProtocol]) {
//        self.tooltips = tooltips
//        self.content = content
//    }
//    
    func render() -> String {
        content().map { $0.render() }.itemized()
    }
}

struct Disjunction: SummaryProtocol {
    var tooltips: [Tooltip] = []
    
    @TextSegmentBuilder
    var content: () -> [any SummaryProtocol]
    
//    init(tooltips: [Tooltip] = [], content: @escaping () -> [any SummaryProtocol]) {
//        self.tooltips = tooltips
//        self.content = content
//    }
    
    func render() -> String {
        content().map { $0.render() }.joined(separator: " ")
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

struct InputPhrase: SummaryProtocol {
    var tooltips: [Tooltip] = []
    private let node: FunctionParameterListSyntax
    @TextSegmentBuilder
    var content: (_ parameter: FunctionParameterSyntax) -> [any SummaryProtocol]
    
    init(_ node: FunctionParameterListSyntax, @TextSegmentBuilder content: @escaping (_ parameter: FunctionParameterSyntax) -> [any SummaryProtocol]) {
        self.node = node
        self.content = content
    }
    
    func render() -> String {
        // maybe could reuse Conjunction here or smth
        "takes input " + node.flatMap { content($0) }.map { $0.render() }.joined(separator: " ")
    }
}

struct OutputPhrase: SummaryProtocol {
    var tooltips: [Tooltip] = []
    
    func render() -> String {
        "returns \(self.node.type.recursiveNaturalLanguageDescription)"
    }
    
    private let node: ReturnClauseSyntax
    
    init(_ node: ReturnClauseSyntax) {
        self.node = node
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

