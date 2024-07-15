//
//  String+SummaryProtocol.swift
//
//
//  Created by Matthew Turk on 7/9/24.
//

import Foundation

extension String: SummaryProtocol {
    func render() -> String {
        self
    }
    
    var tooltips: [Tooltip] {
        []
    }
}
