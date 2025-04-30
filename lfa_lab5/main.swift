//
//  main.swift
//  Lab5
//
//  Variant 10 example
//

import Foundation

let nonTerminals = ["S","A","B","D"]
let terminals    = ["a","b","d"]

let rules: [String:[String]] = [
    "S": ["dB","AB"],
    "A": ["d","dS","aAaAb","ε"],
    "B": ["a","aS","A"],
    "D": ["Aba"]
]

let g = Grammar(nonTerminals: nonTerminals,
                terminals   : terminals,
                rules       : rules,
                start       : "S")

print("Original grammar:")
g.printRules()

print("\nConverting to CNF:\n")
g.toCNF(printSteps: true)
