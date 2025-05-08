// main.swift
import Foundation

// 1) Read some example JSON
let example = """
{
  "name": "Alex",
  "year": 2025,
  "features": ["lexer","parser","AST","graphviz"],
  "active": true,
  "nested": { "a": null, "b": [1,2,3] }
}
"""

// 2) Tokenize
let lexer = JSONLexer(input: example)
let tokens = lexer.tokenize()

// 3) Parse
do {
    let parser = JSONParser(tokens: tokens)
    let ast = try parser.parse()

    // 4) Print GraphViz dot to stdout
    let dot = ast.graphViz()
    print(dot)

    // 5) (Optionally) write it out so you can render:
    let path = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("ast.dot")
    try dot.write(to: path, atomically: true, encoding: .utf8)
    print("Saved AST dot to \(path.path)")
} catch {
    print("Parse error: \(error)")
}
