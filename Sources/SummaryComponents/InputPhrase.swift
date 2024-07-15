//
//  InputPhrase.swift
//
//
//  Created by Matthew Turk on 7/9/24.
//

import Foundation
import SwiftSyntax

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
        "takes input " + node.flatMap { content($0) }.map { $0.render() }.itemized()
    }
}
