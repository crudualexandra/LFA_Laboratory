# Determinism in Finite Automata. Conversion from NDFA 2 DFA. Chomsky Hierarchy.

### Course: Formal Languages & Finite Automata
### Author: Crudu Alexandra, FAF-233

----

## Theory
Formal languages provide a framework for understanding how languages, in the broadest sense, are structured and processed. At its core, a formal language is defined by an alphabet, which is a finite set of symbols, and a set of strings formed from these symbols that are considered valid according to specific rules, known as the grammar of the language. Regular grammars, a subset of formal grammars, restrict the form of production rules and are powerful enough to describe numerous natural and artificial languages, though they cannot capture the complexities of all languages.

A grammar G is typically defined as a tuple G = (V_N, V_T, P, S), where:

- V_N is a finite set of non-terminal symbols.
- V_T is a finite set of terminal symbols.
- P is a finite set of production rules, each rule transforming a string of symbols into another string.
- S is the start symbol, a special non-terminal symbol from V_n used to begin the generation of strings.

A regular grammar is a type of formal grammar that generates regular languages, which are a subset of the class of formal languages. They can be of two types: right-linear grammars and left-linear grammars. A right-linear grammar has production rules of the form A → aB or A → a, where A and B are non-terminal symbols, a is a terminal symbol, and → denotes the transformation. A left-linear grammar has production rules of the form A → Ba or A → a, with the same symbols and transformation notation.

Regular languages can be recognized by finite automata, which are abstract machines that process input strings symbol by symbol and can produce outputs based on a set of internal states and transition rules.

A finite automaton FA can be defined as a tuple FA = (Q, Σ, δ, q_0, F), where:

- Q is a finite set of states.
- Σ is a finite set of input symbols (alphabet).
- δ is the transition function δ: Q × Σ → Q, defining the transitions between states based on input symbols.
- q_0 is the initial state, an element of Q.
- F is the set of accept states, a subset of Q.

The process of converting a grammar into a finite automaton involves translating the components of the grammar (non-terminal and terminal symbols, production rules, and the start symbol) into the components of a finite automaton (states, alphabet, transition function, initial state, and accept states).


## Objectives:



1. **Understand** the basic structure and definition of a finite automaton and classify it as deterministic or non-deterministic.
2. **Implement** the conversion of the given NFA to a DFA by using the subset construction algorithm.
3. **Convert** the same automaton into a regular (right-linear) grammar.
4. **Classify** the resulting grammar according to the Chomsky Hierarchy.
5. **Demonstrate** the acceptance checks for several input strings on both the original NFA and the derived DFA.
6. **(Bonus)** Provide a graphical representation (GraphViz `.dot` output) for the automaton.



## Implementation description

1. **Data Structures**:
   - `FiniteAutomaton`: Holds sets of states, the alphabet, transition function, initial and final states.
   - `Grammar`: Holds nonterminals, terminals, production rules, and a start symbol.
   - `Logger`: A simple struct for logging/debugging.
2. **Key Functions** in `FiniteAutomaton`:
   - `accepts(_ input: String) -> Bool`: 
     * Checks if a given input string is accepted by the automaton. 
     * For an NFA, it keeps track of all possible states at each step.
   - `isDeterministic() -> Bool`: 
     * Determines whether the automaton is deterministic by checking if each state-symbol pair has at most one next state.
   - `toDFA() -> FiniteAutomaton`: 
     * Converts the current NFA to an equivalent DFA using the subset construction.
   - `toRegularGrammar() -> Grammar`: 
     * Converts the automaton to a right-linear grammar by mapping each state to a nonterminal.
   - `toDot() -> String`: 
     * Generates a GraphViz `.dot` representation of the automaton for graphical visualization.

3. **Key Functions** in `Grammar`:
   - `generateString(from: Character, currentDepth: Int, maxDepth: Int) -> String`:
     * Recursively generates a random string from a given nonterminal.
   - `generateStrings(count: Int, maxDepth: Int) -> [String]`:
     * Generates a number of random strings from the start symbol.
   - `classifyChomskyHierarchy() -> String`:
     * Performs a *basic* classification of the grammar into Type-0, 1, 2, or 3 based on certain rule patterns.

4. **Main.swift**:
   - Builds the automaton from the given variant (#10).
   - Demonstrates the calls to check determinism, convert to DFA, run acceptance checks, convert to grammar, generate `.dot` files, and classify the grammar.



* Code snippets 
### Grammar.swift

```swift
import Foundation


struct Grammar {
    let nonTerminals: Set<Character>
    let terminals: Set<Character>
    let rules: [Character: [String]]
    let startSymbol: Character
    
   
    func generateString(from symbol: Character,
                       currentDepth: Int,
                       maxDepth: Int) -> String {
        // Logging
        Logger.log("Generating string from symbol '\(symbol)', depth: \(currentDepth)", level: .info)
        
        // If we've exceeded max depth, return empty to avoid infinite recursion
        guard currentDepth <= maxDepth else {
            Logger.log("Max depth exceeded, returning empty.", level: .warn)
            return ""
        }
        
        // If the symbol is a terminal, just return it
        if terminals.contains(symbol) {
            Logger.log("Symbol '\(symbol)' is terminal. Returning it.", level: .info)
            return String(symbol)
        }
        
        // Otherwise, pick one of the productions for that non-terminal
        guard let productions = rules[symbol], !productions.isEmpty else {
            Logger.log("No productions found for symbol '\(symbol)', returning empty.", level: .warn)
            return ""
        }
        
        let randomIndex = Int.random(in: 0..<productions.count)
        let chosenProduction = productions[randomIndex]
        
        Logger.log("Chosen production for symbol '\(symbol)': \(chosenProduction)", level: .info)
        
        var result = ""
        for ch in chosenProduction {
            result += generateString(from: ch,
                                     currentDepth: currentDepth + 1,
                                     maxDepth: maxDepth)
        }
        return result
    }
    
    /// Generate `count` random strings from the grammar (starting at `startSymbol`).
    func generateStrings(count: Int, maxDepth: Int = 15) -> [String] {
        Logger.log("Generating \(count) strings from start symbol '\(startSymbol)'...", level: .info)
        var result: [String] = []
        for _ in 0..<count {
            let str = generateString(from: startSymbol,
                                     currentDepth: 0,
                                     maxDepth: maxDepth)
            result.append(str)
        }
        return result
    }
    
    /// Classify the grammar by Chomsky hierarchy (Type-0,1,2,3).
 
    func classifyChomskyHierarchy() -> String {
        Logger.log("Classifying grammar in terms of Chomsky hierarchy...", level: .info)
        
        var isRegular = true
        var isContextFree = true
        var isContextSensitive = true
        
        for (leftSide, rightSides) in rules {
            
            // Left side must be a single non-terminal for Types 2 & 3
            if !nonTerminals.contains(leftSide) {
                return "Invalid Grammar (Left side must be a non-terminal)"
            }
            
            for rightSide in rightSides {
                // If right side is empty => Type-0 (unrestricted)
                if rightSide.isEmpty {
                    return "Type-0 (Unrestricted Grammar)"
                }
                
                // Check unknown symbols in right side
                for ch in rightSide {
                    if !nonTerminals.contains(ch) && !terminals.contains(ch) {
                        return "Invalid Grammar (Unknown symbol in right side)"
                    }
                }
                
                // Context-Sensitive requires |leftSide| <= |rightSide|
                // leftSide is length 1 (a single nonterminal),
                // so if rightSide.count < 1 => not context sensitive
                if rightSide.count < 1 {
                    isContextSensitive = false
                }
                
                // Check linearity for regular grammar
                // Right-linear or left-linear => at most one non-terminal in the production
                var nonTerminalCount = 0
                var nonTerminalPositions: [Int] = []
                let chars = Array(rightSide)
                
                for (i, ch) in chars.enumerated() {
                    if nonTerminals.contains(ch) {
                        nonTerminalCount += 1
                        nonTerminalPositions.append(i)
                    }
                }
                
                // If more than one non-terminal => not regular
                if nonTerminalCount > 1 {
                    isRegular = false
                } else if nonTerminalCount == 1 {
                    // Check position for left-/right- linear
                    let pos = nonTerminalPositions[0]
                    let isRightLinear = (pos == chars.count - 1)
                    let isLeftLinear  = (pos == 0)
                    if !(isRightLinear || isLeftLinear) {
                        isRegular = false
                    }
                }
                
                // If any production has length > 1 with a non-terminal => might break context-free
                // (Following the simplified approach in the Java code.)
                if rightSide.count > 1 && nonTerminalCount > 0 {
                    isContextFree = false
                }
            }
        }
        
        if isRegular {
            return "Type-3 (Regular Grammar)"
        } else if isContextFree {
            return "Type-2 (Context-Free Grammar)"
        } else if isContextSensitive {
            return "Type-1 (Context-Sensitive Grammar)"
        } else {
            return "Type-0 (Unrestricted Grammar)"
        }
    }
}

```


### FiniteAutomaton.swift

```
import Foundation


/// Includes:
/// - A function `accepts(_:)` to check if a string is accepted by the (N)DFA
/// - A function `isDeterministic()` to check if for every state & symbol there's at most 1 next state
/// - A function `toDFA()` to convert an NFA to a DFA (subset construction)
/// - A function `toRegularGrammar()` to build a right-linear grammar from the automaton
/// - A function `toDot()` to generate GraphViz .dot representation
///
struct FiniteAutomaton {
    let states: Set<String>
    let alphabet: Set<Character>
    let transitions: [String: [Character: Set<String>]]
    let initialState: String
    let finalStates: Set<String>
    
    /// Check whether this FA (NFA/DFA) accepts a given input string.
    /// For an NFA, we track all possible current states at once.
    func accepts(_ input: String) -> Bool {
        Logger.log("Running acceptance check for input: \(input)", level: .info)
        var currentStates: Set<String> = [initialState]
        
        for symbol in input {
            Logger.log("Current states: \(currentStates), reading symbol: '\(symbol)'", level: .info)
            if !alphabet.contains(symbol) {
                Logger.log("Symbol '\(symbol)' not in alphabet => rejecting", level: .warn)
                return false
            }
            var nextStates = Set<String>()
            for state in currentStates {
                if let possibleNextStates = transitions[state]?[symbol] {
                    nextStates.formUnion(possibleNextStates)
                }
            }
            currentStates = nextStates
            if currentStates.isEmpty {
                Logger.log("No possible transitions => rejecting", level: .warn)
                return false
            }
        }
        
        let isAccepted = !finalStates.intersection(currentStates).isEmpty
        Logger.log("End states: \(currentStates). Is accepted? \(isAccepted)", level: .info)
        return isAccepted
    }
    
    /// Check if the automaton is deterministic:
    /// For each state and each symbol, there should be *at most one* next state.
    func isDeterministic() -> Bool {
        for (state, transitionMap) in transitions {
            for (symbol, nextStates) in transitionMap {
                if nextStates.count > 1 {
                    Logger.log("Found multiple next states for (\(state), '\(symbol)'): \(nextStates). This is NFA.", level: .info)
                    return false
                }
            }
        }
        return true
    }
    
    /// Convert this NFA to an equivalent DFA using the subset construction.
    /// Returns a new `FiniteAutomaton` that is deterministic.
    func toDFA() -> FiniteAutomaton {
        Logger.log("Converting NFA to DFA via subset construction...", level: .info)
        
        // Start with the initial subset {initialState}
        let startSet: Set<String> = [initialState]
        var queue: [Set<String>] = [startSet]
        var visited: Set<Set<String>> = []
        
        /// Subset -> (symbol -> nextSubset)
        var dfaTransitions: [Set<String>: [Character: Set<String>]] = [:]
        var dfaFinalStates: Set<Set<String>> = []
        
        while !queue.isEmpty {
            let currentSubset = queue.removeFirst()
            
            if visited.contains(currentSubset) {
                continue
            }
            visited.insert(currentSubset)
            
            Logger.log("Processing subset: \(currentSubset)", level: .info)
            
            var transitionMap: [Character: Set<String>] = [:]
            
            for symbol in alphabet {
                var nextSubset = Set<String>()
                for st in currentSubset {
                    if let nextStates = transitions[st]?[symbol] {
                        nextSubset.formUnion(nextStates)
                    }
                }
                if !nextSubset.isEmpty {
                    transitionMap[symbol] = nextSubset
                    Logger.log("On symbol '\(symbol)', next subset: \(nextSubset)", level: .info)
                    if !visited.contains(nextSubset) && !queue.contains(nextSubset) {
                        queue.append(nextSubset)
                    }
                }
            }
            dfaTransitions[currentSubset] = transitionMap
            
            // If any state in currentSubset is final => that subset is final
            if !finalStates.intersection(currentSubset).isEmpty {
                dfaFinalStates.insert(currentSubset)
            }
        }
        
        // Convert sets of states into "named" states for the new DFA
        var subsetNameMap: [Set<String>: String] = [:]
        
        // Name them in some consistent manner
        var idx = 0
        for subset in visited {
            subsetNameMap[subset] = "D\(idx)"
            idx += 1
        }
        
        var newStates = Set<String>()
        var newTransitions: [String: [Character: Set<String>]] = [:]
        var newFinalStates = Set<String>()
        
        for subset in visited {
            let subsetLabel = subsetNameMap[subset]!
            newStates.insert(subsetLabel)
            
            var symbolMap: [Character: Set<String>] = [:]
            if let subsetTransitions = dfaTransitions[subset] {
                for (symbol, toSubset) in subsetTransitions {
                    if let toLabel = subsetNameMap[toSubset] {
                        symbolMap[symbol] = [toLabel]
                    }
                }
            }
            newTransitions[subsetLabel] = symbolMap
            
            // If subset is final => the new subsetLabel is final
            if dfaFinalStates.contains(subset) {
                newFinalStates.insert(subsetLabel)
            }
        }
        
        // The new initialState is the name for startSet
        let newInitialState = subsetNameMap[startSet]!
        
        let dfa = FiniteAutomaton(
            states: newStates,
            alphabet: alphabet,
            transitions: newTransitions,
            initialState: newInitialState,
            finalStates: newFinalStates
        )
        
        Logger.log("DFA constructed. States: \(dfa.states)", level: .info)
        Logger.log("DFA final states: \(dfa.finalStates)", level: .info)
        
        return dfa
    }
    
    /// Convert this FA to a right-linear Grammar.
    /// We'll map each state `qi` to a nonterminal (e.g., S, A, B, C, ...).
    /// For each transition q_i --a--> q_j, add a production:
    ///    NT(q_i) -> a NT(q_j)
    /// If q_j is a final state, also add:
    ///    NT(q_i) -> a
    /// If q_i is final, add an ε-production:
    ///    NT(q_i) -> ε
    func toRegularGrammar() -> Grammar {
        Logger.log("Converting FA to a right-linear grammar...", level: .info)
        
        // Sort the states so we can assign consistent non-terminal labels
        let sortedStates = states.sorted()
        var stateToNonTerminal: [String: Character] = [:]
        
        // We'll try to use capital letters for nonTerminals: S, A, B, C, ...
        var availableLetters = (UnicodeScalar("A").value...UnicodeScalar("Z").value).compactMap { UnicodeScalar($0).map { Character($0) } }
        
        // Force the initial state to use 'S' if possible
        stateToNonTerminal[initialState] = "S"
        availableLetters.removeAll { $0 == "S" }
        
        for st in sortedStates {
            if st == initialState { continue }
            if stateToNonTerminal[st] == nil {
                if let letter = availableLetters.first {
                    stateToNonTerminal[st] = letter
                    availableLetters.removeFirst()
                } else {
                    // Fallback: If we run out of letters, use state name's first letter
                    stateToNonTerminal[st] = Character(st)
                }
            }
        }
        
        // Build production rules
        var rules: [Character: [String]] = [:]
        
        for st in states {
            guard let nt = stateToNonTerminal[st] else { continue }
            rules[nt] = rules[nt] ?? []
            
            // If 'st' is final, add ε production
            if finalStates.contains(st) {
                Logger.log("State \(st) is final => \(nt) -> ε", level: .info)
                rules[nt]?.append("")
            }
            
            // For each symbol in alphabet, add transitions
            if let transitionMap = transitions[st] {
                for symbol in alphabet {
                    if let nextSts = transitionMap[symbol], !nextSts.isEmpty {
                        for ns in nextSts {
                            if let nextNT = stateToNonTerminal[ns] {
                                // Add NT -> symbol nextNT
                                let production = "\(symbol)\(nextNT)"
                                rules[nt]?.append(production)
                                // If ns is final, also add NT -> symbol
                                if finalStates.contains(ns) {
                                    rules[nt]?.append(String(symbol))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // The start symbol is the non-terminal for initialState
        let startSymbol = stateToNonTerminal[initialState] ?? "S"
        
        // NonTerminals: all values from our map
        let nonTerminals = Set(stateToNonTerminal.values)
        let terminals = alphabet
        
        let grammar = Grammar(
            nonTerminals: nonTerminals,
            terminals: terminals,
            rules: rules,
            startSymbol: startSymbol
        )
        
        Logger.log("Right-linear grammar created successfully.", level: .info)
        return grammar
    }
    
    /// Generate a GraphViz DOT representation of the automaton.
    /// You can save it to a file named `fa.dot` and run:
    ///     dot -Tpng fa.dot -o fa.png
    /// to produce a PNG diagram of your automaton.
    func toDot() -> String {
        Logger.log("Generating GraphViz DOT representation of the FA...", level: .info)
        
        // We'll label the initial state with a special arrow using an invisible "start" node
        // We'll put doublecircles around final states.
        
        var dot = "digraph FA {\n"
        dot += "  rankdir=LR;\n"
        dot += "  node [shape = circle];\n"
        
        // Mark final states with double circle
        for f in finalStates {
            dot += "  \"\(f)\" [shape=doublecircle];\n"
        }
        
        // Invisible start node
        dot += "  \"\" [shape=none];\n"
        dot += "  \"\" -> \"\(initialState)\";\n"
        
        // For each transition, draw an edge
        for (state, symbolMap) in transitions {
            for (symbol, nextSet) in symbolMap {
                for nxt in nextSet {
                    dot += "  \"\(state)\" -> \"\(nxt)\" [label=\"\(symbol)\"];\n"
                }
            }
        }
        dot += "}\n"
        return dot
    }
}

```

### Logger.swift

```
import Foundation


struct Logger {
    enum LogLevel: String {
        case info  = "[INFO]"
        case warn  = "[WARN]"
        case error = "[ERROR]"
    }
    
    /// Logs a message to the console with a specified log level.
    static func log(_ message: String, level: LogLevel = .info) {
        print("\(level.rawValue) \(message)")
    }
}

```

### main.swift

```
import Foundation

/// Example "Main" usage file demonstrating:
/// 1. Creation of the NFA for Variant #10
/// 2. Logging
/// 3. Checking determinism
/// 4. Subset construction to convert NFA->DFA
/// 5. Acceptance checks
/// 6. Conversion to right-linear grammar
/// 7. Generating .dot for GraphViz (both NFA and DFA)
/// 8. Generating random strings from the derived grammar

// MARK: - 1) Build the Variant #10 NFA

/// Q = {q0,q1,q2,q3}
/// Σ = {a,b,c}
/// F = {q3}
///
/// δ(q0,a) = q1
/// δ(q0,b) = q2
/// δ(q1,b) = q1, q2  (thus nondeterministic on 'b')
/// δ(q2,c) = q3
/// δ(q3,a) = q1

Logger.log("Building Variant #10 NFA...", level: .info)

let states: Set<String> = ["q0", "q1", "q2", "q3"]
let alphabet: Set<Character> = ["a", "b", "c"]
let initialState = "q0"
let finalStates: Set<String> = ["q3"]

let transitions: [String: [Character: Set<String>]] = [
    "q0": [
        "a": ["q1"],
        "b": ["q2"]
    ],
    "q1": [
        "b": ["q1", "q2"]  // nondeterministic
    ],
    "q2": [
        "c": ["q3"]
    ],
    "q3": [
        "a": ["q1"]
    ]
]

let nfa = FiniteAutomaton(
    states: states,
    alphabet: alphabet,
    transitions: transitions,
    initialState: initialState,
    finalStates: finalStates
)

Logger.log("NFA created. States: \(nfa.states), Final states: \(nfa.finalStates)", level: .info)

// MARK: - 2) Check if it's deterministic
let deterministic = nfa.isDeterministic()
Logger.log("Is the NFA deterministic? \(deterministic)", level: .info)

// MARK: - 3) Convert NFA -> DFA
Logger.log("Converting NFA to DFA...", level: .info)
let dfa = nfa.toDFA()
Logger.log("DFA states: \(dfa.states)", level: .info)
Logger.log("DFA final states: \(dfa.finalStates)", level: .info)
Logger.log("Is the resulting automaton deterministic? \(dfa.isDeterministic())", level: .info)

// MARK: - 4) Acceptance checks
Logger.log("Testing acceptance on sample strings...", level: .info)
let testStrings = ["ab", "abb", "abc", "abca", "abbc", "abcabc", "aba", "abcabca"]
for str in testStrings {
    let acceptedNFA = nfa.accepts(str)
    let acceptedDFA = dfa.accepts(str)
    print("String: \(str) => NFA accepted? \(acceptedNFA), DFA accepted? \(acceptedDFA)")
}

// MARK: - 5) Convert FA to Right-Linear Grammar
Logger.log("Converting NFA to a Right-Linear Grammar...", level: .info)
let grammarFromFA = nfa.toRegularGrammar()
Logger.log("Grammar NonTerminals: \(grammarFromFA.nonTerminals)", level: .info)
Logger.log("Grammar Terminals: \(grammarFromFA.terminals)", level: .info)
Logger.log("Grammar Start Symbol: \(grammarFromFA.startSymbol)", level: .info)
Logger.log("Grammar Production Rules:", level: .info)
for (nt, prods) in grammarFromFA.rules {
    for p in prods {
        let rhs = p.isEmpty ? "ε" : p
        Logger.log("\(nt) -> \(rhs)", level: .info)
    }
}

// MARK: - 6) Classify Grammar
let classification = grammarFromFA.classifyChomskyHierarchy()
Logger.log("Chomsky Hierarchy Classification: \(classification)", level: .info)

// MARK: - 7) Generate .dot for GraphViz

// a) NFA .dot
Logger.log("Generating DOT content for the NFA...", level: .info)
let nfaDot = nfa.toDot()
print("\n--- GraphViz .dot Representation of the NFA ---\n\(nfaDot)")

// b) DFA .dot
Logger.log("Generating DOT content for the DFA...", level: .info)
let dfaDot = dfa.toDot()
print("\n--- GraphViz .dot Representation of the DFA ---\n\(dfaDot)")

// (Optional) Write to files if you want:
// let nfaUrl = URL(fileURLWithPath: "nfa.dot")
// try? nfaDot.write(to: nfaUrl, atomically: true, encoding: .utf8)
// let dfaUrl = URL(fileURLWithPath: "dfa.dot")
// try? dfaDot.write(to: dfaUrl, atomically: true, encoding: .utf8)

// Then run in Terminal:
// dot -Tpng nfa.dot -o nfa.png
// dot -Tpng dfa.dot -o dfa.png

// MARK: - 8) Generate Random Strings from Grammar
Logger.log("Generating random strings from the derived grammar...", level: .info)
let generatedStrings = grammarFromFA.generateStrings(count: 5, maxDepth: 10)
Logger.log("Generated strings:\n\(generatedStrings)", level: .info)

print("\nDone.")

```



### Results after running the program
```
[INFO] Building Variant #10 NFA...
[INFO] NFA created. States: ["q2", "q0", "q1", "q3"], Final states: ["q3"]
[INFO] Found multiple next states for (q1, 'b'): ["q2", "q1"]. This is NFA.
[INFO] Is the NFA deterministic? false
[INFO] Converting NFA to DFA...
[INFO] Converting NFA to DFA via subset construction...
[INFO] Processing subset: ["q0"]
[INFO] On symbol 'a', next subset: ["q1"]
[INFO] On symbol 'b', next subset: ["q2"]
[INFO] Processing subset: ["q1"]
[INFO] On symbol 'b', next subset: ["q1", "q2"]
[INFO] Processing subset: ["q2"]
[INFO] On symbol 'c', next subset: ["q3"]
[INFO] Processing subset: ["q1", "q2"]
[INFO] On symbol 'c', next subset: ["q3"]
[INFO] On symbol 'b', next subset: ["q1", "q2"]
[INFO] Processing subset: ["q3"]
[INFO] On symbol 'a', next subset: ["q1"]
[INFO] DFA constructed. States: ["D2", "D4", "D3", "D0", "D1"]
[INFO] DFA final states: ["D4"]
[INFO] DFA states: ["D2", "D4", "D3", "D0", "D1"]
[INFO] DFA final states: ["D4"]
[INFO] Is the resulting automaton deterministic? true
[INFO] Testing acceptance on sample strings...
[INFO] Running acceptance check for input: ab
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] End states: ["q1", "q2"]. Is accepted? false
[INFO] Running acceptance check for input: ab
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] End states: ["D3"]. Is accepted? false
String: ab => NFA accepted? false, DFA accepted? false
[INFO] Running acceptance check for input: abb
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q1", "q2"], reading symbol: 'b'
[INFO] End states: ["q1", "q2"]. Is accepted? false
[INFO] Running acceptance check for input: abb
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'b'
[INFO] End states: ["D3"]. Is accepted? false
String: abb => NFA accepted? false, DFA accepted? false
[INFO] Running acceptance check for input: abc
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q2", "q1"], reading symbol: 'c'
[INFO] End states: ["q3"]. Is accepted? true
[INFO] Running acceptance check for input: abc
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'c'
[INFO] End states: ["D4"]. Is accepted? true
String: abc => NFA accepted? true, DFA accepted? true
[INFO] Running acceptance check for input: abca
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q2", "q1"], reading symbol: 'c'
[INFO] Current states: ["q3"], reading symbol: 'a'
[INFO] End states: ["q1"]. Is accepted? false
[INFO] Running acceptance check for input: abca
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'c'
[INFO] Current states: ["D4"], reading symbol: 'a'
[INFO] End states: ["D1"]. Is accepted? false
String: abca => NFA accepted? false, DFA accepted? false
[INFO] Running acceptance check for input: abbc
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q2", "q1"], reading symbol: 'b'
[INFO] Current states: ["q1", "q2"], reading symbol: 'c'
[INFO] End states: ["q3"]. Is accepted? true
[INFO] Running acceptance check for input: abbc
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'c'
[INFO] End states: ["D4"]. Is accepted? true
String: abbc => NFA accepted? true, DFA accepted? true
[INFO] Running acceptance check for input: abcabc
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q1", "q2"], reading symbol: 'c'
[INFO] Current states: ["q3"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q1", "q2"], reading symbol: 'c'
[INFO] End states: ["q3"]. Is accepted? true
[INFO] Running acceptance check for input: abcabc
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'c'
[INFO] Current states: ["D4"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'c'
[INFO] End states: ["D4"]. Is accepted? true
String: abcabc => NFA accepted? true, DFA accepted? true
[INFO] Running acceptance check for input: aba
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q1", "q2"], reading symbol: 'a'
[WARN] No possible transitions => rejecting
[INFO] Running acceptance check for input: aba
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'a'
[WARN] No possible transitions => rejecting
String: aba => NFA accepted? false, DFA accepted? false
[INFO] Running acceptance check for input: abcabca
[INFO] Current states: ["q0"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q2", "q1"], reading symbol: 'c'
[INFO] Current states: ["q3"], reading symbol: 'a'
[INFO] Current states: ["q1"], reading symbol: 'b'
[INFO] Current states: ["q2", "q1"], reading symbol: 'c'
[INFO] Current states: ["q3"], reading symbol: 'a'
[INFO] End states: ["q1"]. Is accepted? false
[INFO] Running acceptance check for input: abcabca
[INFO] Current states: ["D0"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'c'
[INFO] Current states: ["D4"], reading symbol: 'a'
[INFO] Current states: ["D1"], reading symbol: 'b'
[INFO] Current states: ["D3"], reading symbol: 'c'
[INFO] Current states: ["D4"], reading symbol: 'a'
[INFO] End states: ["D1"]. Is accepted? false
String: abcabca => NFA accepted? false, DFA accepted? false
[INFO] Converting NFA to a Right-Linear Grammar...
[INFO] Converting FA to a right-linear grammar...
[INFO] State q3 is final => C -> ε
[INFO] Right-linear grammar created successfully.
[INFO] Grammar NonTerminals: ["A", "S", "C", "B"]
[INFO] Grammar Terminals: ["c", "a", "b"]
[INFO] Grammar Start Symbol: S
[INFO] Grammar Production Rules:
[INFO] A -> bB
[INFO] A -> bA
[INFO] C -> ε
[INFO] C -> aA
[INFO] S -> aA
[INFO] S -> bB
[INFO] B -> cC
[INFO] B -> c
[INFO] Classifying grammar in terms of Chomsky hierarchy...
[INFO] Chomsky Hierarchy Classification: Type-0 (Unrestricted Grammar)
[INFO] Generating DOT content for the NFA...
[INFO] Generating GraphViz DOT representation of the FA...

--- GraphViz .dot Representation of the NFA ---
digraph FA {
  rankdir=LR;
  node [shape = circle];
  "q3" [shape=doublecircle];
  "" [shape=none];
  "" -> "q0";
  "q0" -> "q1" [label="a"];
  "q0" -> "q2" [label="b"];
  "q2" -> "q3" [label="c"];
  "q1" -> "q2" [label="b"];
  "q1" -> "q1" [label="b"];
  "q3" -> "q1" [label="a"];
}

[INFO] Generating DOT content for the DFA...
[INFO] Generating GraphViz DOT representation of the FA...

--- GraphViz .dot Representation of the DFA ---
digraph FA {
  rankdir=LR;
  node [shape = circle];
  "D4" [shape=doublecircle];
  "" [shape=none];
  "" -> "D0";
  "D1" -> "D3" [label="b"];
  "D3" -> "D4" [label="c"];
  "D3" -> "D3" [label="b"];
  "D2" -> "D4" [label="c"];
  "D0" -> "D2" [label="b"];
  "D0" -> "D1" [label="a"];
  "D4" -> "D1" [label="a"];
}

[INFO] Generating random strings from the derived grammar...
[INFO] Generating 5 strings from start symbol 'S'...
[INFO] Generating string from symbol 'S', depth: 0
[INFO] Chosen production for symbol 'S': aA
[INFO] Generating string from symbol 'a', depth: 1
[INFO] Symbol 'a' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 1
[INFO] Chosen production for symbol 'A': bB
[INFO] Generating string from symbol 'b', depth: 2
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'B', depth: 2
[INFO] Chosen production for symbol 'B': c
[INFO] Generating string from symbol 'c', depth: 3
[INFO] Symbol 'c' is terminal. Returning it.
[INFO] Generating string from symbol 'S', depth: 0
[INFO] Chosen production for symbol 'S': aA
[INFO] Generating string from symbol 'a', depth: 1
[INFO] Symbol 'a' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 1
[INFO] Chosen production for symbol 'A': bB
[INFO] Generating string from symbol 'b', depth: 2
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'B', depth: 2
[INFO] Chosen production for symbol 'B': c
[INFO] Generating string from symbol 'c', depth: 3
[INFO] Symbol 'c' is terminal. Returning it.
[INFO] Generating string from symbol 'S', depth: 0
[INFO] Chosen production for symbol 'S': aA
[INFO] Generating string from symbol 'a', depth: 1
[INFO] Symbol 'a' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 1
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 2
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 2
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 3
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 3
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 4
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 4
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 5
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 5
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 6
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 6
[INFO] Chosen production for symbol 'A': bB
[INFO] Generating string from symbol 'b', depth: 7
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'B', depth: 7
[INFO] Chosen production for symbol 'B': c
[INFO] Generating string from symbol 'c', depth: 8
[INFO] Symbol 'c' is terminal. Returning it.
[INFO] Generating string from symbol 'S', depth: 0
[INFO] Chosen production for symbol 'S': aA
[INFO] Generating string from symbol 'a', depth: 1
[INFO] Symbol 'a' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 1
[INFO] Chosen production for symbol 'A': bB
[INFO] Generating string from symbol 'b', depth: 2
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'B', depth: 2
[INFO] Chosen production for symbol 'B': cC
[INFO] Generating string from symbol 'c', depth: 3
[INFO] Symbol 'c' is terminal. Returning it.
[INFO] Generating string from symbol 'C', depth: 3
[INFO] Chosen production for symbol 'C': aA
[INFO] Generating string from symbol 'a', depth: 4
[INFO] Symbol 'a' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 4
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 5
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 5
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 6
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 6
[INFO] Chosen production for symbol 'A': bB
[INFO] Generating string from symbol 'b', depth: 7
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'B', depth: 7
[INFO] Chosen production for symbol 'B': c
[INFO] Generating string from symbol 'c', depth: 8
[INFO] Symbol 'c' is terminal. Returning it.
[INFO] Generating string from symbol 'S', depth: 0
[INFO] Chosen production for symbol 'S': aA
[INFO] Generating string from symbol 'a', depth: 1
[INFO] Symbol 'a' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 1
[INFO] Chosen production for symbol 'A': bA
[INFO] Generating string from symbol 'b', depth: 2
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'A', depth: 2
[INFO] Chosen production for symbol 'A': bB
[INFO] Generating string from symbol 'b', depth: 3
[INFO] Symbol 'b' is terminal. Returning it.
[INFO] Generating string from symbol 'B', depth: 3
[INFO] Chosen production for symbol 'B': c
[INFO] Generating string from symbol 'c', depth: 4
[INFO] Symbol 'c' is terminal. Returning it.
[INFO] Generated strings:
["abc", "abc", "abbbbbbc", "abcabbbc", "abbc"]

Done.
Program ended with exit code: 0


```




## Conclusions 

This lab exercise effectively showcased the design and operation of a finite automaton built from a regular grammar. The Grammar class generated strings adhering to the defined production rules, while the FiniteAutomaton class evaluated these strings to verify their acceptance. Additionally, the conversion process from a regular grammar to a finite automaton was implemented, confirming the theoretical equivalence between the two. Comprehensive testing with various input strings further reinforced the understanding of how finite automata process inputs to determine language acceptance.








