import Foundation

public struct SupabaseConfig {
    public let url: URL
    public let anonKey: String

    public init(url: URL, anonKey: String) {
        self.url = url
        self.anonKey = anonKey
    }

    public static func load(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        bundle: Bundle = .main
    ) throws -> SupabaseConfig {
        let envURL = environment["SUPABASE_URL"].flatMap(URL.init(string:))
        let envKey = environment["SUPABASE_ANON_KEY"]

        let plistURL = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        let plistKey = bundle.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String

        guard let url = envURL ?? plistURL.flatMap(URL.init(string:)) else {
            throw AppError.configuration("SUPABASE_URL is missing or malformed.")
        }

        guard let anonKey = envKey ?? plistKey, !anonKey.isEmpty else {
            throw AppError.configuration("SUPABASE_ANON_KEY is missing.")
        }

        return SupabaseConfig(url: url, anonKey: anonKey)
    }
}
