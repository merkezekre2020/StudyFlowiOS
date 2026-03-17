import Foundation
import Supabase

#if os(Linux)
import Auth

private final class InMemoryAuthLocalStorage: AuthLocalStorage, @unchecked Sendable {
    private var store: [String: Data] = [:]

    func store(key: String, value: Data) throws {
        store[key] = value
    }

    func retrieve(key: String) throws -> Data? {
        store[key]
    }

    func remove(key: String) throws {
        store.removeValue(forKey: key)
    }
}
#endif

public protocol SupabaseClientProviding {
    var client: SupabaseClient { get }
}

public final class SupabaseClientProvider: SupabaseClientProviding {
    public let client: SupabaseClient

    public init(config: SupabaseConfig) {
        #if os(Linux)
        let options = SupabaseClientOptions(auth: .init(storage: InMemoryAuthLocalStorage()))
        #else
        let options = SupabaseClientOptions()
        #endif

        self.client = SupabaseClient(
            supabaseURL: config.url,
            supabaseKey: config.anonKey,
            options: options
        )
    }

    public static func live() throws -> SupabaseClientProvider {
        try SupabaseClientProvider(config: SupabaseConfig.load())
    }
}
