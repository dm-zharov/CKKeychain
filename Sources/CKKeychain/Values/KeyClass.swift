//
//  File.swift
//  
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

import Foundation

public enum KeyClass {
    case `public`
    case `private`
    case symmetric
}

extension KeyClass: RawRepresentable, CustomStringConvertible {
    public init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrKeyClassPublic):
            self = .public

        case String(kSecAttrKeyClassPrivate):
            self = .private

        case String(kSecAttrKeyClassSymmetric):
            self = .symmetric

        default:
            return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .public:
            return String(kSecAttrKeyClassPublic)

        case .private:
            return String(kSecAttrKeyClassPrivate)

        case .symmetric:
            return String(kSecAttrKeyClassSymmetric)
        }
    }

    public var description: String {
        switch self {
        case .public:
            return "Public"
        case .private:
            return "Private"
        case .symmetric:
            return "Symmetric"
        }
    }
}
