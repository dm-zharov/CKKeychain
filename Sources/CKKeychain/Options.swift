//
//  Options.swift
//  
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

import Foundation

struct Options {
    var itemClass: ItemClass = .genericPassword
    
    var accessGroup: String?
    
    var accessibility: Accessibility = .afterFirstUnlock
    var authenticationPolicy: AuthenticationPolicy?

    var useDataProtectionKeychain = true
    var synchronizable: Bool = false
    
    var label: String?
    var applicationLabel: String?
    var comment: String?

    // MARK: Generic Password
    
    var service: String = ""
    
    // MARK: Internet Password

    var server: URL!
    var protocolType: ProtocolType!
    var authenticationType: AuthenticationType = .default
    
    // MARK: -

    var authenticationUI: AuthenticationUI?
    var authenticationContext: AnyObject?

    var attributes = [String: Any]()
}

extension Options {
    func query(ignoringAttributeSynchronizable: Bool = true) -> [String: Any] {
        var query = [String: Any]()

        query[Class] = itemClass.rawValue
        
        if let accessGroup = self.accessGroup {
            query[AttributeAccessGroup] = accessGroup
        }
        
        if ignoringAttributeSynchronizable {
            query[AttributeSynchronizable] = kSecAttrSynchronizableAny
        } else {
            query[AttributeSynchronizable] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse
        }

        switch itemClass {
        case .genericPassword:
            query[AttributeService] = service

        case .internetPassword:
            query[AttributeServer] = server.host
            query[AttributePort] = server.port
            query[AttributeProtocol] = protocolType.rawValue
            query[AttributeAuthenticationType] = authenticationType.rawValue

        case .certificate:
            break

        case .key:
            break

        case .identity:
            break
        }
        
        #if targetEnvironment(macCatalyst) || os(macOS)
            query[UseDataProtectionKeychain] = true
        #endif

        if authenticationContext != nil {
            query[UseAuthenticationContext] = authenticationContext
        }

        return query
    }
    
    func attributes(key: String?, value: Any) -> ([String: Any], Error?) {
        var attributes: [String: Any]
        
        if key != nil {
            attributes = query()
        } else {
            attributes = [String: Any]()
        }
        
        if [.genericPassword, .internetPassword].contains(itemClass) {
            attributes[AttributeAccount] = key
            if value is Data {
                attributes[ValueData] = value
            } else {
                fatalError("Value type of \(itemClass) must be a Data")
            }
        } else {
            if let key = key {
                attributes[key] = value
            }
        }
        
        switch itemClass {
        case .genericPassword:
            break

        case .internetPassword:
            break

        case .certificate:
            break

        case .key:
            break

        case .identity:
            // If you use kSecReturnAttributes, kSecReturnData, or kSecReturnRef, even when successfully added, the result is NULL.
            // Only if you use kSecReturnPersistentRef it will not be NULL.
            guard
                attributes[ReturnData] == nil,
                attributes[ReturnRef] == nil,
                attributes[ReturnAttributes] == nil
            else {
                return (attributes, Status.badReq)
            }
            attributes[ReturnPersistentRef] = true
            
            // If you have that in your query dictionary, nothing is added at all!
            // The call indicates success (returns 0), but it doesn't add anything to keychain.
            attributes[Class] = nil
        }

        if let label = label {
            attributes[AttributeLabel] = label
        }
        if let applicationLabel = applicationLabel {
            attributes[AttributeApplicationLabel] = applicationLabel
        }
        if let comment = comment {
            attributes[AttributeComment] = comment
        }

        if let authenticationPolicy = authenticationPolicy {
            var error: Unmanaged<CFError>?
            guard let accessControl = SecAccessControlCreateWithFlags(
                    kCFAllocatorDefault,
                    accessibility.rawValue as CFTypeRef,
                    SecAccessControlCreateFlags(rawValue: CFOptionFlags(authenticationPolicy.rawValue)),
                    &error
            ) else {
                if let error = error?.takeUnretainedValue() {
                    return (attributes, error.error)
                }

                return (attributes, Status.unexpectedError)
            }
            attributes[AttributeAccessControl] = accessControl
        } else {
            attributes[AttributeAccessible] = accessibility.rawValue
        }
        
        #if targetEnvironment(macCatalyst) || os(macOS)
            attributes[UseDataProtectionKeychain] = true
        #endif

        attributes[AttributeSynchronizable] = synchronizable

        return (attributes, nil)
    }
}
