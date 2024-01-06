//
//  File.swift
//  
//
//  Created by Matthew Turk on 1/5/24.
//

import Foundation

extension Collection where Element: CustomStringConvertible {
    func itemized() -> String {
        switch self.count {
        case 0:
            return ""
        case 1:
            return self.first!.description
        default:
            let allButLast = self.prefix(self.count - 1) //self.prefix(upTo: self.index(before: self.endIndex))
            let last = self.suffix(1)
            // result = self.dropLast().joined(separator: ", ") + ", and " + (self.dropFirst(self.count - 1).first ?? "")
            return allButLast.map { $0.description }.joined(separator: ", ") + ", and " + last.first!.description
        }
    }
}
