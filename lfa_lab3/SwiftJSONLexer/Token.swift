import Foundation

public struct Token {
    public let type: TokenType
    public let value: String   // The substring that was matched
    public let position: Int   // The start index of the token in the input
    
    public init(type: TokenType, value: String, position: Int) {
        self.type = type
        self.value = value
        self.position = position
    }
}
