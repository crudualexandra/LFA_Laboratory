// JSONParser.swift
import Foundation

public enum JSONParseError: Error {
    case unexpectedToken(Token, expected: String)
    case endOfInput
}

public class JSONParser {
    private let tokens: [Token]
    private var pos = 0

    public init(tokens: [Token]) {
        // drop whitespace tokens if you like
        self.tokens = tokens.filter { $0.type != .whitespace }
    }

    private var current: Token? { pos < tokens.count ? tokens[pos] : nil }
    private func advance() { pos += 1 }

    public func parse() throws -> JSONValue {
        let value = try parseValue()
        guard pos == tokens.count else {
            throw JSONParseError.unexpectedToken(tokens[pos], expected: "end of input")
        }
        return value
    }

    private func parseValue() throws -> JSONValue {
        guard let t = current else { throw JSONParseError.endOfInput }
        switch t.type {
        case .leftBrace:   return try parseObject()
        case .leftBracket: return try parseArray()
        case .string:
            advance()
            // strip the quotes
            let s = t.value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            return .string(s)
        case .number:
            advance()
            return .number(Double(t.value)!)
        case .boolean:
            advance()
            return .boolean(t.value == "true")
        case .null:
            advance()
            return .null
        default:
            throw JSONParseError.unexpectedToken(t, expected: "value")
        }
    }

    private func parseObject() throws -> JSONValue {
        // consume '{'
        guard current?.type == .leftBrace else {
            throw JSONParseError.unexpectedToken(current!, expected: "{")
        }
        advance()
        var dict = [String: JSONValue]()
        while current?.type != .rightBrace {
            guard let keyTok = current, keyTok.type == .string else {
                throw JSONParseError.unexpectedToken(current!, expected: "string key")
            }
            let key = keyTok.value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            advance()
            guard current?.type == .colon else {
                throw JSONParseError.unexpectedToken(current!, expected: ":")
            }
            advance()
            let val = try parseValue()
            dict[key] = val
            if current?.type == .comma { advance() }
        }
        // consume '}'
        advance()
        return .object(dict)
    }

    private func parseArray() throws -> JSONValue {
        // consume '['
        guard current?.type == .leftBracket else {
            throw JSONParseError.unexpectedToken(current!, expected: "[")
        }
        advance()
        var arr = [JSONValue]()
        while current?.type != .rightBracket {
            arr.append(try parseValue())
            if current?.type == .comma { advance() }
        }
        // consume ']'
        advance()
        return .array(arr)
    }
}
