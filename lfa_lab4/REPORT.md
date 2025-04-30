
# Regular Expressions

### Course: Formal Languages & Finite Automata

### Author: Crudu Alexandra

## Theory

Regular expressions (regex) are patterns that describe sets of strings. They are extensively used in searching, matching, and parsing text, and in lexical analysis where recognizing patterns in input text is essential. Regexes can specify complex string patterns succinctly and are foundational in text processing, data validation, and compiler construction.

Regular expressions consist of literals and meta-characters that define search patterns. Meta-characters such as `*`, `+`, `?`, and alternation `|` describe repetition and optional components, while parentheses `()` are used for grouping and precedence.



## Implementation description

### RegexGenerator Class

This class dynamically parses regex patterns, tokenizes them, and generates valid string combinations respecting regex semantics.

Initializes the generator with specified limits.
```swift
init(maxIterations: Int = 1000, maxStarRepeat: Int = 5, maxPlusRepeat: Int = 5)
```

### Tokenizing Regex Patterns

Tokenizes input patterns into manageable units (tokens), respecting grouping and operators.
```swift
private func tokenize(_ regex: String) -> [String]
```

Detects repetition operators (*, +, ?, superscript numerals).
```swift
private func isRepetitionOperator(_ c: Character) -> Bool
```

### Processing Tokens

Generates strings from tokens by expanding groups, repetitions, and alternations according to regex rules.
```swift
private func processTokens(_ tokens: [String]) -> [String]
```

Identifies repetition within token groups.
```swift
private func hasRepetitionOperator(_ token: String) -> Bool
```

### Generation Function

Produces valid strings for each regex pattern up to defined iteration limits.
```swift
func generate(patterns: [String], count: Int) -> [String]
```

### Main Execution Example

Uses predefined complex regex patterns to demonstrate the generation of valid string outputs.

```swift
let generator = RegexGenerator(maxIterations: 1000, maxStarRepeat: 3, maxPlusRepeat: 4)
let patterns = [
    "M?N²(O|P)³Q*R+",
    "(X|Y|Z)³8+(9|0)",
    "(H|i)(J|K)L*N?"
]
_ = generator.generate(patterns: patterns, count: 3)
```

## Results

The provided regex patterns from Variant 2 generated valid sample strings successfully, adhering strictly to the dynamic parsing rules and repetition constraints:

**Variant 2 (provided task patterns):**



- `M?N²(O|P)³Q*R+` generated examples like `{MNNOOOQR, NNPPPQQQRRR, ...}`
- `(X|Y|Z)³8+(9|0)` generated examples like `{XXX89, YYY88889, ...}`
- `(H|i)(J|K)L*N?` generated examples like `{HJLLN, IKLLLLLL, ...}`

## Difficulties Encountered

- Handling nested groups and various repetition operators required careful token parsing logic.
- Implementing a practical limit on repetitions (e.g., 5) to avoid infinite loops and overly long strings.
- Ensuring alternation (`|`) and grouped expressions were processed dynamically rather than hardcoded.

## Conclusion

This implementation effectively demonstrates dynamic interpretation of complex regex patterns, generating valid strings systematically. It highlights the flexibility and practicality of regexes in automating text generation and validation tasks, providing a solid foundation for further studies in formal languages and automata.

