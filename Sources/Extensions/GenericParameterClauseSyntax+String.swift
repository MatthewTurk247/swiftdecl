//
//  GenericParameterClauseSyntax+String.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

extension GenericParameterClauseSyntax {
    func summarize() -> String {
        let parameters = self.genericParameterList.map { parameter -> String in
            var description = parameter.name.text
            if let inheritedType = parameter.inheritedType {
                description += ": "//\(inheritedType.summarize())"
            }
            return description
        }
        
        return "<\(parameters.joined(separator: ", "))>"
    }
}
