//
//  Footnote.swift
//
//
//  Created by Matthew Turk on 1/22/24.
//

import Foundation
import SwiftSyntax

struct Footnote {
    // A node from the syntax tree, namely of a function declaration.
    let node: Syntax
    // The text of the note associated with the node.
    let text: String
}
