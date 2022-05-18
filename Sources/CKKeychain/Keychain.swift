//
//  Keychain.swift
//
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

import Foundation
import Security
#if os(iOS) || os(macOS)
import LocalAuthentication
#endif

public let KeychainErrorDomain = "Keychain.error"

public final class Keychain {
    public var itemClass: ItemClass {
        return options.itemClass
    }
    
    // This attribute (kSecAttrAccessGroup) applies to macOS keychain items only if you also set a value of true for the
    // kSecUseDataProtectionKeychain key, the kSecAttrSynchronizable key, or both.
    public var accessGroup: String? {
        return options.accessGroup
    }
    
    public var accessibility: Accessibility {
        return options.accessibility
    }

    @available(iOS 8.0, macOS 10.10, *)
    @available(watchOS, unavailable)
    public var authenticationPolicy: AuthenticationPolicy? {
        return options.authenticationPolicy
    }
    
    public var useDataProtectionKeychain: Bool {
        return options.useDataProtectionKeychain
    }

    public var synchronizable: Bool {
        return options.synchronizable
    }
    
    public var label: String? {
        return options.label
    }

    public var comment: String? {
        return options.comment
    }
    
    // MARK: Generic Password

    public var service: String {
        return options.service
    }
    
    // MARK: Internet Password

    public var server: URL {
        return options.server
    }

    public var protocolType: ProtocolType {
        return options.protocolType
    }
    
    // MARK: -

    public var authenticationType: AuthenticationType {
        return options.authenticationType
    }

    public var authenticationUI: AuthenticationUI? {
        return options.authenticationUI
    }

    #if os(iOS) || os(macOS)
    public var authenticationContext: LAContext? {
        return options.authenticationContext as? LAContext
    }
    #endif
    
    public convenience init(itemClass: ItemClass) {
        var options = Options()
        options.itemClass = itemClass
        self.init(options)
    }

    private let options: Options
    
    private init(_ opts: Options) {
        options = opts
    }
}

// MARK: - Generic Password
extension Keychain {
    public static func genericPassword() -> Keychain {
        var options = Options()
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            options.service = bundleIdentifier
        }
        return self.init(options)
    }

    public static func genericPassword(service: String) -> Keychain {
        var options = Options()
        options.service = service
        return self.init(options)
    }

    public static func genericPassword(accessGroup: String) -> Keychain {
        var options = Options()
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            options.service = bundleIdentifier
        }
        options.accessGroup = accessGroup
        return self.init(options)
    }

    public static func genericPassword(service: String, accessGroup: String) -> Keychain {
        var options = Options()
        options.service = service
        options.accessGroup = accessGroup
        return self.init(options)
    }
}
    
// MARK: - Internet Password
extension Keychain {
    public static func internetPassword(server: String,
                                        protocolType: ProtocolType = .https,
                                        accessGroup: String? = nil,
                                        authenticationType: AuthenticationType = .default) -> Keychain {
        internetPassword(
            server: URL(string: server)!,
            protocolType: protocolType,
            accessGroup: accessGroup,
            authenticationType: authenticationType
        )
    }

    public static func internetPassword(server: URL,
                                        protocolType: ProtocolType = .https,
                                        accessGroup: String? = nil,
                                        authenticationType: AuthenticationType = .default) -> Keychain {
        var options = Options()
        options.itemClass = .internetPassword
        options.server = server
        options.protocolType = protocolType
        options.accessGroup = accessGroup
        options.authenticationType = authenticationType
        return self.init(options)
    }
}

// MARK: - Key
extension Keychain {
    public static func key(keyClass: KeyClass, keyType: KeyType) -> Keychain {
        var options = Options()
        options.itemClass = .key
        options.attributes[AttributeKeyType] = keyType.rawValue
        return self.init(options)
    }
}

// MARK: - Certificate
extension Keychain {
    public static func certificate() -> Keychain {
        var options = Options()
        options.itemClass = .certificate
        return self.init(options)
    }
}

// MARK: - Modifiers
extension Keychain {
    public func accessibility(_ accessibility: Accessibility) -> Keychain {
        var options = self.options
        options.accessibility = accessibility
        return Keychain(options)
    }

    @available(iOS 8.0, macOS 10.10, *)
    @available(watchOS, unavailable)
    public func accessibility(_ accessibility: Accessibility, authenticationPolicy: AuthenticationPolicy) -> Keychain {
        var options = self.options
        options.accessibility = accessibility
        options.authenticationPolicy = authenticationPolicy
        return Keychain(options)
    }
    
    public func useDataProtectionKeychain(_ useDataProtectionKeychain: Bool) -> Keychain {
        var options = self.options
        options.useDataProtectionKeychain = useDataProtectionKeychain
        return Keychain(options)
    }

    public func synchronizable(_ synchronizable: Bool) -> Keychain {
        var options = self.options
        options.synchronizable = synchronizable
        return Keychain(options)
    }

    public func label(_ label: String) -> Keychain {
        var options = self.options
        options.label = label
        return Keychain(options)
    }
    
    public func applicationLabel(_ applicationLabel: String) -> Keychain {
        var options = self.options
        options.applicationLabel = applicationLabel
        return Keychain(options)
    }

    public func comment(_ comment: String) -> Keychain {
        var options = self.options
        options.comment = comment
        return Keychain(options)
    }

    public func attributes(_ attributes: [String: Any]) -> Keychain {
        var options = self.options
        attributes.forEach { options.attributes.updateValue($1, forKey: $0) }
        return Keychain(options)
    }

    public func authenticationUI(_ authenticationUI: AuthenticationUI) -> Keychain {
        var options = self.options
        options.authenticationUI = authenticationUI
        return Keychain(options)
    }

    #if os(iOS) || os(macOS)
    public func authenticationContext(_ authenticationContext: LAContext) -> Keychain {
        var options = self.options
        options.authenticationContext = authenticationContext
        return Keychain(options)
    }
    #endif
}

// MARK: - Operations
extension Keychain {
    // MARK: Reading
    
    public func get(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> String? {
        return try getString(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }

    public func getString(_ key: String? = nil, ignoringAttributeSynchronizable: Bool = true) throws -> String? {
        guard let data = try getData(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable) else {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            print("failed to convert data to string")
            throw Status.conversionError
        }
        return string
    }

    public func getData(_ key: String? = nil, ignoringAttributeSynchronizable: Bool = true) throws -> Data? {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)

        query[MatchLimit] = MatchLimitOne
        query[ReturnData] = kCFBooleanTrue

        if [.genericPassword, .internetPassword].contains(options.itemClass) {
            query[AttributeAccount] = key
        } else if key != nil {
            throw Status.badReq
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw Status.unexpectedError
            }
            return data

        case errSecItemNotFound:
            return nil

        default:
            throw securityError(status: status)
        }
    }

    public func get<T>(_ key: String? = nil, ignoringAttributeSynchronizable: Bool = true, handler: (Attributes?) -> T) throws -> T {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)

        query[MatchLimit] = MatchLimitOne
    
        query[ReturnData] = true
        query[ReturnRef] = true
        query[ReturnPersistentRef] = true
        
        query[ReturnAttributes] = true

        if [.genericPassword, .internetPassword].contains(options.itemClass) {
            query[AttributeAccount] = key
        } else if key != nil {
            throw Status.badReq
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let attributes = result as? [String: Any] else {
                throw Status.unexpectedError
            }
            return handler(Attributes(attributes: attributes))

        case errSecItemNotFound:
            return handler(nil)

        default:
            throw securityError(status: status)
        }
    }

    // MARK: Writing

    public func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            print("failed to convert string to data")
            throw Status.conversionError
        }
        try set(data, key: key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }

    public func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
        
        if [.genericPassword, .internetPassword].contains(options.itemClass) {
            query[AttributeAccount] = key
        }
        
        if let authenticationUI = options.authenticationUI {
            query[UseAuthenticationUI] = authenticationUI.rawValue
        }

        var result: AnyObject?
        var status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            var query = options.query()
            if [.genericPassword, .internetPassword].contains(itemClass) {
                query[AttributeAccount] = key
            }

            var (attributes, error) = options.attributes(key: nil, value: value)
            if let error = error {
                print(error.localizedDescription)
                throw error
            }

            options.attributes.forEach { attributes.updateValue($1, forKey: $0) }
            
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if status != errSecSuccess {
                throw securityError(status: status)
            }

        case errSecItemNotFound:
            var (attributes, error) = options.attributes(key: key, value: value)
            if let error = error {
                print(error.localizedDescription)
                throw error
            }

            options.attributes.forEach { attributes.updateValue($1, forKey: $0) }

            status = SecItemAdd(attributes as CFDictionary, nil)
            if status != errSecSuccess {
                throw securityError(status: status)
            }

        default:
            throw securityError(status: status)
        }
    }
    
    public func setPersistentValue(_ value: Any, key: String, ignoringAttributeSynchronizable: Bool = true) throws -> Data? {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
        
        if [.genericPassword, .internetPassword].contains(itemClass) {
            throw Status.badReq
        }
        
        #if os(iOS) || os(macOS)
        if let authenticationUI = options.authenticationUI {
            query[UseAuthenticationUI] = authenticationUI.rawValue
        }
        #endif

        var (attributes, error) = options.attributes(key: key, value: value)
        if let error = error {
            print(error.localizedDescription)
            throw error
        }

        options.attributes.forEach { attributes.updateValue($1, forKey: $0) }

        var result: AnyObject?
        let status = SecItemAdd(attributes as CFDictionary, &result)
        
        if status != errSecSuccess || result == nil {
            throw securityError(status: status)
        }
        
        return result as? Data
    }

    public subscript(key: String) -> String? {
        get {
            #if swift(>=5.0)
            return try? get(key)
            #else
            return (try? get(key)).flatMap { $0 }
            #endif
        }

        set {
            if let value = newValue {
                do {
                    try set(value, key: key)
                } catch {}
            } else {
                do {
                    try remove(key)
                } catch {}
            }
        }
    }

    public subscript(string key: String) -> String? {
        get {
            return self[key]
        }
        set {
            self[key] = newValue
        }
    }

    public subscript(data key: String) -> Data? {
        get {
            return try? getData(key)
        }
        set {
            if let value = newValue {
                do {
                    try set(value, key: key)
                } catch {}
            } else {
                do {
                    try remove(key)
                } catch {}
            }
        }
    }

    public subscript(attributes key: String) -> Attributes? {
        get {
            return try? get(key) { $0 }
        }
    }

    // MARK: Removing

    public func remove(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
        if [.genericPassword, .internetPassword].contains(options.itemClass) {
            query[AttributeAccount] = key
        }

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw securityError(status: status)
        }
    }

    public func removeAll() throws {
        var query = options.query()
        #if !os(iOS) && !os(watchOS) && !os(tvOS)
        query[MatchLimit] = MatchLimitAll
        #endif

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw securityError(status: status)
        }
    }

    // MARK: 

    public func contains(_ key: String, withoutAuthenticationUI: Bool = false) throws -> Bool {
        var query = options.query()
        if [.genericPassword, .internetPassword].contains(options.itemClass) {
            query[AttributeAccount] = key
        }

        if withoutAuthenticationUI {
            if let authenticationUI = options.authenticationUI {
                query[UseAuthenticationUI] = authenticationUI.rawValue
            }
        } else {
            if let authenticationUI = options.authenticationUI {
                query[UseAuthenticationUI] = authenticationUI.rawValue
            }
        }
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
                return true

        case errSecInteractionNotAllowed:
            if withoutAuthenticationUI {
                return true
            }
            return false

        case errSecItemNotFound:
            return false

        default:
            throw securityError(status: status)
        }
    }

    // MARK: 

    public class func allKeys(_ itemClass: ItemClass) -> [(String, String)] {
        var query = [String: Any]()
        query[Class] = itemClass.rawValue
        query[AttributeSynchronizable] = SynchronizableAny
        query[MatchLimit] = MatchLimitAll
        query[ReturnAttributes] = kCFBooleanTrue

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            if let items = result as? [[String: Any]] {
                return prettify(itemClass: itemClass, items: items).map {
                    switch itemClass {
                    case .certificate, .key, .identity:
                        fallthrough

                    case .genericPassword:
                        return (($0["service"] ?? "") as! String, ($0["key"] ?? "") as! String)

                    case .internetPassword:
                        return (($0["server"] ?? "") as! String, ($0["key"] ?? "") as! String)
                    }
                }
            }

        case errSecItemNotFound:
            return []
        default: ()
        }

        securityError(status: status)
        return []
    }

    public func allKeys() -> [String] {
        let allItems = type(of: self).prettify(itemClass: itemClass, items: items())
        let filter: ([String: Any]) -> String? = { $0["key"] as? String }

        return allItems.compactMap(filter)
    }

    public class func allItems(_ itemClass: ItemClass) -> [[String: Any]] {
        var query = [String: Any]()
        query[Class] = itemClass.rawValue
        query[MatchLimit] = MatchLimitAll
        query[ReturnAttributes] = true
        #if os(iOS) || os(watchOS) || os(tvOS)
        query[ReturnData] = true
        #endif

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            if let items = result as? [[String: Any]] {
                return prettify(itemClass: itemClass, items: items)
            }

        case errSecItemNotFound:
            return []
        default: ()
        }

        securityError(status: status)
        return []
    }

    public func allItems() -> [[String: Any]] {
        return type(of: self).prettify(itemClass: itemClass, items: items())
    }
}

// MARK: - Shared Credentials
extension Keychain {
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public func getSharedPassword(_ completion: @escaping (_ account: String?, _ password: String?, _ error: Error?) -> Void = { account, password, error -> Void in }) {
        if let domain = server.host {
            type(of: self).requestSharedWebCredential(domain: domain, account: nil) { credentials, error -> Void in
                if let credential = credentials.first {
                    let account = credential["account"]
                    let password = credential["password"]
                    completion(account, password, error)
                } else {
                    completion(nil, nil, error)
                }
            }
        } else {
            let error = securityError(status: Status.param.rawValue)
            completion(nil, nil, error)
        }
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    public func getSharedPassword(_ account: String, completion: @escaping (_ password: String?, _ error: Error?) -> Void = { password, error -> Void in }) {
        if let domain = server.host {
            type(of: self).requestSharedWebCredential(domain: domain, account: account) { credentials, error -> Void in
                if let credential = credentials.first {
                    if let password = credential["password"] {
                        completion(password, error)
                    } else {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, error)
                }
            }
        } else {
            let error = securityError(status: Status.param.rawValue)
            completion(nil, error)
        }
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    public func setSharedPassword(_ password: String, account: String, completion: @escaping (_ error: Error?) -> Void = { e -> Void in }) {
        setSharedPassword(password as String?, account: account, completion: completion)
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    fileprivate func setSharedPassword(_ password: String?, account: String, completion: @escaping (_ error: Error?) -> Void = { e -> Void in }) {
        if let domain = server.host {
            SecAddSharedWebCredential(domain as CFString, account as CFString, password as CFString?) { error -> Void in
                if let error = error {
                    completion(error.error)
                } else {
                    completion(nil)
                }
            }
        } else {
            let error = securityError(status: Status.param.rawValue)
            completion(error)
        }
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    public func removeSharedPassword(_ account: String, completion: @escaping (_ error: Error?) -> Void = { e -> Void in }) {
        setSharedPassword(nil, account: account, completion: completion)
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    public class func requestSharedWebCredential(_ completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> Void = { credentials, error -> Void in }) {
        requestSharedWebCredential(domain: nil, account: nil, completion: completion)
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    public class func requestSharedWebCredential(domain: String, completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> Void = { credentials, error -> Void in }) {
        requestSharedWebCredential(domain: domain, account: nil, completion: completion)
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    public class func requestSharedWebCredential(domain: String,
                                                 account: String,
                                                 completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> Void = { credentials, error -> Void in }) {
        requestSharedWebCredential(domain: Optional(domain), account: Optional(account)!, completion: completion)
    }
    #endif

    #if os(iOS) && !targetEnvironment(macCatalyst)
    fileprivate class func requestSharedWebCredential(domain: String?, account: String?, completion: @escaping (_ credentials: [[String: String]], _ error: Error?) -> Void) {
        SecRequestSharedWebCredential(domain as CFString?, account as CFString?) { credentials, error -> Void in
            var remoteError: NSError?
            if let error = error {
                remoteError = error.error
                if remoteError?.code != Int(errSecItemNotFound) {
                    print("error:[\(remoteError!.code)] \(remoteError!.localizedDescription)")
                }
            }
            if let credentials = credentials {
                let credentials = (credentials as NSArray).map { credentials -> [String: String] in
                    var credential = [String: String]()
                    if let credentials = credentials as? [String: String] {
                        if let server = credentials[AttributeServer] {
                            credential["server"] = server
                        }
                        if let account = credentials[AttributeAccount] {
                            credential["account"] = account
                        }
                        if let password = credentials[SharedPassword] {
                            credential["password"] = password
                        }
                    }
                    return credential
                }
                completion(credentials, remoteError)
            } else {
                completion([], remoteError)
            }
        }
    }
    #endif
}

// MARK: - Generator
extension Keychain {
    #if os(iOS) && !targetEnvironment(macCatalyst)
    /**
     @abstract Returns a randomly generated password.
     @return String in the form xxx-xxx-xxx-xxx where x from the sets "abcdefghkmnopqrstuvwxy", "ABCDEFGHJKLMNPQRSTUVWXYZ", "3456789" with at least one character from each set being present.
     */
    public class func generatePassword() -> String {
        return SecCreateSharedWebCredentialPassword()! as String
    }
    #endif
}

// MARK: -
extension Keychain {
    fileprivate func items() -> [[String: Any]] {
        var query = options.query()
        query[MatchLimit] = MatchLimitAll
        query[ReturnAttributes] = kCFBooleanTrue
        #if os(iOS) || os(watchOS) || os(tvOS)
        query[ReturnData] = kCFBooleanTrue
        #endif

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            if let items = result as? [[String: Any]] {
                return items
            }

        case errSecItemNotFound:
            return []
        default: ()
        }

        securityError(status: status)
        return []
    }

    fileprivate class func prettify(itemClass: ItemClass, items: [[String: Any]]) -> [[String: Any]] {
        let items = items.map { attributes -> [String: Any] in
            var item = [String: Any]()

            item["class"] = itemClass.description
            
            if let accessGroup = attributes[AttributeAccessGroup] as? String {
                item["accessGroup"] = accessGroup
            }

            switch itemClass {
            case .genericPassword:
                if let service = attributes[AttributeService] as? String {
                    item["service"] = service
                }

            case .internetPassword:
                if let server = attributes[AttributeServer] as? String {
                    item["server"] = server
                }
                if let proto = attributes[AttributeProtocol] as? String {
                    if let protocolType = ProtocolType(rawValue: proto) {
                        item["protocol"] = protocolType.description
                    }
                }
                if let auth = attributes[AttributeAuthenticationType] as? String {
                    if let authenticationType = AuthenticationType(rawValue: auth) {
                        item["authenticationType"] = authenticationType.description
                    }
                }

            case .certificate:
                break

            case .key:
                break

            case .identity:
                break
            }

            if let key = attributes[AttributeAccount] as? String {
                item["key"] = key
            }
            if let data = attributes[ValueData] as? Data {
                if let text = String(data: data, encoding: .utf8) {
                    item["value"] = text
                } else {
                    item["value"] = data
                }
            }

            if let accessible = attributes[AttributeAccessible] as? String {
                if let accessibility = Accessibility(rawValue: accessible) {
                    item["accessibility"] = accessibility.description
                }
            }
            if let synchronizable = attributes[AttributeSynchronizable] as? Bool {
                item["synchronizable"] = synchronizable ? "true" : "false"
            }

            return item
        }
        return items
    }

    // MARK: 

    @discardableResult
    fileprivate class func securityError(status: OSStatus) -> Error {
        let error = Status(status: status)
        if error != .userCanceled {
            print("OSStatus error:[\(error.errorCode)] \(error.description)")
        }

        return error
    }

    @discardableResult
    fileprivate func securityError(status: OSStatus) -> Error {
        return type(of: self).securityError(status: status)
    }
}

extension Keychain: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let items = allItems()
        if items.isEmpty {
            return "[]"
        }
        var description = "[\n"
        for item in items {
            description += "  "
            description += "\(item)\n"
        }
        description += "]"
        return description
    }

    public var debugDescription: String {
        return "\(items())"
    }
}
