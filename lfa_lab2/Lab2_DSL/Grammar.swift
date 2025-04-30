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
        
        // pick one of the productions for that non-terminal
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
    
    // Generate `count` random strings from the grammar (starting at `startSymbol`).
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
