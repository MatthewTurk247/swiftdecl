//
//  FunctionVisitor.swift
//  swiftdecl
//
//  Created by Matthew Turk on 10/2/23.
//

import Foundation
import SwiftSyntax

/// `FunctionVisitor` is a subclass of `SyntaxVisitor` tailored to traverse and analyze Swift function declarations within a syntax tree.
///
/// When parsing a Swift source file using SwiftSyntax, `FunctionVisitor` walks through the syntax tree and collects detailed information about each function it encounters. This includes attributes, modifiers, function name, generic parameters, and other key components of a function's declaration.
///
/// The gathered information is utilized to construct a comprehensive summary of the function, providing insights into its behavior, accessibility, and structure. This summary can be particularly useful for generating documentation, aiding in code analysis, or presenting an overview of the function's capabilities and requirements in a human-readable format.
///
/// - Note: `FunctionVisitor` focuses specifically on function declarations and is not designed to handle other syntax tree elements. As a subclass of `SyntaxVisitor`, it overrides specific `visit` methods to target the components of a function declaration.
///
/// ## Usage
///
/// You typically use an instance of `FunctionVisitor` in conjunction with a ``SyntaxParser`` to analyze a Swift source file. After parsing the file, pass the resulting syntax tree to the `FunctionVisitor` for traversal and analysis.
///
/// Here is an example of how to use `FunctionVisitor`:
///
/// ```swift
/// import SwiftSyntax
///
/// let source = try SyntaxParser.parse("...")
/// let functionVisitor = FunctionVisitor()
/// source.walk(functionVisitor)
/// let functionSummaries = functionVisitor.summarize()
/// ```
///
/// After visiting all nodes in the syntax tree, you can retrieve a summary of each function with the `summarize()` method.
/// A future version is expected to produce footnotes for further detailed explanations of the structure and meaning of Swift function declarations.
class FunctionVisitor: SyntaxVisitor {
    /// Attributes (optional): Attributes/property wrappers provide more information about the function's behavior or intended use (e.g., `@discardableResult`).
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
    /// If the function can throw an error, you use the `throws` keyword before the return arrow to specify/indicate that.
    var throwsOrRethrowsKeyword: TokenSyntax?
    /// If a function returns a value, you specify the type of the value after the return arrow.
    var returnType: TypeSyntax?
    
    var functionDecl: FunctionDeclSyntax?

    private var summarizers: [FunctionDeclSyntax: FunctionSummarizer] = [:]
    var attributeDescriptions: [String] = []
    var genericRequirementDescriptions: [String] = []
    var parameterDescriptions: [String] = []
    var footnotes: [Footnote] = []
        
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
    
    // footnotes
    override func visit(_ node: AttributedTypeSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }
    
    // footnotes
    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        guard node.parent?.parent?.kind == .functionDecl else { return .skipChildren }
        guard let functionDecl else { return .visitChildren }
        
        switch node.argument {
        case .token(let tokenSyntax):
            break
        case .stringExpr(let stringLiteralExprSyntax):
            break
        case .availability(let availabilitySpecListSyntax):
            // @available: Indicates the platform and version on which the declaration is available.
            // Is it possible to have multiple versions in this syntax?
            guard let spec = availabilitySpecListSyntax
                .first(where: { $0.entry.kind == .availabilityVersionRestriction }) else { break }
            summarizers[functionDecl, default: FunctionSummarizer()].attributeDescriptions.append("available on \(spec.entry.description)")
        case .specializeArguments(let specializeAttributeSpecListSyntax):
            break
        case .objCName(let objCSelectorSyntax):
            summarizers[functionDecl, default: FunctionSummarizer()].attributeDescriptions.append("exposed to Objective-C")
        case .implementsArguments(let implementsAttributeArgumentsSyntax):
            break
        case .differentiableArguments(let differentiableAttributeArgumentsSyntax):
            break
        case .derivativeRegistrationArguments(let derivativeRegistrationAttributeArgumentsSyntax):
            break
        case .namedAttributeString(let namedAttributeStringArgumentSyntax):
            break
        case .backDeployedArguments(let backDeployedAttributeSpecListSyntax):
            break
        case .conventionArguments(let conventionAttributeArgumentsSyntax):
            break
        case .conventionWitnessMethodArguments(let conventionWitnessMethodAttributeArgumentsSyntax):
            break
        case .opaqueReturnTypeOfAttributeArguments(let opaqueReturnTypeOfAttributeArgumentsSyntax):
            break
        case .tokenList(let tokenListSyntax):
            break
        case .none:
            // These argument-less nodes will be mapped to pre-written, one-line explanations of what the attribute means.
            let attributeText = node.description.trimmingCharacters(in: .whitespacesAndNewlines)
            if let attributeDescription = Footnote.attributes[attributeText] {
                footnotes.append(Footnote(nodeDescription: attributeText, text: attributeDescription))
            }
        }
        
        return .visitChildren
    }

    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        let ellipsisToken = node.tokens(viewMode: .fixedUp).first { $0.tokenKind == .ellipsis }
        let inoutToken = node.tokens(viewMode: .fixedUp).first { $0.tokenKind == .inoutKeyword }
        guard let firstName = node.firstName, let type = node.type, let functionDecl else { return .visitChildren }
        var parameterDescription = ""
        var typeDescription = type.naturalLanguageDescription(includeChildren: false)

        if let ellipsisToken {
            // Parameter is variadic.
            parameterDescription += "an indefinite number of "
            typeDescription = String(typeDescription.dropLast(ellipsisToken.text.count))
        } else if inoutToken != nil {
            parameterDescription += "a non-constant "
        }
        // TODO: If there is a first name and second name, add a footnote explaining this.
        let parameterName = node.secondName?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? firstName.text.trimmingCharacters(in: .whitespacesAndNewlines)
        parameterDescription += "`\(parameterName)` of type \(typeDescription)"
        if let defaultArgument = node.defaultArgument {
            parameterDescription += " with default value of `\(defaultArgument.value)`"
        }

        // footnotes.append(node.type?.recursiveNaturalLanguageDescription)
        // print(node.recursivePhrase)
        summarizers[functionDecl, default: FunctionSummarizer()].parameterDescriptions.append(parameterDescription)
        
        return .visitChildren
    }
    
    override func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        guard let functionDecl else { return .visitChildren }
        var genericRequirementDescription = "`\(node.name.text)` "
        
        if let inheritedType = node.inheritedType {
            genericRequirementDescription += "conforms to `\(inheritedType)`"
        } else {
            genericRequirementDescription += "can be any type"
        }
        
        summarizers[functionDecl, default: FunctionSummarizer()].genericRequirementDescriptions.append(genericRequirementDescription)
        
        return .visitChildren
    }
    
    // Could also use AnyIterator perhaps
    func summarize() -> [FunctionSummarizer.Translation] {
        var translations: [FunctionSummarizer.Translation] = []
        
        for (node, summarizer) in summarizers {
            let summary = summarizer.summarize(node)
            var batch = summary.text
            batch = String(batch.trimmingCharacters(in: CharacterSet(charactersIn: ",").union(.whitespacesAndNewlines)))
            batch += "."
            translations.append(FunctionSummarizer.Translation(text: batch.isEmpty ? batch : (batch.prefix(1).capitalized + batch.dropFirst()), footnotes: summary.footnotes))
        }

        return translations
    }
    
    /*
     Return Arrow (optional): -> This symbol indicates that the function returns a value.
     Function Body: Enclosed in braces {}, this is where you write the series of statements that constitute the function's behavior.
     Async specifier

     Examples:
     A function named foo, available on macOS 13.0 and later, takes a string parameter named name, a variable number of integer values, and an optional integer parameter named age with a default value of 30, and returns a string.

     The public function named `getAs` takes a type parameter `T` that must be a class type. It takes one argument, which is the type of `T`, has no external name, and has an internal name of `objectType`. The function returns either an instance of type `T` or `nil`.
     */
}
