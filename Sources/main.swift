import ArgumentParser
import SwiftSyntax
import SwiftSyntaxParser

struct SwiftDecl: ParsableCommand {
    @Argument(help: "Raw Swift source code or a path to a Swift file.")
    var source: String
    
    @Flag(help: "Format output as JSON.")
    var json = false // Whether user prefers JSON output
    
    static let configuration = CommandConfiguration(abstract: "A command-line tool for systematically analyzing and explaining Swift function declarations.")
    
    func run() throws {
        let visitor = FunctionVisitor(viewMode: .fixedUp)
        let syntaxTree = try SyntaxParser.parse(source: source)
        guard !syntaxTree.hasError else { throw InputError.invalidSource } // { throw SwiftSyntax.UnexpectedNodesSyntax }
        
        visitor.walk(syntaxTree)
        var colorMapping: [Range<String.Index>: ANSI] = [:]
        var highlightMapping: [Range<String.Index>: Tooltip] = [:]
        
        if let attributes = visitor.attributes {
//            print(attributes.summarize())
            for attribute in attributes {
                colorMapping[syntaxSlice(attribute, in: source)] = .red
            }
        }
        if let funcKeyword = visitor.funcKeyword {
            colorMapping[syntaxSlice(funcKeyword, in: source)] = .red
        }
        if let identifier = visitor.identifier {
            colorMapping[syntaxSlice(identifier, in: source)] = .green
        }
        if let throwsOrRethrowsKeyword = visitor.throwsOrRethrowsKeyword {
            colorMapping[syntaxSlice(throwsOrRethrowsKeyword, in: source)] = .red
        }
        if let parameterList = visitor.parameterList {
            // Go parameter by parameter
//            print(parameterList.summarize())
        }
        if let returnType = visitor.returnType {
            colorMapping[syntaxSlice(returnType, in: source)] = .blue
        }
//        print(colorize(source, with: colorMapping))
        print(visitor.summarize())
    }
}

// MARK: - Helper Functions
extension SwiftDecl {
    func colorize(_ text: String, with mappings: [Range<String.Index>: ANSI]) -> String {
        var result: String = ""
        var currentIndex: String.Index = text.startIndex
        // Sort the mappings by the starting index to ensure we process them in order.
        let sortedMappings = mappings.sorted { $0.key.lowerBound < $1.key.lowerBound }
        
        for (range, color) in sortedMappings {
            // Append the text before the range.
            result += text[currentIndex..<range.lowerBound]
            
            // Append the colorized text for the range.
            result += color.wrap(text[range])
            
            // Move the current index to the end of the range.
            currentIndex = range.upperBound
        }
        
        // Append any remaining text after the last range.
        result += String(text[currentIndex...])
        
        return result
    }

    func syntaxSlice(_ syntax: some SyntaxProtocol, in text: String) -> Range<String.Index> {
        let startIndex = String.Index(utf16Offset: syntax.positionAfterSkippingLeadingTrivia.utf8Offset, in: text)
        let endIndex = String.Index(utf16Offset: syntax.endPositionBeforeTrailingTrivia.utf8Offset, in: text)
        
        return startIndex..<endIndex
    }
}

// Given [params of type whatever], __, __, return
// Given __, __, __, run the function body and return no value

// possibly

// MARK: - Error Handling
extension SwiftDecl {
    struct RuntimeError: Error, CustomStringConvertible {
        var description: String

        init(_ description: String) {
            self.description = description
        }
    }
    
    enum InputError: Error {
        case invalidSource
    }
}

let source = """
@available(macOS 13.0, *) public func foo<T: Numeric>(name: T, values: Int..., age: Int = 30) async throws -> String?

func authenticateUser(method: (String) throws -> Bool) rethrows

func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
) -> UITableViewCell

func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry

func reduce<T>(
    _ initialResult: T,
    _ nextPartialResult: @escaping (T, Self.Output) -> T
) -> Publishers.Reduce<Self, T>

private func getAs<T: AnyObject>(_ objectType: T.Type) -> T?

func foo<T: Codable, R: Codable>(_ bar: inout [T]) -> R
"""

SwiftDecl.main([source])
