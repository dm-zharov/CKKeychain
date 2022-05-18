//
//  KeyType.swift
//  
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

import Foundation

public enum KeyType {
    case rsa
    case dsa
    case aes
    case des
    case tdes // 3des
    case rc4
    case rc2
    case cast
    case ecdsa
    case ec
}

extension KeyType: RawRepresentable, CustomStringConvertible {
    public init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrKeyTypeRSA):
            self = .rsa

        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .rsa:
            return String(kSecAttrKeyTypeRSA)

        default:
            fatalError("Unimplemented")
        }
    }
    
    public var description: String {
        switch self {
        case .rsa:
            return "RSA"
        default:
            fatalError("Unimplemented")
        }
    }
}
