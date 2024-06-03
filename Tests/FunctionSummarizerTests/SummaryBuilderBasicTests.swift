//
//  SummaryBuilderBasicTests.swift
//
//
//  Created by Matthew Turk on 6/3/24.
//

import Foundation
import XCTest
@testable import swiftdecl

/*
 function named `reduce` takes inputs `initialResult` of type `T` `(T, Self.Output) -> T` escaping closure and returns output of type Publishers.Reduce<Self, T> function named, where `T` can be any type

 asynchronous function named `snapshot` takes inputs `configuration` of type `ConfigurationAppIntent` `context` of type `Context` and returns output of type SimpleEntry

 asynchronous function named `foo` takes inputs `name` of type `T` `values` of type `Int` `age` of type `Int ` and returns output of type `String` or `nil` or throws an error asynchronous, where `T` conforms to Numeric

 function named `authenticateUser` takes input unary throwing function that returns `Bool` and returns no output or throws an error if its input closure throws an error

 function named `tableView` takes inputs `tableView` of type `UITableView` `indexPath` of type `IndexPath` and returns output of type UITableViewCell

 function named `getAs` takes input `T.Type` and returns output of type `T` or `nil` function named, where `T` conforms to AnyObject

 function named `foo` takes input `[T]` and returns output of type R function named, where `T` conforms to Codable `R` conforms to Codable
 */

class SummaryBuilderBasicTests: XCTestCase {
    func testSimpleFunctionParsing() {
        // NounPhrase()
    }
}
