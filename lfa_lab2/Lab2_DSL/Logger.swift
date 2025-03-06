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
