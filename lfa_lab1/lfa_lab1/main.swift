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
    
  
    private func generateString(symbol: Character, length: Int, maxLength: Int) -> String {
        if length > maxLength {
            return ""
        }
        
        // If it's a terminal, just return it as a string.
        if terminals.contains(symbol) {
            return String(symbol)
        }
        
        // If there's no production for this symbol, return empty.
        guard let productions = rules[symbol], !productions.isEmpty else {
            return ""
        }
        
        // Randomly pick a production from the available ones.
        let chosenProduction = productions.randomElement() ?? ""
        
        var result = ""
        for ch in chosenProduction {
            result += generateString(symbol: ch, length: length + 1, maxLength: maxLength)
        }
        return result
    }
    
    /// Generates a specified number of strings from the start symbol.
    func generateStrings(count: Int) -> [String] {
        var generatedStrings = [String]()
        for _ in 0..<count {
            let str = generateString(symbol: startSymbol, length: 0, maxLength: 15)
            generatedStrings.append(str)
        }
        return generatedStrings
    }
    
   
    func convertToFA() -> FiniteAutomaton {
        var transitions: [Character: [Character: Character]] = [:]
        
        // States: all non-terminals + a dead state (X)
        var states = nonTerminals
        let deadState: Character = "X"
        states.insert(deadState)
        
        let initialState = startSymbol
        var acceptStates = Set<Character>()
        
        // Initialize the transition maps
        for nt in nonTerminals {
            transitions[nt] = [:]
        }
        transitions[deadState] = [:]
        
        // Build transitions from the grammar rules
        for (nt, prods) in rules {
            for production in prods {
                // If production is a single terminal, transition to deadState and mark it as accepting.
                if production.count == 1 {
                    if let terminal = production.first {
                        transitions[nt]?[terminal] = deadState
                        acceptStates.insert(deadState)
                    }
                } else if production.count >= 2 {
                    // If production is (terminal + nonTerminal)
                    let terminal = production.first!
                    let nextState = production.dropFirst().first! // next symbol
                    transitions[nt]?[terminal] = nextState
                }
            }
        }
        
        return FiniteAutomaton(states: states,
                               alphabet: terminals,
                               transitions: transitions,
                               initialState: initialState,
                               acceptStates: acceptStates)
    }
}

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
    
    /// Checks whether the given input string is accepted by this FA.
    func accepts(input: String) -> Bool {
        var currentState = initialState
        
        for symbol in input {
            // If the symbol is not in the alphabet or there's no valid transition, reject.
            guard alphabet.contains(symbol),
                  let stateTransitions = transitions[currentState],
                  let nextState = stateTransitions[symbol]
            else {
                return false
            }
            currentState = nextState
        }
        
        // Check if the last state is an accept state.
        return acceptStates.contains(currentState)
    }
}

// -------------------------
// MARK: - Main execution
// -------------------------


func main() {
    
    
    // -------------------------
    // Variant 10 grammar:
    //
    //   VN = { S, B, L }
    //   VT = { a, b, c }
    //   P = {
    //       S -> aB
    //       B -> bB
    //       B -> cL
    //       L -> cL
    //       L -> aS
    //       L -> b
    //   }
    //
    let nonTerminals: Set<Character> = ["S", "B", "L"]
    let terminals: Set<Character> = ["a", "b", "c"]
    let rules: [Character: [String]] = [
        "S": ["aB"],
        "B": ["bB", "cL"],
        "L": ["cL", "aS", "b"]
    ]
    
    // Create the grammar with start symbol 'S'
    let grammar = Grammar(nonTerminals: nonTerminals,
                          terminals: terminals,
                          rules: rules,
                          startSymbol: "S")
    
    // Generate some random strings
    let generatedStrings = grammar.generateStrings(count: 5)
    print("Generated Strings:")
    for str in generatedStrings {
        print(str)
    }
    
    // Convert to a Finite Automaton
    let fa = grammar.convertToFA()
    
    // Test the FA with some strings
    print("\nTesting with sample strings:")
    let testStrings = [
        "ab",
        "abb",
        "acb",
        "b",
        "abc"
    ]
    for testStr in testStrings {
        print("String: \(testStr) - Accepted: \(fa.accepts(input: testStr))")
    }
}


main()
