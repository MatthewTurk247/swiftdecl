//
//  Footnote.swift
//
//
//  Created by Matthew Turk on 1/22/24.
//

import Foundation
import SwiftSyntax

struct Footnote: Encodable {
    // A node from the syntax tree, namely of a function declaration.
    let nodeDescription: String
    // let id: SyntaxIdentifier
    // The text of the note associated with the node.
    let text: String
    
    // https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/
    static let attributes = [
        "@available": "Indicates the platform and version on which the declaration is available. This attribute specifies the availability of a declaration in different Swift versions or different operating system versions.",
        "@objc": "Marks a piece of Swift code (like a class or a method) as being available in Objective-C. This is often used for interoperability between Swift and Objective-C code in the same project.",
        "@objcMembers": "Automatically infers @objc attribute for all members of a class or an extension.",
        "@nonobjc": "Prevents an otherwise automatically inferred @objc attribute. This can be used to stop Swift from exposing a method to Objective-C.",
        "@discardableResult": "Allows a function or method to return a value that doesn't necessarily have to be used by the caller.",
        "@IBAction": "Indicates that a method is an action that can be connected to an event in Interface Builder.",
        "@IBOutlet": "Marks a property in a view controller as an outlet, allowing it to be connected to a view or another element in Interface Builder.",
        "@IBDesignable": "Indicates that a custom view class can be rendered in Interface Builder.",
        "@IBInspectable": "Allows properties of a custom view to be modified in Interface Builder.",
        "@escaping": "Indicates that a closure is allowed to escape a function, meaning it can be stored and executed after the function returns.",
        "@autoclosure": "Automatically creates a closure from an expression passed in where a closure is expected.",
        "@inlinable": "Allows a function or method to be inlined by the compiler at the call site to improve performance.",
        "@GKInspectable": "Used in SpriteKit and GameplayKit to expose properties to the Scene Editor.",
        "@testable": "Allows a test target to access the internal elements of the module being tested.",
        "@UIApplicationMain": "Marks the entry point to a UIKit application.",
        "@main": "Indicates the top-level entry point for program flow."
    ]
}
