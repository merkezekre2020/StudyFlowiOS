import Foundation

public enum AppError: LocalizedError, Equatable {
    case configuration(String)
    case authentication(String)
    case authorization(String)
    case validation(String)
    case storage(String)
    case network(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .configuration(let message),
             .authentication(let message),
             .authorization(let message),
             .validation(let message),
             .storage(let message),
             .network(let message),
             .unknown(let message):
            return message
        }
    }

    public static func map(_ error: Error) -> AppError {
        let message = (error as NSError).localizedDescription
        let lowercased = message.lowercased()

        if lowercased.contains("invalid login") || lowercased.contains("invalid credentials") {
            return .authentication("Invalid email or password.")
        }

        if lowercased.contains("email not confirmed") {
            return .authentication("Please confirm your email before signing in.")
        }

        if lowercased.contains("jwt") || lowercased.contains("not authorized") || lowercased.contains("permission") {
            return .authorization("You are not authorized for this action.")
        }

        if lowercased.contains("network") || lowercased.contains("offline") {
            return .network("Network connection issue. Please try again.")
        }

        if lowercased.contains("duplicate") || lowercased.contains("already exists") {
            return .validation("This record already exists.")
        }

        return .unknown(message)
    }
}
