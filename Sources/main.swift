import ArgumentParser
import SwiftSyntax
import SwiftSyntaxParser

struct SwiftDecl: ParsableCommand {
    @Argument
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
        
        if let attributes = visitor.attributes {
            for attribute in attributes {
                colorMapping[syntaxSlice(Syntax(attribute), in: source)] = .red
            }
        }
        if let funcKeyword = visitor.funcKeyword {
            colorMapping[syntaxSlice(Syntax(funcKeyword), in: source)] = .red
        }
        if let identifier = visitor.identifier {
            colorMapping[syntaxSlice(Syntax(identifier), in: source)] = .green
        }
        if let throwsOrRethrowsKeyword = visitor.throwsOrRethrowsKeyword {
            colorMapping[syntaxSlice(Syntax(throwsOrRethrowsKeyword), in: source)] = .red
        }
        if let parameterList = visitor.parameterList {
            // Go parameter by parameter
        }
        if let returnType = visitor.returnType {
            colorMapping[syntaxSlice(Syntax(returnType), in: source)] = .blue
        }
        print(colorize(source, with: colorMapping))
    }
}

// MARK: - Helper Functions
extension SwiftDecl {
    func colorize(_ text: String, with mappings: [Range<String.Index>: ANSI]) -> String {
        var result = ""
        var currentIndex = text.startIndex
        
        // Sort the mappings by the starting index to ensure we process them in order.
        let sortedMappings = mappings.sorted(by: { $0.key.lowerBound < $1.key.lowerBound })
        
        for mapping in sortedMappings {
            let range = mapping.key
            let color = mapping.value
            
            // Append the text before the range.
            result += String(text[currentIndex..<range.lowerBound])
            
            // Append the colorized text for the range.
            result += color.wrap(String(text[range]))
            
            // Move the current index to the end of the range.
            currentIndex = range.upperBound
        }
        
        // Append any remaining text after the last range.
        result += String(text[currentIndex...])
        
        return result
    }

    func syntaxSlice(_ syntax: Syntax, in source: String) -> Range<String.Index> {
        let startIndex = String.Index(utf16Offset: syntax.positionAfterSkippingLeadingTrivia.utf8Offset, in: source)
        let endEndIndex = String.Index(utf16Offset: syntax.endPositionBeforeTrailingTrivia.utf8Offset, in: source)
        
        return startIndex..<endEndIndex
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

SwiftDecl.main()
