//
//  FunctionParameterListSyntax+String.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

extension FunctionParameterListSyntax {
    func summarize() -> String {
        var result = ""
        let visitor = ParameterVisitor(viewMode: .fixedUp)
        for parameter in self {
            visitor.walk(parameter)
            guard let localName = visitor.localName else { continue }
            // what is the recursiveDescription property? how different is it
            result += localName.text
        }
        
        return result
    }
}
