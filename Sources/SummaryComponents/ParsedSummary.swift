//
//  ParsedSummary.swift
//
//
//  Created by Matthew Turk on 7/9/24.
//

import Foundation

struct ParsedSummary: SummaryProtocol {
    var tooltips: [Tooltip] = []
    @TextSegmentBuilder
    var content: () -> [any SummaryProtocol]
    
    func render() -> String {
        let result = content().map { $0.render() }.joined(separator: " ")
        guard let firstUppercased = result.first?.uppercased() else { return result }
        
        return "\(firstUppercased)\(result.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines))."
    }
}

// TODO: Add struct for AvailabilitySummary, which, in practice, will be a sentence that follows the ParsedSummary sentence.
