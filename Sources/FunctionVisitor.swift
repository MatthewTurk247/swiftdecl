//
//  FunctionVisitor.swift
//  swiftdecl
//
//  Created by Matthew Turk on 10/2/23.
//

import Foundation
import SwiftSyntax

class FunctionVisitor: SyntaxVisitor {
    /// Attributes (optional): Attributes/property wrappers provide more information about the function's behavior or intended use, e.g., @discardableResult.
    var attributes: AttributeListSyntax?

    /// Modifiers (optional): These adjust the function's behavior or accessibility (e.g., `public`, `private`, `static`).
    var modifiers: ModifierListSyntax?
    
    /// Swift functions are declared using the `func` keyword.
    var funcKeyword: TokenSyntax?
    
    /// The name by which you will call the function. It should be descriptive of what the function does.
    var identifier: TokenSyntax?
    
    /// Enclosed in angle brackets `< >`, these allow you to make functions that work with any type.
    var genericParameterClause: GenericParameterClauseSyntax?
    var genericWhereClause: GenericWhereClauseSyntax?
    
    /// Enclosed in parentheses `()`, this is a comma-separated list of zero or more parameters.
    ///
    /// Each parameter may have any of the following properties:
    /// - Name (optional) for external use when calling the function.
    /// - Local name, used within the function body.
    /// - Data type.
    /// - Default value (optional).
    /// - Variadic parameter (optional), which accepts multiple values, denoted by `...` after its type.
    var parameterList: FunctionParameterListSyntax? // ditto
    var asyncOrReasyncKeyword: TokenSyntax?
    /// If the function can throw an error, you use the `throws` keyword before the return arrow to indicate that.
    var throwsOrRethrowsKeyword: TokenSyntax?
    /// If a function returns a value, you specify the type of the value after the return arrow.
    var returnType: TypeSyntax?
    
    var functionDecl: FunctionDeclSyntax?
    /*
     Function Keyword: Every function declaration starts with the func keyword.
     Return Arrow (optional): -> This symbol indicates that the function returns a value.

     Function Body: Enclosed in braces {}, this is where you write the series of statements that constitute the function's behavior.

     Access modifier
     func keyword
     Name
     Generic types
     Parameters
     Throwing specifier
     Return type
     Body
     Async specifier
     */
    private var summarizers: [FunctionDeclSyntax: FunctionSummarizer] = [:]
    var attributeDescriptions: [String] = []
    var genericRequirementDescriptions: [String] = []
    var parameterDescriptions: [String] = []
    // var reverseIndex: [String: Syntax] = [:]
    
    // https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/
    static let mainAttribute: String = "Indicates the top-level entry point for program flow"
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        // https://swiftpackageindex.com/apple/swift-syntax/509.0.2/documentation/swiftsyntax/attributesyntax
        self.functionDecl = node
        self.attributes = node.attributes
        self.modifiers = node.modifiers
        self.funcKeyword = node.funcKeyword
        self.identifier = node.identifier
        
        self.genericParameterClause = node.genericParameterClause
        self.genericWhereClause = node.genericWhereClause
        self.parameterList = node.signature.input.parameterList
        self.asyncOrReasyncKeyword = node.signature.asyncOrReasyncKeyword
        self.throwsOrRethrowsKeyword = node.signature.throwsOrRethrowsKeyword
        self.returnType = node.signature.output?.returnType

        return .visitChildren
    }

    override func visit(_ node: AvailabilityArgumentSyntax) -> SyntaxVisitorContinueKind {
        switch node.entry {
        case .availabilityVersionRestriction(let availabilityVersionRestrictionSyntax):
            var availabilityDescription = "available on \(availabilityVersionRestrictionSyntax.platform.text)"
            if let version = availabilityVersionRestrictionSyntax.version {
                availabilityDescription += " " + version.majorMinor.text
            }
        case .availabilityLabeledArgument(let availabilityLabeledArgumentSyntax):
            switch availabilityLabeledArgumentSyntax.value {
            case .string(let tokenSyntax):
                print(tokenSyntax.text)
            case .version(let versionTupleSyntax):
                print("available on \(versionTupleSyntax.majorMinor.text)")
            }
            print("(" + availabilityLabeledArgumentSyntax.value.description.trimmingCharacters(in: CharacterSet.init(charactersIn: "\"")) + ")")
        default:
            break
        }
                
        return .visitChildren
    }
    
    override func visit(_ node: AvailabilityLabeledArgumentSyntax) -> SyntaxVisitorContinueKind {
        print(node.label.text)
        return .visitChildren
    }

    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        let isVariadic = node.tokens(viewMode: .fixedUp).contains { $0.tokenKind == .ellipsis }
        let isInOut = node.tokens(viewMode: .fixedUp).contains { $0.tokenKind == .inoutKeyword }

        if let firstName = node.firstName, let type = node.type {
            var parameterDescription = ""
            var typeDescription = type.description

            if isVariadic {
                parameterDescription += "an indefinite number of "
                typeDescription = String(typeDescription.dropLast(3))
            } else if isInOut {
                parameterDescription += "a non-constant "
                typeDescription = String(typeDescription.dropFirst(5))
            }
            parameterDescription += "`\(firstName.text.trimmingCharacters(in: .whitespacesAndNewlines))` of type `\(typeDescription.trimmingCharacters(in: .whitespacesAndNewlines))`"
            if let defaultArgument = node.defaultArgument {
                parameterDescription += " with default value of `\(defaultArgument.value)`"
            }
            
            if let functionDecl = self.functionDecl {
                summarizers[functionDecl, default: FunctionSummarizer()].parameterDescriptions.append(parameterDescription)
            }
//            self.functionDescriptions[self.functionDecl].parameterDescriptions.append(parameterDescription)
        }
        
        return .visitChildren
    }
    
    override func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        if let functionDecl = self.functionDecl {
            if let inheritedType = node.inheritedType {
                summarizers[functionDecl, default: FunctionSummarizer()].genericRequirementDescriptions.append("\(node.name.text) conforms to \(inheritedType)")
            } else {
                summarizers[functionDecl, default: FunctionSummarizer()].genericRequirementDescriptions.append("can be any type")
            }
        }
        return .visitChildren
    }
    
    func summarize() -> String {
        var batches: [String] = []
        
        for (node, summarizer) in summarizers {
            // batches.append(summarizer.summarize(node))
//            print("key", node.signature.asyncOrReasyncKeyword, summarizer)
            var batch = ""
            
            // Add async and throws specifiers
            if let asyncKeyword = node.signature.asyncOrReasyncKeyword {
                // resync?
                batch += "asynchronous "
            }

            // Add modifiers description
            if let modifiers = node.modifiers {
                batch += modifiers.map { $0.description }.joined(separator: " ")
            }

            // Add function name
            batch += "function named `\(node.identifier.text)`"

            if summarizer.parameterDescriptions.isEmpty {
                batch += " takes no inputs"
            } else {
                batch += " takes inputs \(summarizer.parameterDescriptions.joined(separator: ", "))"
            }
            
            if let rrType = node.signature.output?.returnType, let optionalReturnType = OptionalTypeSyntax(rrType) {
                batch += " and returns `\(rrType.description.dropLast())` or `nil`"
            } else if let returnType = node.signature.output?.returnType.description {
                batch += " and returns `\(returnType)`"
            } else {
                batch += " and does not return a value"
            }
            
            // Add generic requirements
            if !summarizer.genericRequirementDescriptions.isEmpty {
                batch += ", where \(summarizer.genericRequirementDescriptions.joined(separator: ", ")),"
            }
            
            if let throwsKeyword = node.signature.throwsOrRethrowsKeyword {
                switch throwsKeyword.tokenKind {
                case .throwsKeyword:
                    batch += " or throws an error"
                case .rethrowsKeyword:
                    batch += " or throws an error if its input function throws an error"
                default:
                    break
                }
            }
            
            // Add attributes description
            if let attributes = node.attributes, !attributes.isEmpty {
                let attributesDescription = attributes.map { $0.description }.joined(separator: ", ")
                batch += ". " + attributes.summarize()
            }
            
            batch = String(batch.trimmingCharacters(in: CharacterSet(charactersIn: ","))) + "."
            batches.append(batch.isEmpty ? batch : (batch.prefix(1).capitalized + batch.dropFirst()))
        }

        return batches.joined(separator: "\n\n")
    }

        // "with inputs ..."

        /*
         example:
         A function named foo, available on macOS 13.0 and later, takes a string parameter named name, a variable number of integer values, and an optional integer parameter named age with a default value of 30, and returns a string.
         */
        
    // public func getAs<T: AnyObject>(_ objectType: T.Type) -> T?
    /*
     The public function named `getAs` takes a type parameter `T` that must be a class type. It takes one argument, which is the type of `T`, has no external name, and has an internal name of `objectType`. The function returns either an instance of type `T` or `nil`.
     */
    
    func explain() -> String {
        var result = "Given "
        let inputVerbiage = parameterList?.summarize() ?? "no external inputs"
        result += inputVerbiage
        
        if let returnTypeDescription = returnType?.description {
            result += "return \(returnTypeDescription)"
        } else {
            result += "execute the function body and return no value"
        }
        
        return "" // not implemented yet, could also return an explanation object or smth
    }
}
