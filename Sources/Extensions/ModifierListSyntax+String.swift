//
//  ModifierListSyntax+String.swift
//
//
//  Created by Matthew Turk on 10/7/23.
//

import Foundation
import SwiftSyntax

extension ModifierListSyntax {
    var summary: String {
        var result = ""
        
        for element in self {
            let modifier = element.cast(DeclModifierSyntax.self)
            // what about `open` keyword?
            switch modifier.name.tokenKind {
            case .publicKeyword:
                break // not implemented yet
            case .internalKeyword:
                break // ditto
            case .fileprivateKeyword:
                break // not implemented yet
            case .privateKeyword:
                break // ditto
            default:
                break // ditto
            }
        }
        
        return result
    }
    
    var explanation: String {
        return "" // not implemented yet
    }
}
