//
//  AuthenticationUI.swift
//  
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

import Foundation

/**
 Predefined item attribute constants used to get or set values
 in a dictionary. The kSecUseAuthenticationUI constant is the key and its
 value is one of the constants defined here.
 If the key kSecUseAuthenticationUI not provided then kSecUseAuthenticationUIAllow
 is used as default.
 */
public enum AuthenticationUI {
    /**
     Specifies that all items which need
     to authenticate with UI will be silently skipped. This value can be used
     only with SecItemCopyMatching.
     */
    case skip
}

extension AuthenticationUI {
    public var rawValue: String {
        switch self {
        case .skip:
            return UseAuthenticationUISkip
        }
    }

    public var description: String {
        switch self {
        case .skip:
            return "skip"
        }
    }
}
