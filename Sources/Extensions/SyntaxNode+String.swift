//
//  File.swift
//  
//
//  Created by Matthew Turk on 4/9/24.
//

import Foundation
import SwiftSyntax

extension FunctionParameterListSyntax {
    var naturalLanguageDescription: String {
        self.compactMap { $0.phrase }.itemized()
    }
}

extension TypeSyntaxProtocol {
    func naturalLanguageSegments(includeChildren: Bool, preferredName: String? = nil) -> [String] {
        switch Syntax(self).as(SyntaxEnum.self) {
        case .classRestrictionType(let classRestrictionTypeSyntax):
            return ["class-constrained type"]
        case .arrayType(let arrayTypeSyntax):
            return ["array of"] + (includeChildren ? arrayTypeSyntax.element.naturalLanguageSegments(includeChildren: true) : [arrayTypeSyntax.element.description])
        default:
            return [self.description]
        }
    }
}
