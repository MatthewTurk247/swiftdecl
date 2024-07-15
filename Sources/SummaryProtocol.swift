//
//  SummaryProtocol.swift
//
//
//  Created by Matthew Turk on 7/9/24.
//

import Foundation

protocol SummaryProtocol { //CustomStringConvertible {
    var tooltips: [Tooltip]  { get }
    func render() -> String
}
