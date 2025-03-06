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
