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
