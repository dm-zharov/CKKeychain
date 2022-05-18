//
//  Keys.swift
//  
//
//  Created by Dmitriy Zharov on 29.10.2021.
//

import Security
#if os(iOS) || os(macOS)
import LocalAuthentication
#endif

/** Class Key Constant */
public let Class = String(kSecClass)

/** General Attribute Key Constants */
public let AttributeAccessControl = String(kSecAttrAccessControl)
public let AttributeAccessible = String(kSecAttrAccessible)
public let AttributeAccessGroup = String(kSecAttrAccessGroup)
public let AttributeSynchronizable = String(kSecAttrSynchronizable)
public let AttributeCreationDate = String(kSecAttrCreationDate)
public let AttributeModificationDate = String(kSecAttrModificationDate)
public let AttributeDescription = String(kSecAttrDescription)
public let AttributeComment = String(kSecAttrComment)
public let AttributeCreator = String(kSecAttrCreator)
public let AttributeType = String(kSecAttrType)
public let AttributeLabel = String(kSecAttrLabel)
public let AttributeIsInvisible = String(kSecAttrIsInvisible)
public let AttributeIsNegative = String(kSecAttrIsNegative)

/** Password Attribute Key Constants */
public let AttributeAccount = String(kSecAttrAccount)
public let AttributeService = String(kSecAttrService)
public let AttributeGeneric = String(kSecAttrGeneric)
public let AttributeSecurityDomain = String(kSecAttrSecurityDomain)
public let AttributeServer = String(kSecAttrServer)
public let AttributeProtocol = String(kSecAttrProtocol)
public let AttributeAuthenticationType = String(kSecAttrAuthenticationType)
public let AttributePort = String(kSecAttrPort)
public let AttributePath = String(kSecAttrPath)

/** Certificate Attribute Key Constants */
public let AttributeSubject = String(kSecAttrSubject)
public let AttributeIssuer = String(kSecAttrIssuer)
public let AttributeSerialNumber = String(kSecAttrSerialNumber)
public let AttributeSubjectKeyID = String(kSecAttrSubjectKeyID)
public let AttributePublicKeyHash = String(kSecAttrPublicKeyHash)
public let AttributeCertificateType = String(kSecAttrCertificateType)
public let AttributeCertificateEncoding = String(kSecAttrCertificateEncoding)

/** Cryptographic Key Attribute Constants */
public let AttributeKeyClass = String(kSecAttrKeyClass)
public let AttributeApplicationLabel = String(kSecAttrApplicationLabel)
public let AttributeApplicationTag = String(kSecAttrApplicationTag)
public let AttributeKeyType = String(kSecAttrKeyType)
public let AttributeKeySizeInBits = String(kSecAttrKeySizeInBits)
public let AttributeEffectiveKeySize = String(kSecAttrEffectiveKeySize)
public let AttributeTokenID = String(kSecAttrTokenID)

/** Cryptographic Key Usage Attribute Constants */
public let AttributeIsPermament = String(kSecAttrIsPermanent)
public let AttributeIsSensitive = String(kSecAttrIsSensitive)
public let AttributeIsExtractable = String(kSecAttrIsExtractable)

public let SynchronizableAny = kSecAttrSynchronizableAny

/** Search Constants */
public let MatchLimit = String(kSecMatchLimit)
public let MatchLimitOne = kSecMatchLimitOne
public let MatchLimitAll = kSecMatchLimitAll

/** Return Type Key Constants */
public let ReturnData = String(kSecReturnData)
public let ReturnAttributes = String(kSecReturnAttributes)
public let ReturnRef = String(kSecReturnRef)
public let ReturnPersistentRef = String(kSecReturnPersistentRef)

/** Value Type Key Constants */
public let ValueData = String(kSecValueData)
public let ValueRef = String(kSecValueRef)
public let ValuePersistentRef = String(kSecValuePersistentRef)

/** Import Export Constants */
public let ImportExportPassphrase = String(kSecImportExportPassphrase)

/** Other Constants */
public let UseAuthenticationUI = String(kSecUseAuthenticationUI)

public let UseAuthenticationContext = String(kSecUseAuthenticationContext)

public let UseAuthenticationUISkip = String(kSecUseAuthenticationUISkip)

public let UseDataProtectionKeychain = String(kSecUseDataProtectionKeychain)

#if os(iOS) && !targetEnvironment(macCatalyst)
/** Credential Key Constants */
public let SharedPassword = String(kSecSharedPassword)
#endif
