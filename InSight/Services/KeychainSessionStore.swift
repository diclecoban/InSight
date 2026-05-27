import Foundation
import Security

struct KeychainSessionStore: SessionPersisting {
    private let service = "com.diclesara.InSight.session"
    private let account = "auth-session"

    func loadSession() -> AuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard
            status == errSecSuccess,
            let data = item as? Data
        else {
            return nil
        }

        return try? JSONDecoder().decode(AuthSession.self, from: data)
    }

    func saveSession(_ session: AuthSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }

        var query = baseQuery
        let attributes = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    func clearSession() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
