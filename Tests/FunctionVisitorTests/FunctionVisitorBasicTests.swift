//
//  FunctionVisitorBasicTests.swift
//
//
//  Created by Matthew Turk on 1/26/24.
//

import Foundation
import SwiftSyntax
import SwiftParser
import XCTest
@testable import swiftdecl

class FunctionVisitorBasicTests: XCTestCase {
    func testSimpleFunctionParsing() {
        let visitor = FunctionVisitor(viewMode: .fixedUp)
        let syntaxTree = Parser.parse(source: "func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry")
        visitor.walk(syntaxTree)
        XCTAssertNotNil(visitor.functionDecl)
        guard let functionDecl = visitor.functionDecl else { return }
        
        let summary = ParsedSummary {
            if (functionDecl.signature.effectSpecifiers?.asyncSpecifier) != nil {
                "asynchronous"
            }
            if let firstModifer = functionDecl.modifiers.first {
                firstModifer.name.text
            }
            "function"
            functionDecl.name.text.backticked
            Conjunction {
                InputPhrase(functionDecl.signature.parameterClause.parameters) { parameter in
                    parameter.type.naturalLanguageDescription(includeChildren: false, preferredName: parameter.secondName?.text ?? parameter.firstName.text)
                }
                Disjunction {
                    if let returnClause = functionDecl.signature.returnClause {
                        OutputPhrase(returnClause)
                    } else {
                        // Executes the function body and does not return anything.
                        "returns no output"
                    }

                    if functionDecl.signature.effectSpecifiers?.throwsSpecifier?.tokenKind == .keyword(.throws) {
                        "throws an error"
                    } else if functionDecl.signature.effectSpecifiers?.throwsSpecifier?.tokenKind == .keyword(.rethrows) {
                        "throws an error if its input closure throws an error"
                    }
                    
                    ErrorPhrase(description: "") {
                        "smth"
                    }
                }
                // if generics, RelativePhrase here
                if let genericParameterClause = functionDecl.genericParameterClause,
                   let genericWhereClause = functionDecl.genericWhereClause {
                    
                } else if let genericParameterClause = functionDecl.genericParameterClause {
                    
                }
                
                // or maybe RelativePhrase has initializer with genericParameterClause and optional genericWhereClause
            }
        }.render()
        print(summary)
        
        XCTAssertFalse(summary.isEmpty)
    }
}

// Conjunction could be kinda like for each and then `{ item in ... }`

// Conjunction(functionDecl.signature.parameterClause)

/*Clause(predicate: {
    Compound(.take) {
        
    }
}) {
    // subject
    Compound {
        
    }
}
*/

/*
 Asynchronous public function named foo takes inputs name of type T, an indefinite number of values of type Int, and age of type Int with default value of 30 and returns output of String or nil, where T conforms to Numeric, or throws an error.
 Breakdown of Main Clause:
 Subject: "Asynchronous public function named foo"

 Adjectives: "Asynchronous public" modifying "function"
 Noun: "function"
 Appositive: "named foo" renaming "function"
 Verb: "takes" and "returns" and "throws" (compound verb structure with a coordination of actions the function performs)

 Objects/Complements:

 Direct Object 1: "inputs name of type T, an indefinite number of values of type Int, and age of type Int with default value of 30"
 Compound Object: Broken down into:
 "name of type T"
 "an indefinite number of values of type Int"
 "age of type Int with default value of 30"
 Direct Object 2: "output of String or nil"
 Phrases:

 Prepositional Phrases:
 "of type T" modifying "name"
 "of type Int" modifying "values" and "age"
 "with default value of 30" modifying "age of type Int"
 "of String or nil" modifying "output"
 Infinitive Phrase: The sentence does not contain a clear infinitive phrase, but the structure "takes inputs" and "returns output" implies an infinitive understanding of actions the function is capable of.
 Breakdown of Subordinate Clause:
 Conjunction: "where" introduces the subordinate clause that provides additional information about the type "T".

 Subject: "T"

 Verb: "conforms"

 Object: "Numeric"

 let sentence = Clause(
     subject: .compound(
         .noun(NounPhrase(adjectives: ["asynchronous", "public"], noun: "function", prepositionalPhrase: nil)),
         .participle(ParticiplePhrase(participle: "named", complement: .noun(NounPhrase(adjectives: [], noun: "foo", prepositionalPhrase: nil))))
     ),
     predicate: .verb(VerbPhrase(verb: "takes", objects: [
         .compound(
             .prepositional(PrepositionalPhrase(preposition: "inputs", objectOfPreposition: .noun(NounPhrase(adjectives: [], noun: "name", prepositionalPhrase: .prepositional(PrepositionalPhrase(preposition: "of type", objectOfPreposition: .noun(NounPhrase(adjectives: [], noun: "T", prepositionalPhrase: nil)))))))),
             .compound(
                 .prepositional(PrepositionalPhrase(preposition: "an indefinite number of values", objectOfPreposition: .prepositional(PrepositionalPhrase(preposition: "of type", objectOfPreposition: .noun(NounPhrase(adjectives: [], noun: "Int", prepositionalPhrase: nil)))))),
                 .prepositional(PrepositionalPhrase(preposition: "and age", objectOfPreposition: .compound(
                     .prepositional(PrepositionalPhrase(preposition: "of type", objectOfPreposition: .noun(NounPhrase(adjectives: [], noun: "Int", prepositionalPhrase: nil)))),
                     .prepositional(PrepositionalPhrase(preposition: "with default value", objectOfPreposition: .noun(NounPhrase(adjectives: [], noun: "30", prepositionalPhrase: nil))))
                 )))
             )
         ),
         .verb(VerbPhrase(verb: "returns", objects: [
             .prepositional(PrepositionalPhrase(preposition: "output", objectOfPreposition: .compound(
                 .noun(NounPhrase(adjectives: [], noun: "String", prepositionalPhrase: nil)),
                 .noun(NounPhrase(adjectives: [], noun: "nil", prepositionalPhrase: nil))
             )))
         ])),
         .participle(ParticiplePhrase(participle: "where T conforms to", complement: .noun(NounPhrase(adjectives: [], noun: "Numeric", prepositionalPhrase: nil)))),
         .verb(VerbPhrase(verb: "or throws", objects: [
             .noun(NounPhrase(adjectives: [], noun: "an error", prepositionalPhrase: nil))
         ]))
     ])),
     conjunction: nil
 )

 */
