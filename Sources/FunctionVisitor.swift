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
    var attributeDescriptions: [String] = []
    var parameterDescriptions: [String] = []
    // var reverseIndex: [String: Syntax] = [:]
    
    // https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/
    static let mainAttribute: String = "Indicates the top-level entry point for program flow"
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
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
            print(availabilityDescription)
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
    
    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        let isVariadic = node.tokens(viewMode: .fixedUp).contains { $0.tokenKind == .ellipsis }
        let isInOut = node.tokens(viewMode: .fixedUp).contains { $0.tokenKind == .inoutKeyword }

        if let firstName = node.firstName, let type = node.type {
            var partial = ""
            var typeDescription = type.description

            if isVariadic {
                partial += "an indefinite number of "
                typeDescription = String(typeDescription.dropLast(3).trimmingCharacters(in: .whitespaces))
            } else if isInOut {
                partial += "a non-constant "
                typeDescription = String(typeDescription.dropFirst(5).trimmingCharacters(in: .whitespaces))
            }
            partial += "`\(firstName)` of type `\(typeDescription)`"
            if let defaultArgument = node.defaultArgument {
                partial += " with default value of `\(defaultArgument.value)`"
            }
            parameterDescriptions.append(partial)
        }
        
        return .visitChildren
    }
    
    override func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        print(node.name.text, terminator: " ")
        if let inheritedType = node.inheritedType {
            print("conforms to \(inheritedType)")
        } else {
            print("can be any type")
        }
        return .visitChildren
    }
    
    func summarize() -> String {
        var result = ""
        

        // Add async and throws specifiers
        if let asyncKeyword = self.asyncOrReasyncKeyword?.text {
            // resync?
            result += "asynchronous "
        }

        // Add modifiers description
        if let modifiers = self.modifiers {
            result += modifiers.map { $0.description }.joined(separator: " ")
        }

        // Add function name
        result += "function "
        if let functionName = self.identifier?.text {
            result += "named `\(functionName)`"
        }

        // Add parameters description
        if let params = self.parameterList, !params.isEmpty {
            let paramsDescription = params.compactMap { param in
                // let externalName = param.firstName?.text ?? ""
                guard let internalName = param.firstName?.text else { return "" }
                let type = param.type?.description ?? "unknown type"
                var isVariadic = false // this is a bit of a hack, but will do for now
                let defaultArgumentValue = param.defaultArgument?.value.description
                // PackExpansionTypeSyntax(patternType: , ellipsis: )
                // TupleTypeSyntax(elements: )
                for token in Syntax(param.cast(FunctionParameterSyntax.self)).tokens(viewMode: .fixedUp) {
                    if token.text == "..." {
                        isVariadic = true
                    }
                }
                if isVariadic {
                    return "an indefinite number of `\(internalName)` of type `\(type.dropLast(3))`"
                }
                var partial = "`\(internalName)` of type `\(type.trimmingCharacters(in: .whitespaces))`"
                if let defaultArgumentValue {
                    partial += " with default value of `\(defaultArgumentValue)`"
                }
                
                return partial
            }.joined(separator: ", ")
            result += " takes inputs \(paramsDescription)"
        } else {
            result += " takes no inputs"
        }
        
        if let rrType = self.returnType, let optionalReturnType = OptionalTypeSyntax(rrType) {
            result += " and returns `\(rrType.description.dropLast())` or `nil`"
        } else if let returnType = self.returnType?.description {
            result += " and returns `\(returnType)`"
        } else {
            result += " and does not return a value"
        }
        
        // Add generic where clause
        if let whereClause = self.genericWhereClause {
            print(whereClause)
            result += ", where \(whereClause.description),"
        }
        
        // Add generic parameters description
        if let generics = self.genericParameterClause {
            // print(generics.recursiveDescription)
            // result += ", where \(generics)," must conform to...
            result += ", where"

                for parameter in generics.genericParameterList {
                     let parameterName = parameter.name.text
                        result += " \(parameterName) "

                        if let inheritedType = parameter.inheritedType {
                            result += "conforms to \(inheritedType)"
                        } else {
                            result += "can be any type"
                        }
                    if parameter.trailingComma != nil {
                        result += ", "
                    }
                }
            result += ","
        }
        
        if let throwsKeyword = self.throwsOrRethrowsKeyword {
            switch throwsKeyword.tokenKind {
            case .throwsKeyword:
                result += " or throws an error"
            case .rethrowsKeyword:
                result += " or throws an error if its input function throws an error"
            default:
                break
            }
        }
        
        // Add attributes description
        if let attributes = self.attributes, !attributes.isEmpty {
            let attributesDescription = attributes.map { $0.description }.joined(separator: ", ")
            result += ". " + attributes.summarize() + "."
        }
        
        print(parameterDescriptions)
        
        guard !result.isEmpty else { return result }

        return result.prefix(1).capitalized + result.dropFirst()
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
