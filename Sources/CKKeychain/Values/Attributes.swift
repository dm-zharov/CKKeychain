//
//  Attributes.swift
//  
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

import Foundation

/// General Item Attribute Keys
public struct Attributes {
    public var `class`: String? {
        return attributes[Class] as? String
    }
    public var data: Data? {
        return attributes[ValueData] as? Data
    }
    public var ref: Data? {
        return attributes[ValueRef] as? Data
    }
    public var persistentRef: Data? {
        return attributes[ValuePersistentRef] as? Data
    }

    public var accessControl: SecAccessControl? {
        if let accessControl = attributes[AttributeAccessControl] {
            return (accessControl as! SecAccessControl)
        }
        return nil
    }
    public var accessible: String? {
        return attributes[AttributeAccessible] as? String
    }
    public var accessGroup: String? {
        return attributes[AttributeAccessGroup] as? String
    }
    public var synchronizable: Bool? {
        return attributes[AttributeSynchronizable] as? Bool
    }
    public var creationDate: Date? {
        return attributes[AttributeCreationDate] as? Date
    }
    public var modificationDate: Date? {
        return attributes[AttributeModificationDate] as? Date
    }
    public var attributeDescription: String? {
        return attributes[AttributeDescription] as? String
    }
    public var comment: String? {
        return attributes[AttributeComment] as? String
    }
    public var creator: String? {
        return attributes[AttributeCreator] as? String
    }
    public var type: String? {
        return attributes[AttributeType] as? String
    }
    public var label: String? {
        return attributes[AttributeLabel] as? String
    }
    public var isInvisible: Bool? {
        return attributes[AttributeIsInvisible] as? Bool
    }
    public var isNegative: Bool? {
        return attributes[AttributeIsNegative] as? Bool
    }

    fileprivate let attributes: [String: Any]

    init(attributes: [String: Any]) {
        self.attributes = attributes
    }

    public subscript(key: String) -> Any? {
        get {
            return attributes[key]
        }
    }
}

/// Password Attribute Keys
extension Attributes {
    public var account: String? {
        return attributes[AttributeAccount] as? String
    }
    public var service: String? {
        return attributes[AttributeService] as? String
    }
    public var generic: Data? {
        return attributes[AttributeGeneric] as? Data
    }
    public var securityDomain: String? {
        return attributes[AttributeSecurityDomain] as? String
    }
    public var server: String? {
        return attributes[AttributeServer] as? String
    }
    public var `protocol`: String? {
        return attributes[AttributeProtocol] as? String
    }
    public var authenticationType: String? {
        return attributes[AttributeAuthenticationType] as? String
    }
    public var port: Int? {
        return attributes[AttributePort] as? Int
    }
    public var path: String? {
        return attributes[AttributePath] as? String
    }
}

/// Certificate Attribute Keys
extension Attributes {
    public var subject: String? {
        return attributes[AttributeSubject] as? String
    }
    
    public var issuer: String? {
        return attributes[AttributeIssuer] as? String
    }
    
    public var serialNumber: String? {
        return attributes[AttributeSerialNumber] as? String
    }
    
    public var publicKeyHash: Data? {
        return attributes[AttributePublicKeyHash] as? Data
    }
}

/// Cryptographic Key Attribute Keys
extension Attributes {
    public var keyClass: String? {
        return attributes[AttributeKeyClass] as? String
    }
    
    public var applicationLabel: String? {
        return attributes[AttributeApplicationLabel] as? String
    }
    
    public var applicationTag: String? {
        return attributes[AttributeApplicationTag] as? String
    }
    
    public var keyType: String? {
        return attributes[AttributeKeyType] as? String
    }
}

/// Cryptographic Key Usage Attribute Keys
extension Attributes {
    public var isPermament: Bool? {
        return attributes[AttributeIsPermament] as? Bool
    }
    
    public var isSensitive: Bool? {
        return attributes[AttributeIsSensitive] as? Bool
    }
    
    public var isExtractable: Bool? {
        return attributes[AttributeIsExtractable] as? Bool
    }
}

extension Attributes: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(attributes)"
    }

    public var debugDescription: String {
        return description
    }
}
