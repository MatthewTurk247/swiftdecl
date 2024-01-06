//
//  Collection+String.swift
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
            let allButLast = self.prefix(self.count - 1)
            let last = self.suffix(1)
            return "\(allButLast.map { $0.description }.joined(separator: ", ")), and \(last.first!.description)"
        }
    }
}
