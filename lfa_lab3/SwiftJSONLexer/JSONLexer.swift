// JSONLexer.swift

import Foundation

public class JSONLexer {
    
    private let input: String
    private var position: Int = 0
    
    public init(input: String) {
        self.input = input
    }
    
    public func tokenize() -> [Token] {
        var tokens: [Token] = []
        position = 0
        
        while position < input.count {
            // 1) Whitespace?
            if matchWhitespace(&tokens) {
                continue
            }
            // 2) Single-char tokens: { } [ ] : ,
            if matchSingleChar(&tokens) {
                continue
            }
            // 3) Strings
            if matchString(&tokens) {
                continue
            }
            // 4) Numbers
            if matchNumber(&tokens) {
                continue
            }
            // 5) Booleans
            if matchBoolean(&tokens) {
                continue
            }
            // 6) Null
            if matchNull(&tokens) {
                continue
            }
            // 7) Otherwise unknown
            matchUnknown(&tokens)
        }
        
        return tokens
    }
    
    // MARK: - Matching Methods
    
    /// 1) Match and emit whitespace as a token
    private func matchWhitespace(_ tokens: inout [Token]) -> Bool {
        let substring = input[position...]
        // Matches one or more whitespace characters
        let pattern = #"^\s+"#
        
        guard let range = substring.range(of: pattern, options: .regularExpression) else {
            return false
        }
        // If it matches at the start
        if range.lowerBound != substring.startIndex {
            return false
        }
        
        let matchValue = String(substring[range])
        tokens.append(Token(type: .whitespace, value: matchValue, position: position))
        position += matchValue.count
        return true
    }
    
    /// 2) Match single-char tokens
    private func matchSingleChar(_ tokens: inout [Token]) -> Bool {
        guard position < input.count else { return false }
        
        let ch = currentChar()
        let pos = position
        
        switch ch {
        case "{":
            tokens.append(Token(type: .leftBrace, value: String(ch), position: pos))
        case "}":
            tokens.append(Token(type: .rightBrace, value: String(ch), position: pos))
        case "[":
            tokens.append(Token(type: .leftBracket, value: String(ch), position: pos))
        case "]":
            tokens.append(Token(type: .rightBracket, value: String(ch), position: pos))
        case ":":
            tokens.append(Token(type: .colon, value: String(ch), position: pos))
        case ",":
            tokens.append(Token(type: .comma, value: String(ch), position: pos))
        default:
            return false
        }
        
        position += 1
        return true
    }
    
    /// 3) Match JSON strings: `"something"`, including possible escaped chars.
    private func matchString(_ tokens: inout [Token]) -> Bool {
        let substring = input[position...]
        // Regex: "(?:\\.|[^"\\])*"
        let pattern = #"^"(?:\\.|[^"\\])*""#
        
        guard let range = substring.range(of: pattern, options: .regularExpression),
              range.lowerBound == substring.startIndex
        else {
            return false
        }
        
        let matchValue = String(substring[range])
        tokens.append(Token(type: .string, value: matchValue, position: position))
        position += matchValue.count
        return true
    }
    
    /// 4) Match JSON numbers: 42, -3.14, etc.
    private func matchNumber(_ tokens: inout [Token]) -> Bool {
        let substring = input[position...]
        // Regex: -?\d+(\.\d+)?
        let pattern = #"^-?\d+(\.\d+)?"#
        
        guard let range = substring.range(of: pattern, options: .regularExpression),
              range.lowerBound == substring.startIndex
        else {
            return false
        }
        
        let matchValue = String(substring[range])
        tokens.append(Token(type: .number, value: matchValue, position: position))
        position += matchValue.count
        return true
    }
    
    /// 5) Match booleans: true | false
    private func matchBoolean(_ tokens: inout [Token]) -> Bool {
        let substring = input[position...]
        let pattern = #"^(true|false)"#
        
        guard let range = substring.range(of: pattern, options: .regularExpression),
              range.lowerBound == substring.startIndex
        else {
            return false
        }
        
        let matchValue = String(substring[range])
        tokens.append(Token(type: .boolean, value: matchValue, position: position))
        position += matchValue.count
        return true
    }
    
    /// 6) Match null
    private func matchNull(_ tokens: inout [Token]) -> Bool {
        let substring = input[position...]
        let pattern = #"""^null"#
        
        guard let range = substring.range(of: pattern, options: .regularExpression),
              range.lowerBound == substring.startIndex
        else {
            return false
        }
        
        let matchValue = String(substring[range])
        tokens.append(Token(type: .null, value: matchValue, position: position))
        position += matchValue.count
        return true
    }
    
    /// 7) Anything unrecognized becomes unknown
    private func matchUnknown(_ tokens: inout [Token]) {
        let pos = position
        let ch = currentChar()
        tokens.append(Token(type: .unknown, value: String(ch), position: pos))
        position += 1
    }
    
    // MARK: - Helper
    
    private func currentChar() -> Character {
        let idx = input.index(input.startIndex, offsetBy: position)
        return input[idx]
    }
}

extension String {
    subscript(_ range: PartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        return self[start...]
    }
}
