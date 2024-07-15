//
//  Conjunction.swift
//
//
//  Created by Matthew Turk on 7/9/24.
//

import Foundation

struct Conjunction: SummaryProtocol {
    var tooltips: [Tooltip] = []
    
    @TextSegmentBuilder
    var content: () -> [any SummaryProtocol]
    
//    init(tooltips: [Tooltip] = [], content: @escaping () -> [any SummaryProtocol]) {
//        self.tooltips = tooltips
//        self.content = content
//    }
//
    func render() -> String {
        content().map { $0.render() }.itemized()
    }
}
