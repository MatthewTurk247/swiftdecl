//
//  OutputPhrase.swift
//
//
//  Created by Matthew Turk on 7/9/24.
//

import Foundation
import SwiftSyntax

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
