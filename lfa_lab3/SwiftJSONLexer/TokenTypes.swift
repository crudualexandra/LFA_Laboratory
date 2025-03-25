// TokenType.swift

import Foundation

public enum TokenType {
    case leftBrace       // '{'
    case rightBrace      // '}'
    case leftBracket     // '['
    case rightBracket    // ']'
    case colon           // ':'
    case comma           // ','
    case string          // "some text"
    case number          // 42, 3.14
    case boolean         // true or false
    case null            // null
    case whitespace      // spaces, tabs, newlines
    case unknown         // unrecognized input
}
