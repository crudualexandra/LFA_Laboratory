import Foundation

/// A simple regex-like string generator for Swift terminal applications.
class RegexGenerator {
    let maxIterations: Int
    let maxStarRepeat: Int
    let maxPlusRepeat: Int

    init(maxIterations: Int = 1000, maxStarRepeat: Int = 5, maxPlusRepeat: Int = 5) {
        self.maxIterations = maxIterations
        self.maxStarRepeat = maxStarRepeat
        self.maxPlusRepeat = maxPlusRepeat
    }

    /// Parses a regex-like pattern into tokens and processes them.
    func parseRegex(_ pattern: String) -> [String] {
        let tokens = tokenize(pattern)
        return processTokens(tokens)
    }

    /// Generates up to `count` strings for each given pattern.
    @discardableResult
    func generate(patterns: [String], count: Int) -> [String] {
        var allResults = [String]()

        for pattern in patterns {
            var patternResults = [String]()
            var iterations = 0

            while patternResults.count < count && iterations < maxIterations {
                let generated = parseRegex(pattern)
                if let first = generated.first {
                    patternResults.append(first)
                }
                iterations += 1
            }

            print("Pattern: \(pattern)")
            print("  Results: \(patternResults)")
            allResults.append(contentsOf: patternResults)
        }

        return allResults
    }

    // MARK: - Tokenization

    private func tokenize(_ regex: String) -> [String] {
        var tokens = [String]()
        var i = regex.startIndex

        while i < regex.endIndex {
            let c = regex[i]

            if c == "(" {
                // Extract a group, including nested parentheses
                var level = 1
                var j = regex.index(after: i)
                while j < regex.endIndex && level > 0 {
                    if regex[j] == "(" { level += 1 }
                    else if regex[j] == ")" { level -= 1 }
                    j = regex.index(after: j)
                }
                if level == 0 {
                    let content = String(regex[regex.index(after: i)..<regex.index(before: j)])
                    var op: Character? = nil
                    if j < regex.endIndex, isRepetitionOperator(regex[j]) {
                        op = regex[j]
                        j = regex.index(after: j)
                    }
                    let token = "(\(content))" + (op.map { String($0) } ?? "")
                    tokens.append(token)
                    i = j
                } else {
                    tokens.append(String(c))
                    i = regex.index(after: i)
                }
            }
            // Single character with repetition operator
            else if let next = regex.index(i, offsetBy: 1, limitedBy: regex.endIndex), next < regex.endIndex,
                    isRepetitionOperator(regex[next]) {
                tokens.append(String(regex[i...next]))
                i = regex.index(after: next)
            }
            else {
                tokens.append(String(c))
                i = regex.index(after: i)
            }
        }

        return tokens
    }

    private func isRepetitionOperator(_ c: Character) -> Bool {
        return c == "*" || c == "+" || c == "?" || c.isSuperscript
    }

    // MARK: - Processing Tokens

    private func processTokens(_ tokens: [String]) -> [String] {
        var results = [""]

        for token in tokens {
            var newResults = [String]()

            // Group without repetition (handles alternation)
            if token.hasPrefix("(") && token.hasSuffix(")") {
                let content = String(token.dropFirst().dropLast())
                if content.contains("|") {
                    // Handle alternation
                    let alternatives = content.split(separator: "|").map(String.init)
                    for prefix in results {
                        for alt in alternatives {
                            let altResults = processTokens(tokenize(alt))
                            for suffix in altResults {
                                newResults.append(prefix + suffix)
                            }
                        }
                    }
                } else {
                    // Single-option group
                    let groupResults = processTokens(tokenize(content))
                    for prefix in results {
                        for suffix in groupResults {
                            newResults.append(prefix + suffix)
                        }
                    }
                }
            }
            // Group with repetition operator
            else if token.hasPrefix("(") && hasRepetitionOperator(token) {
                let op = token.last!
                let content = String(token.dropFirst().dropLast(2))
                let repeatCount: Int = {
                    switch op {
                    case "*": return Int.random(in: 0...maxStarRepeat)
                    case "+": return Int.random(in: 1...maxPlusRepeat)
                    case "?": return Int.random(in: 0...1)
                    default: return op.superscriptValue ?? 0
                    }
                }()
                let choices: [String]
                if content.contains("|") {
                    choices = content.split(separator: "|").map(String.init)
                } else {
                    choices = [content]
                }
                for prefix in results {
                    let choice = choices.randomElement() ?? ""
                    let groupResults = processTokens(tokenize(choice))
                    let suffix = groupResults.first ?? ""
                    let repeated = String(repeating: suffix, count: repeatCount)
                    newResults.append(prefix + repeated)
                }
            }
            // Single character with repetition
            else if token.count == 2, let op = token.last, isRepetitionOperator(op) {
                let char = token.first!
                let repeatCount: Int = {
                    switch op {
                    case "*": return Int.random(in: 0...maxStarRepeat)
                    case "+": return Int.random(in: 1...maxPlusRepeat)
                    case "?": return Int.random(in: 0...1)
                    default: return op.superscriptValue ?? 0
                    }
                }()
                for prefix in results {
                    let repeated = String(repeating: char, count: repeatCount)
                    newResults.append(prefix + repeated)
                }
            }
            // Empty token (μ)
            else if token == "μ" {
                newResults = results
            }
            // Literal character
            else {
                for prefix in results {
                    newResults.append(prefix + token)
                }
            }

            results = newResults
        }

        return results
    }

    private func hasRepetitionOperator(_ token: String) -> Bool {
        guard token.count >= 2 else { return false }
        return isRepetitionOperator(token.last!)
    }
}

// MARK: - Character Helpers

private extension Character {
    /// Checks if the character is a Unicode superscript digit.
    var isSuperscript: Bool {
        "²³⁴⁵⁶⁷⁸⁹".contains(self)
    }

    /// Converts a Unicode superscript digit to its integer value.
    var superscriptValue: Int? {
        switch self {
        case "²": return 2
        case "³": return 3
        case "⁴": return 4
        case "⁵": return 5
        case "⁶": return 6
        case "⁷": return 7
        case "⁸": return 8
        case "⁹": return 9
        default: return nil
        }
    }
}

// MARK: - Main Execution

// Example usage in a Swift terminal application:
let generator = RegexGenerator(maxIterations: 1000, maxStarRepeat: 3, maxPlusRepeat: 4)
let patterns = [
    "M?N²(O|P)³Q*R+",
    "(X|Y|Z)³8+(9|0)",
    "(H|i)(J|K)L*N?"
]

// Generate 3 example strings per pattern
_ = generator.generate(patterns: patterns, count: 3)
