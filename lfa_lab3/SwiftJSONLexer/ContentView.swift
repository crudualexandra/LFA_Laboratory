import SwiftUI

extension UIApplication {
    // Allows dismissal of keyboard from anywhere
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @State private var jsonInput: String = """
{
  "name": "Miriam",
  "age": 32,
  "isMale": false,
  "scores": [95, 82, 88],
  "address": null,
  "isStudent": true
}
"""
    
    @State private var tokens: [Token] = []
    
    var body: some View {
        // 1) Put entire screen inside a ScrollView
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                Text("JSON Lexer")
                    .font(.title)
                    .padding(.top)
                
                Text(
    """
    Guide: Enter valid JSON data below (objects, arrays, strings, numbers, booleans, null). Then tap outside the editor or the 'Tokenize' button to dismiss keyboard.

    Example:
    {
      "name": "Miriam",
      "age": 32,
      "isMale": false,
      "scores": [95, 82, 88],
      "address": null,
      "isStudent": true
    }
    """
                )
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                
                // 2) A TextEditor for JSON input
                TextEditor(text: $jsonInput)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 180)
                    .border(Color.gray, width: 1)
                    .padding(.horizontal)
                
                // 3) Tokenize button
                Button("Tokenize") {
                    let lexer = JSONLexer(input: jsonInput)
                    tokens = lexer.tokenize()
                    UIApplication.shared.endEditing() // also hide keyboard on tap
                }
                .foregroundColor(.blue)
                .padding(.horizontal)
                
                // 4) List the tokens
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(tokens.indices, id: \.self) { i in
                            let token = tokens[i]
                            Text(formatToken(token))
                                .font(.system(.footnote, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 180)
                .border(Color.gray.opacity(0.4), width: 1)
                .padding(.horizontal)
                
                Text("Colored Preview:")
                    .bold()
                    .padding(.horizontal)
                
                // 5) The colorized preview of the JSON
                ScrollView {
                    colorizedText(jsonInput, tokens: tokens)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(maxHeight: 200)
                .border(Color.gray.opacity(0.4), width: 1)
                .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
            .onTapGesture {
                // 6) Tap anywhere in empty space -> hide keyboard
                UIApplication.shared.endEditing()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all)) // optional: dark background
    }
    
    // MARK: - Helpers
    
    /// Produce lines like: `Token(STRING, "Miriam", 11)`
    private func formatToken(_ token: Token) -> String {
        let typeName = "\(token.type)".uppercased()
        return "Token(\(typeName), \(token.value), \(token.position))"
    }
    
    /// Reconstruct colored text from tokens (including whitespace).
    private func colorizedText(_ original: String, tokens: [Token]) -> Text {
        var result = Text("")
        var currentIndex = 0
        
        for token in tokens {
            let start = token.position
            // Add any plain text before this token
            if start > currentIndex {
                let prefixRange = currentIndex ..< start
                let prefixStr = substring(original, in: prefixRange)
                result = result + Text(prefixStr)
            }
            
            // Colorize the token itself
            let tokenStr = token.value
            let coloredSegment = Text(tokenStr)
                .foregroundColor(colorForToken(token.type))
            
            result = result + coloredSegment
            currentIndex = start + tokenStr.count
        }
        
        // Finally, add any remainder text after the last token
        if currentIndex < original.count {
            let suffixStr = substring(original, in: currentIndex ..< original.count)
            result = result + Text(suffixStr)
        }
        
        return result
    }
    
    private func colorForToken(_ type: TokenType) -> Color {
        switch type {
        case .leftBrace, .rightBrace,
             .leftBracket, .rightBracket,
             .colon, .comma:
            return .blue
        case .string:
            return .red
        case .number:
            return .green
        case .boolean:
            return .purple
        case .null:
            return .orange
        case .whitespace:
            return .primary // show whitespace as normal
        case .unknown:
            return .gray
        }
    }
    
    /// Extract a substring by integer Range.
    private func substring(_ s: String, in range: Range<Int>) -> String {
        let start = s.index(s.startIndex, offsetBy: range.lowerBound)
        let end   = s.index(s.startIndex, offsetBy: range.upperBound)
        return String(s[start..<end])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
