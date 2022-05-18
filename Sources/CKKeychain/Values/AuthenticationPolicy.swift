//
//  AuthenticationPolicy.swift
//  
//
//  Created by Dmitriy Zharov on 31.08.2021.
//

public struct AuthenticationPolicy: OptionSet {
    /**
     User presence policy using Touch ID or Passcode. Touch ID does not
     have to be available or enrolled. Item is still accessible by Touch ID
     even if fingers are added or removed.
     */
    public static let userPresence = AuthenticationPolicy(rawValue: 1 << 0)

    /**
     Constraint: Touch ID (any finger) or Face ID. Touch ID or Face ID must be available. With Touch ID
     at least one finger must be enrolled. With Face ID user has to be enrolled. Item is still accessible by Touch ID even
     if fingers are added or removed. Item is still accessible by Face ID if user is re-enrolled.
     */
    public static let biometryAny = AuthenticationPolicy(rawValue: 1 << 1)

    /**
     Constraint: Touch ID from the set of currently enrolled fingers. Touch ID must be available and at least one finger must
     be enrolled. When fingers are added or removed, the item is invalidated. When Face ID is re-enrolled this item is invalidated.
     */
    public static let biometryCurrentSet = AuthenticationPolicy(rawValue: 1 << 3)

    /**
     Constraint: Device passcode
     */
    public static let devicePasscode = AuthenticationPolicy(rawValue: 1 << 4)

    /**
     Constraint logic operation: when using more than one constraint,
     at least one of them must be satisfied.
     */
    public static let or = AuthenticationPolicy(rawValue: 1 << 14)

    /**
     Constraint logic operation: when using more than one constraint,
     all must be satisfied.
     */
    public static let and = AuthenticationPolicy(rawValue: 1 << 15)

    /**
     Create access control for private key operations (i.e. sign operation)
     */
    public static let privateKeyUsage = AuthenticationPolicy(rawValue: 1 << 30)

    /**
     Security: Application provided password for data encryption key generation.
     This is not a constraint but additional item encryption mechanism.
     */
    public static let applicationPassword = AuthenticationPolicy(rawValue: 1 << 31)

    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}
