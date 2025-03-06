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
