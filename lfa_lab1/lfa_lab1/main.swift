import Foundation

class Grammar {
    private let nonTerminals: Set<Character>
    private let terminals: Set<Character>
    private let rules: [Character: [String]]
    private let startSymbol: Character
    
    init(nonTerminals: Set<Character>,
         terminals: Set<Character>,
         rules: [Character: [String]],
         startSymbol: Character) {
        self.nonTerminals = nonTerminals
        self.terminals = terminals
        self.rules = rules
        self.startSymbol = startSymbol
    }
    
    /// Safely generate a random string from the grammar (up to maxLength).
    private func generateString(symbol: Character,
                                length: Int,
                                maxLength: Int) -> String {
        // 1) If we exceed max length, abort this path.
        if length > maxLength {
            return ""
        }
        
        // 2) If symbol is a terminal, return it.
        if terminals.contains(symbol) {
            return String(symbol)
        }
        
        // 3) No productions => empty.
        guard let productions = rules[symbol], !productions.isEmpty else {
            return ""
        }
        
        // up to 5 random picks
        for _ in 0..<5 {
            let chosenProduction = productions.randomElement() ?? ""
            
            var result = ""
            for ch in chosenProduction {
                let partial = generateString(symbol: ch,
                                             length: length + 1,
                                             maxLength: maxLength)
                if partial.isEmpty {
                    // If any sub-part fails, we discard this production
                    result = ""
                    break
                } else {
                    result += partial
                }
            }
            if !result.isEmpty {
                return result
            }
        }
        
        return ""
    }
    
    /// Generate `count` strings from the start symbol.
    func generateStrings(count: Int, maxLength: Int = 15) -> [String] {
        var results = [String]()
        for _ in 0..<count {
            let str = generateString(symbol: startSymbol,
                                     length: 0,
                                     maxLength: maxLength)
            results.append(str)
        }
        return results
    }
    
    // Convert this right-linear grammar to an NFA.
    func convertToFA() -> FiniteAutomaton {
        var transitions: [Character: [Character: Character]] = [:]
        
        // 1) Gather states = all nonTerminals + final state 'F'
        var states = nonTerminals
        let finalState: Character = "F"
        states.insert(finalState)
        
        let initialState = startSymbol
        let acceptStates: Set<Character> = [finalState]
        
        // 2) Initialize transitions
        for st in states {
            transitions[st] = [:]
        }
        
        // 3) Build transitions from the grammar rules
        for (nt, prods) in rules {
            for production in prods {
                if production.count == 1 {
                    // Single terminal => (nt, terminal) -> F
                    let terminal = production.first!
                    transitions[nt]?[terminal] = finalState
                } else if production.count == 2 {
                    // terminal + nonTerminal => (nt, terminal) -> nextNonTerminal
                    let terminal = production.first!
                    let nextState = production.last!
                    transitions[nt]?[terminal] = nextState
                }
            }
        }
        
        // 4) Return the NFA
        return FiniteAutomaton(
            states: states,
            alphabet: terminals,
            transitions: transitions,
            initialState: initialState,
            acceptStates: acceptStates
        )
    }
}

// Simple NFA class
class FiniteAutomaton {
    private let states: Set<Character>
    private let alphabet: Set<Character>
    private let transitions: [Character: [Character: Character]]
    private let initialState: Character
    private let acceptStates: Set<Character>
    
    init(states: Set<Character>,
         alphabet: Set<Character>,
         transitions: [Character: [Character: Character]],
         initialState: Character,
         acceptStates: Set<Character>) {
        self.states = states
        self.alphabet = alphabet
        self.transitions = transitions
        self.initialState = initialState
        self.acceptStates = acceptStates
    }
    
    /// Check acceptance of `input`.
    func accepts(input: String) -> Bool {
        var currentState = initialState
        
        for symbol in input {
            // If there's no transition, we reject immediately.
            guard alphabet.contains(symbol),
                  let nextState = transitions[currentState]?[symbol]
            else {
                return false
            }
            currentState = nextState
        }
        // Accept iff currentState is in acceptStates.
        return acceptStates.contains(currentState)
    }
}

// -------------------------

//
//   VN = { S, B, L }
//   VT = { a, b, c }
//   P = {
//       S -> aB
//       B -> bB | cL
//       L -> cL | aS | b
//   }

func main() {
    let nonTerminals: Set<Character> = ["S", "B", "L"]
    let terminals: Set<Character> = ["a", "b", "c"]
    let rules: [Character: [String]] = [
        "S": ["aB"],
        "B": ["bB", "cL"],
        "L": ["cL", "aS", "b"]
    ]
    
    let grammar = Grammar(nonTerminals: nonTerminals,
                          terminals: terminals,
                          rules: rules,
                          startSymbol: "S")
    
    // Generate a few strings
    let generatedStrings = grammar.generateStrings(count: 5, maxLength: 15)
    print("Generated Strings from Grammar:")
    for str in generatedStrings {
        print("  \(str)")
    }
    
    // Convert to FA
    let fa = grammar.convertToFA()
    
    // Test acceptance
    print("\nTesting the FA with some sample strings:")
    let testStrings = ["ab", "abb", "acb", "b", "abc", "abcb", "abbbc"]
    for tstr in testStrings {
        print("  \(tstr) => \(fa.accepts(input: tstr))")
    }
}

main()
