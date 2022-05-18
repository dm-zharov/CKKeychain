//
//  ItemClass.swift
//  
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

import Foundation

public enum ItemClass {
    /// Application Password
    case genericPassword
    
    /// Web Password
    case internetPassword
    
    case certificate
    
    case key
    
    /// Certificate paired with its associated private key.
    /// Identity is a virtual object. It's more reliable to store certificate and key in keychain separately.
    /// Identity would be retrieved on SecItemCopyMatching only if certificate's `kSecAttrPublicKeyHash` will be matched with private key's `kSecAttrLabel` and `kSecAttrApplicationLabel` values.
    case identity
}

extension ItemClass: RawRepresentable, CustomStringConvertible {
    public init?(rawValue: String) {
        switch rawValue {
        case String(kSecClassGenericPassword):
            self = .genericPassword

        case String(kSecClassInternetPassword):
            self = .internetPassword

        case String(kSecClassCertificate):
            self = .certificate

        case String(kSecClassKey):
            self = .key

        case String(kSecClassIdentity):
            self = .identity

        default:
            return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .genericPassword:
            return String(kSecClassGenericPassword)

        case .internetPassword:
            return String(kSecClassInternetPassword)

        case .certificate:
            return String(kSecClassCertificate)

        case .key:
            return String(kSecClassKey)

        case .identity:
            return String(kSecClassIdentity)
        }
    }

    public var description: String {
        switch self {
        case .genericPassword:
            return "GenericPassword"
        case .internetPassword:
            return "InternetPassword"
        case .certificate:
            return "Certificate"
        case .key:
            return "Key"
        case .identity:
            return "Identity"
        }
    }
}
