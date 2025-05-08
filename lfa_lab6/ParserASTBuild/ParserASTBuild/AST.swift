// AST.swift
import Foundation

/// Represents any JSON value in the AST.
public indirect enum JSONValue {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case number(Double)
    case boolean(Bool)
    case null
}
