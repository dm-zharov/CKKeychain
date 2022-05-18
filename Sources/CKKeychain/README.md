# CKKeychain
Обертка для системной библиотеки Security

## Мотивация
* Библиотека Security является низкоуровневой (CoreFoundation). Работа с ней происходит посредством формирования различных словарей с параметрами
* Набор параметров для каждого типа сохраняемого в кейчейн значения различен. Во множестве проектов возникают проблемы поиска оптимальных значений
* Кейчейн работает неидеально: он может выдавать некорректный результат при документированом использовании, и наоборот, корректный результат при неочевидных действиях
* Различные открытые решения не предоставляют функционал для работы с сертификатом и его приватным ключом

Данная библиотека призвана помочь вам не задумываться о том, какие параметры записи необходимо подбирать на iOS/Mac Catalyst/macOS, а просто получать желаемый результат!

Примеры проблем, встречаемых при работе напрямую с Security при решении корпоративных бизнес-задач:
- При записи `kSecItemClassIdentity` не удается его считать обратно. Почему?
    1. При записи через `SecItemAdd` необходимо сохранять возвращенный указатель (`kSecReturnPersistentRef`). Обнаружить записанный вами `kSecItemClassIdentity` возможно лишь при поиске его с помощью указателя.
    2. При записи через `SecItemAdd` нельзя передавать [`kSecClass`: `kSecItemClassIdentity`], система вернёт `errSecSuccess`, однако на самом деле ничего записано не будет.
    3. При записи и поиске сохраненных `kSecItemClassIdentity` нельзя передавать параметры `kSecReturnAttributes`, `kSecReturnData`, или `kSecReturnRef`. Из данного перечня доступен только `kSecReturnPersistentRef`.
- `kSecItemClassIdentity` представляет из себя виртуальный объект, формируемый из пары `kSecItemClassCertificate` и `kSecItemClassKey`. Однако при раздельной записи сертификата и ключа получить назад `kSecItemClassIdentity` не выходит. Почему? Для получения этого виртуального объекта значение поля `kSecAttrPublicKeyHash` у `kSecItemClassCertificate` и значение полей `kSecAttrLabel` + `kSecAttrApplicationLabel` у `kSecItemClassKey` должны полностью совпадать.
- Без указания атрибута `kSecUseDataProtectionKeychain` и/или `kSecAttrSynchronizable` при чтении из `Mac Catalyst` и `macOS` происходит обращение в системный кейчейн. При указании обращение произойдет к кейчейну приложения.
- И прочие неочевидные нюансы...

## Особенности

- Простой интерфейс
- Поддержка групп доступа
- [Поддержка указания уровня доступа](#accessibility)
- [Поддержка iCloud Sharing](#icloud_sharing)
- [Поддержка TouchID и Face ID](#touch_id_integration)
- [Поддержка Shared Web Credentials](#shared_web_credentials)
- [Поддержка iOS, Mac Catalyst & macOS](#requirements)
- [watchOS и tvOS также поддерживаются](#requirements)

## Использование

##### See also:  
- [:link: iOS Example Project](./Examples/Example-iOS)

### Основа

#### Сохранение авторизационных данных от приложения/сервиса

```swift
let keychain = Keychain.genericPassword(service: "SberCloud")
keychain["dm_zharov"] = "01234567-89ab-cdef-0123-456789abcdef"
```

#### Сохранение авторизационных данных сайта

```swift
let keychain = Keychain.internetPassword(server: "https://github.com", protocolType: .https)
keychain["dm_zharov"] = "01234567-89ab-cdef-0123-456789abcdef"
```

### Сохранение публичного и приватного ключей
```swift
Keychain.key(keyClass: .public, keyType: .rsa).set(publicKeyData, "public.key.unique.string")
Keychain.key(keyClass: .private, keyType: .rsa).set(privateKeyData, "public.key.unique.string")
```

### Сохранение и чтение сущности сертификата пользователя (X.509)
```swift
let persistentReference = Keychain(itemClass: .identity).attributes([
    AttributeAccessGroup: "my.access.group" // Необязательно
]).setPersistentValue(identity, key: ValueRef) else {
    return
}

let identity = Keychain(itemClass: .identity).attributes([
    AttributeAccessGroup: "my.access.group" // Необязательно
    ValuePersistentRef: persistentReference
]).allItems().first
```

### :key: Инициализация

#### Создание кейчейна для авторизационных данных от приложения/сервиса

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")
```

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token", accessGroup: "12ABCD3E4F.shared")
```

#### Создание кейчейна для авторизационных данных сайта

```swift
let keychain = Keychain.internetPassword(service: "https://github.com", protocolType: .https)
```

```swift
let keychain = Keychain.internetPassword(service: "https://github.com", protocolType: .https, authenticationType: .htmlForm)
```

### :key: Добавление объекта

#### subscripting

##### for String

```swift
keychain["dm_zharov"] = "01234567-89ab-cdef-0123-456789abcdef"
```

```swift
keychain[string: "dm_zharov"] = "01234567-89ab-cdef-0123-456789abcdef"
```

##### for NSData

```swift
keychain[data: "secret"] = NSData(contentsOfFile: "secret.bin")
```

#### set method

```swift
keychain.set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
```

#### error handling

```swift
do {
    try keychain.set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
}
catch let error {
    print(error)
}
```

### :key: Получение объекта

#### subscripting

##### for String (If the value is NSData, attempt to convert to String)

```swift
let token = keychain["dm_zharov"]
```

```swift
let token = keychain[string: "dm_zharov"]
```

##### for NSData

```swift
let secretData = keychain[data: "secret"]
```

#### get methods

##### as String

```swift
let token = try? keychain.get("dm_zharov")
```

```swift
let token = try? keychain.getString("dm_zharov")
```

##### as NSData

```swift
let data = try? keychain.getData("dm_zharov")
```

### :key: Удаление объекта

#### subscripting

```swift
keychain["dm_zharov"] = nil
```

#### remove method

```swift
do {
    try keychain.remove("dm_zharov")
} catch let error {
    print("error: \(error)")
}
```

### :key: Указание Label, Appication Label и Comment

```swift
let keychain = Keychain.internetPassword(service: "https://github.com", protocolType: .https)
do {
    try keychain
        .label("github.com (dm_zharov)")
        .applicationLabel("github.com (dm_zharov)")
        .comment("github access token")
        .set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
} catch let error {
    print("error: \(error)")
}
```

### :key: Получение других атрибутов

#### Постоянный указатель

```swift
let keychain = Keychain.genericPassword()
let persistentRef = keychain[attributes: "dm_zharov"]?.persistentRef
...
```

#### Дата создания

```swift
let keychain = Keychai.genericPassword()
let creationDate = keychain[attributes: "dm_zharov"]?.creationDate
...
```

#### Все атрибуты

```swift
let keychain = Keychain.genericPassword()
do {
    let attributes = try keychain.get("dm_zharov") { $0 }
    print(attributes?.comment)
    print(attributes?.label)
    print(attributes?.creator)
    ...
} catch let error {
    print("error: \(error)")
}
```

##### subscripting

```swift
let keychain = Keychain.genericPassword()
if let attributes = keychain[attributes: "dm_zharov"] {
    print(attributes.comment)
    print(attributes.label)
    print(attributes.creator)
}
```

### :key: Конфигурация (Accessibility, Sharing, iCloud Sync)

**Реализаны простые модификаторы**

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")
    .label("github.com (dm_zharov)")
    .synchronizable(true)
    .accessibility(.afterFirstUnlock)
```

#### <a name="accessibility"> Уровень доступа 

##### Стандартный уровень доступа подходит для бекграунд приложений (= `kSecAttrAccessibleAfterFirstUnlock`)

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")
```

##### Явное указание, что объект будет использоваться в бекграунд приложении

###### Создание кейчейна

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")
    .accessibility(.afterFirstUnlock)

keychain["dm_zharov"] = "01234567-89ab-cdef-0123-456789abcdef"
```

###### Разовый вызов

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")

do {
    try keychain
        .accessibility(.afterFirstUnlock)
        .set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
} catch let error {
    print("error: \(error)")
}
```

##### Для активного приложения

###### Создание кейчейна

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")
    .accessibility(.whenUnlocked)

keychain["dm_zharov"] = "01234567-89ab-cdef-0123-456789abcdef"
```

###### Разовый вызов

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")

do {
    try keychain
        .accessibility(.whenUnlocked)
        .set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
} catch let error {
    print("error: \(error)")
}
```

#### :couple: По умолчанию шаринг объектов через iCloud отключен

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token", accessGroup: "12ABCD3E4F.shared")
```

#### <a name="icloud_sharing"> :arrows_counterclockwise: Шаринг объектов кейчейн через iCloud

###### Создание кейчейна

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")
    .synchronizable(true)

keychain["dm_zharov"] = "01234567-89ab-cdef-0123-456789abcdef"
```

###### Разовый вызов

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")

do {
    try keychain
        .synchronizable(true)
        .set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
} catch let error {
    print("error: \(error)")
}
```

### <a name="touch_id_integration"> :cyclone: Интеграция Touch ID (Face ID)

**Любая операция, требующая аутентификации от пользователя должна выполняться из бекграунд треда**  
**При их выполнении из main треда, UI будет заблокирован во время отображения диалога аутентификации**

**Для использования Face ID, добавьте ключ `NSFaceIDUsageDescription` в ваш `Info.plist`**

#### :closed_lock_with_key: Добавление объекта, защищенного при помощи Touch ID (Face ID)

Если вы хотите записать в кейчейн объект, который должен быть защищен при помощи Touch ID (Face ID), укажите атрибуты `accessibility` и `authenticationPolicy`.  

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")

DispatchQueue.global().async {
    do {
        // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
        try keychain
            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
            .set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
    } catch let error {
        // Error handling if needed...
    }
}
```

#### :closed_lock_with_key: Обновление объекта, защищенного при помощи Touch ID (Face ID)

Аналогично с тем, как вы добавляете объект 
**Не вызывайте данный код из main треда, так как существует вероятность, что объект уже существует, и он уже защищен**
**Все потому, что операция с объектом потребует аутентификации от пользователя**

Если вы хотите отобразить кастомное сообщение пользователю при аутентификации, укажите атрибут `authenticationPrompt`.
Если объект не защищен, атрибут `authenticationPrompt` будет проигнорирован.

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")

DispatchQueue.global().async {
    do {
        // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
        try keychain
            .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
            .authenticationPrompt("Authenticate to update your access token")
            .set("01234567-89ab-cdef-0123-456789abcdef", key: "dm_zharov")
    } catch let error {
        // Error handling if needed...
    }
}
```

#### :closed_lock_with_key: Получение объекта, защищенного при помощи Touch ID (Face ID)

Аналогично с тем, как вы получаете обычные объекты. Пользователю автоматически будет отображен диалог аутентификации по Touch ID (Face ID) или паролю.
Если вы хотите отобразить кастомное сообщение пользователю при аутентификации, укажите атрибут `authenticationPrompt`.
Если объект не защищен, атрибут `authenticationPrompt` будет проигнорирован.

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")

DispatchQueue.global().async {
    do {
        let password = try keychain
            .authenticationPrompt("Authenticate to login to server")
            .get("dm_zharov")

        print("password: \(password)")
    } catch let error {
        // Error handling if needed...
    }
}
```

#### :closed_lock_with_key: Удаление объекта, защищенного при помощи Touch ID (Face ID)

Аналогично с тем, как вы удаляете обычные объекты.
Диалог аутентификации по Touch ID (Face ID) или паролю при удалении не отображается.

```swift
let keychain = Keychain.genericPassword(service: "com.example.github-token")

do {
    try keychain.remove("dm_zharov")
} catch let error {
    // Error handling if needed...
}
```

### <a name="shared_web_credentials"> :key: Shared Web Credentials (Beta)

> Shared web credentials is a programming interface that enables native iOS apps to share credentials with their website counterparts. For example, a user may log in to a website in Safari, entering a user name and password, and save those credentials using the iCloud Keychain. Later, the user may run a native app from the same developer, and instead of the app requiring the user to reenter a user name and password, shared web credentials gives it access to the credentials that were entered earlier in Safari. The user can also create new accounts, update passwords, or delete her account from within the app. These changes are then saved and used by Safari.  
<https://developer.apple.com/library/ios/documentation/Security/Reference/SharedWebCredentialsRef/>


```swift
let keychain = Keychain.internetPassword(service: "https://www.dm_zharov.com", protocolType: .HTTPS)

let username = "dm_zharov@mac.com"

// First, check the credential in the app's Keychain
if let password = try? keychain.get(username) {
    // If found password in the Keychain,
    // then log into the server
} else {
    // If not found password in the Keychain,
    // try to read from Shared Web Credentials
    keychain.getSharedPassword(username) { (password, error) -> () in
        if password != nil {
            // If found password in the Shared Web Credentials,
            // then log into the server
            // and save the password to the Keychain

            keychain[username] = password
        } else {
            // If not found password either in the Keychain also Shared Web Credentials,
            // prompt for username and password

            // Log into server

            // If the login is successful,
            // save the credentials to both the Keychain and the Shared Web Credentials.

            keychain[username] = inputPassword
            keychain.setSharedPassword(inputPassword, account: username)
        }
    }
}
```

#### Request all associated domain's credentials

```swift
Keychain.requestSharedWebCredential { (credentials, error) -> () in

}
```

#### Generate strong random password

Generate strong random password that is in the same format used by Safari autofill (xxx-xxx-xxx-xxx).

```swift
let password = Keychain.generatePassword() // => Nhu-GKm-s3n-pMx
```

#### How to set up Shared Web Credentials

> 1. Add a com.apple.developer.associated-domains entitlement to your app. This entitlement must include all the domains with which you want to share credentials.
>
> 2. Add an apple-app-site-association file to your website. This file must include application identifiers for all the apps with which the site wants to share credentials, and it must be properly signed.
>
> 3. When the app is installed, the system downloads and verifies the site association file for each of its associated domains. If the verification is successful, the app is associated with the domain.

**Больше информации:**  
<https://developer.apple.com/library/ios/documentation/Security/Reference/SharedWebCredentialsRef/>

### :mag: Debugging

#### Печать (print) всех хранимых объектов

```swift
let keychain = Keychain.internetPassword(service: "https://github.com", protocolType: .https)
print("\(keychain)")
```

```
=>
[
  [authenticationType: default, key: dm_zharov, server: github.com, class: internetPassword, protocol: https]
  [authenticationType: default, key: hirohamada, server: github.com, class: internetPassword, protocol: https]
  [authenticationType: default, key: honeylemon, server: github.com, class: internetPassword, protocol: https]
]
```

#### Получение всех хранимых ключей

```swift
let keychain = Keychain.internetPassword(service: "https://github.com", protocolType: .https)

let keys = keychain.allKeys()
for key in keys {
  print("key: \(key)")
}
```

```
=>
key: dm_zharov
key: hirohamada
key: honeylemon
```

#### Получение всех хранимых объектов

```swift
let keychain = Keychain.internetPassword(service: "https://github.com", protocolType: .https)

let items = keychain.allItems()
for item in items {
  print("item: \(item)")
}
```

```
=>
item: [authenticationType: Default, key: dm_zharov, server: github.com, class: InternetPassword, protocol: https]
item: [authenticationType: Default, key: hirohamada, server: github.com, class: InternetPassword, protocol: https]
item: [authenticationType: Default, key: honeylemon, server: github.com, class: InternetPassword, protocol: https]
```

## Требования для шаринга объектов через iCloud

Если вы столкнулись с указанной ниже проблемом, вам необходимо модифицировать `*.entitlements` (добавить новый `Capability`).

```
OSStatus error:[-34018] Internal error when a required entitlement isn't present, client has neither application-identifier nor keychain-access-groups entitlements.
```

<img alt="Screen Shot 2019-10-27 at 8 08 50" src="https://user-images.githubusercontent.com/40610/67627108-1a7f2f80-f891-11e9-97bc-7f7313cb63d1.png" width="500">

<img src="https://user-images.githubusercontent.com/40610/67627072-333b1580-f890-11e9-9feb-bf507abc2724.png" width="500" />
