// AST+GraphViz.swift
import Foundation

extension JSONValue {
    /// Emits a GraphViz dot‐format description of this AST.
    func graphViz() -> String {
        var dot = "digraph AST {\n  node [shape=box];\n"
        var counter = 0

        func emit(_ value: JSONValue, parent: String?) {
            let myID = "n\(counter)"
            counter += 1

            // label for this node
            let label: String = {
                switch value {
                case .object:   return "{object}"
                case .array:    return "{array}"
                case .string:   return "{string}\\n\"\(value.asString()!)\""
                case .number:   return "{number}\\n\(value.asNumber()!)"
                case .boolean:  return "{boolean}\\n\(value.asBool()!)"
                case .null:     return "{null}"
                }
            }()
            dot += "  \(myID) [label=\"\(label)\"];\n"
            if let p = parent {
                dot += "  \(p) -> \(myID);\n"
            }

            // recurse into children
            switch value {
            case .object(let dict):
                for (key, v) in dict {
                    let keyID = "n\(counter)"; counter += 1
                    dot += "  \(keyID) [label=\"key: \\\"\(key)\\\"\"];\n"
                    dot += "  \(myID) -> \(keyID);\n"
                    emit(v, parent: keyID)
                }
            case .array(let arr):
                for v in arr {
                    emit(v, parent: myID)
                }
            default:
                break
            }
        }

        emit(self, parent: nil)
        dot += "}\n"
        return dot
    }

    fileprivate func asString() -> String? {
        if case .string(let s) = self { return s }
        return nil
    }
    fileprivate func asNumber() -> Double? {
        if case .number(let d) = self { return d }
        return nil
    }
    fileprivate func asBool() -> Bool? {
        if case .boolean(let b) = self { return b }
        return nil
    }
}
