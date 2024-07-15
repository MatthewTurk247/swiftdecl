import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

struct SwiftDecl: ParsableCommand {
    @Argument(help: "Raw Swift source code or a path to a Swift file.")
    var source: String
    
    @Flag(help: "Format output as JSON.")
    var json = false // Whether user prefers JSON output
    
    static let configuration = CommandConfiguration(abstract: "A command-line tool for systematically analyzing and explaining Swift function declarations.")
    
    func run() throws {
        let visitor = FunctionVisitor(viewMode: .fixedUp)
        let syntaxTree = Parser.parse(source: source)
        guard !syntaxTree.hasError else { throw InputError.invalidSource } // { throw SwiftSyntax.UnexpectedNodesSyntax }
        
        visitor.walk(syntaxTree)
        
        /*for translation in visitor.summarize() {
            if json,
               let translationEncoding = try? JSONEncoder().encode(translation),
               let translationString = String(data: translationEncoding, encoding: .utf8) {
                print(translationString)
            } else {
                print(translation.text, terminator: "\n\n")
            }
        }*/
        
        let result = TokenSyntax.Summary {
            "smth"
            "another"
            if let funcKeyword = visitor.functionDecl?.funcKeyword {
                funcKeyword
            }
        }
        
        print(result.render())
        
        for composer in visitor.composers.values {
            let summary = composer.compose()
            print(summary.text, terminator: "\n\n")
        }
    }
}

@_cdecl("add")
func add(_ lhs: Int, _ rhs: Int) -> Int {
    return lhs + rhs
}

//@_cdecl("summarize")
//func summarize(_ source: String) -> [String] {
//    let visitor = FunctionVisitor(viewMode: .fixedUp)
//    let syntaxTree = Parser.parse(source: String(source))
//    guard !syntaxTree.hasError else { return [] }
//    visitor.walk(syntaxTree)
//    
//    return visitor.composers.values.map { $0.compose().text }
//}

@_cdecl("summarize")
func summarize(_ source: Int) -> Int {
    let visitor = FunctionVisitor(viewMode: .fixedUp)
    let syntaxTree = Parser.parse(source: source == 42 ? "func foo(n: Int)" : "func bar(n: Int, k: Int) -> String")
    guard !syntaxTree.hasError else {
        print("some kinda error")
        return -1
    }
    
    visitor.walk(syntaxTree)
    
    return visitor.functionDecl?.signature.parameterClause.parameters.count ?? 0
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

@main
func foo<T: Codable, R: Codable>(_ bar: inout [T]) -> R

func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Publishers.CompactMap<Self, T>

static func buildLimitedAvailability<W, C1, C2>(_ component: some RegexComponent) -> Regex<(Substring, C1?, C2?)>
"""

/*
 example build commands for WebAssembly
 (also, remember to set the proper Swift toolchain)
 https://book.swiftwasm.org/getting-started/setup.html
 
 swift build -target --triple wasm32-unknown-wasi \
 -parse-as-library \
     main.swift -o swiftdecl.wasm \
     -Xlinker --export=add \
     -Xclang-linker -mexec-model=reactor

 swift build --triple wasm32-unknown-wasi -Xswiftc -Osize --build-path ~/Desktop/swiftdecl-output

 swift build --triple wasm32-unknown-wasi -Xswiftc -Osize -Xlinker --export=add \
     -Xclang-linker -mexec-model=reactor --build-path ~/Desktop/swiftdecl-output
 */

SwiftDecl.main([source])
