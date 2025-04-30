//
//  Grammar.swift
//  Lab5


import Foundation

/// Context-free grammar helper that can convert itself to CNF.
final class Grammar {

    // MARK: Stored data
    private(set) var nonTerminals: [String]
    private(set) var terminals   : [String]
    private var rules            : [String:[String]]
    private let start            : String
    private let EPSILON = "ε"

    // MARK: Init
    init(nonTerminals: [String],
         terminals   : [String],
         rules       : [String:[String]],
         start       : String)
    {
        self.nonTerminals = nonTerminals
        self.terminals    = terminals
        self.rules        = rules.mapValues { Array($0) }
        self.start        = start
    }

    // MARK: Printing
    func printRules() {
        for nt in nonTerminals {
            guard let prods = rules[nt] else { continue }
            print("\(nt) → \(prods.joined(separator: " | "))")
        }
    }

    // MARK: CNF test
    func isCNF() -> Bool {
        for prods in rules.values {
            for p in prods {
                switch p.count {
                case 1: if !terminals.contains(p) { return false }
                case 2:
                    for ch in p where terminals.contains(String(ch)) { return false }
                default: return false
                }
            }
        }
        return true
    }

    // MARK: ε-elimination
    func eliminateEpsilonProductions() {
        var nullable = Set<String>()
        for nt in nonTerminals where rules[nt]?.contains(EPSILON) == true { nullable.insert(nt) }

        var changed = true
        while changed {
            changed = false
            for nt in nonTerminals where !nullable.contains(nt) {
                for prod in rules[nt] ?? [] where prod.allSatisfy({ nullable.contains(String($0)) }) {
                    nullable.insert(nt); changed = true; break
                }
            }
        }

        var newRules = [String:[String]]()
        for nt in nonTerminals {
            var newProds = [String]()
            for prod in rules[nt] ?? [] where prod != EPSILON {
                newProds.append(contentsOf: expandNullable(prod, nullableSet: nullable))
            }
            newRules[nt] = Array(Set(newProds))
        }
        rules = newRules
    }

    private func expandNullable(_ prod: String, nullableSet: Set<String>) -> [String] {
        var expansions = [""]
        for ch in prod {
            let sym = String(ch)
            var next = [String]()
            for partial in expansions {
                next.append(partial + sym)
                if nullableSet.contains(sym) { next.append(partial) }
            }
            expansions = next
        }
        return expansions.filter { !$0.isEmpty }
    }

    // MARK: unit-production elimination
    func eliminateRenaming() {
        var changed = true
        while changed {
            changed = false
            for nt in nonTerminals {
                var units = [String]()
                for p in rules[nt] ?? [] where nonTerminals.contains(p) { units.append(p) }
                for u in units {
                    if let set = rules[u] {
                        rules[nt]?.append(contentsOf: set)
                        rules[nt] = Array(Set(rules[nt]!)).filter { $0 != u }
                        changed = true
                    }
                }
                rules[nt] = rules[nt]?.filter { !nonTerminals.contains($0) }
            }
        }
    }

    // MARK: remove inaccessible
    func eliminateInaccessibleSymbols() {
        var accessible: Set<String> = [start]
        var changed = true
        while changed {
            changed = false
            for nt in accessible {
                for p in rules[nt] ?? [] {
                    for ch in p where nonTerminals.contains(String(ch)) && !accessible.contains(String(ch)) {
                        accessible.insert(String(ch)); changed = true
                    }
                }
            }
        }
        nonTerminals = nonTerminals.filter { accessible.contains($0) }
        rules = rules.filter { accessible.contains($0.key) }
    }

    // MARK: remove non-productive
    func eliminateNonProductiveSymbols() {
        var productive = Set<String>()
        var changed = true
        while changed {
            changed = false
            for nt in nonTerminals where !productive.contains(nt) {
                outer: for p in rules[nt] ?? [] {
                    for ch in p where !terminals.contains(String(ch)) && !productive.contains(String(ch)) {
                        continue outer
                    }
                    productive.insert(nt); changed = true; break
                }
            }
        }
        nonTerminals = nonTerminals.filter { productive.contains($0) }
        rules = rules.compactMapValues { ps in
            ps.filter { p in p.allSatisfy { ch in
                terminals.contains(String(ch)) || productive.contains(String(ch))
            }}
        }.filter { productive.contains($0.key) }
    }

    // MARK: helper for new symbols
    private func createNewNonTerminal() -> String {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789αβγδζηθικλμνξοπρστυφχψω"
        for ch in alphabet where !nonTerminals.contains(String(ch)) {
            nonTerminals.append(String(ch)); return String(ch)
        }
        var idx = 0
        while true {
            let cand = "N\(idx)"
            if !nonTerminals.contains(cand) { nonTerminals.append(cand); return cand }
            idx += 1
        }
    }

    // MARK: full conversion
    func toCNF(printSteps: Bool = false) {

        guard !isCNF() else { return }

        // ① ε
        eliminateEpsilonProductions()
        if printSteps { print("① ε-removed"); printRules(); print() }

        // ② unit
        eliminateRenaming()
        if printSteps { print("② unit-removed"); printRules(); print() }

        // ③ inaccessible
        eliminateInaccessibleSymbols()
        if printSteps { print("③ inaccessible-removed"); printRules(); print() }

        // ④ non-productive
        eliminateNonProductiveSymbols()
        if printSteps { print("④ non-productive-removed"); printRules(); print() }

        // ⑤ binarise + de-terminalise
        var rhs2nt = [String:String]()
        var newRules = [String:Set<String>]()
        for nt in nonTerminals { newRules[nt] = [] }

        for (nt, prods) in rules {
            for var p in prods {
                while p.count > 2 {
                    let head = String(p.prefix(2))
                    let v = rhs2nt[head] ?? {
                        let x = createNewNonTerminal()
                        rhs2nt[head] = x
                        newRules[x] = [head]
                        return x
                    }()
                    p = v + p.dropFirst(2)
                }
                newRules[nt]?.insert(p)
            }
        }

        // replace terminals in length-2
        for nt in nonTerminals {
            guard var set = newRules[nt] else { continue }
            for p in set where p.count == 2 {
                var np = ""
                var changed = false
                for ch in p {
                    let s = String(ch)
                    if terminals.contains(s) {
                        let v = rhs2nt[s] ?? {
                            let x = createNewNonTerminal()
                            rhs2nt[s] = x
                            newRules[x] = [s]
                            return x
                        }()
                        np += v; changed = true
                    } else { np += s }
                }
                if changed { set.remove(p); set.insert(np) }
            }
            newRules[nt] = set
        }

        rules = newRules.mapValues { Array($0) }.filter { !$0.value.isEmpty }

        // **extra final cleanup**
        eliminateInaccessibleSymbols()
        eliminateNonProductiveSymbols()

        if printSteps { print("⑤ final CNF"); printRules(); print() }
    }
}
