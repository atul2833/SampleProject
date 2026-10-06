//
//  KeychainWrapper.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 16/01/2024.
//

import Foundation
import KeychainSwift

final class KeychainWrapper {
    
    static let shared = KeychainWrapper()
    private let keychain = KeychainSwift()
    
    enum Keys:String {
        case tokenVerifiedModel
        case ugudoAccessToken
    }
    
    private init() {
        configureKeychain()
    }
    
    private func configureKeychain() {
        // Add any common keychain configuration here
//        keychain.accessGroup = "asd"
        // You can include additional configurations as needed
    }
    
    @discardableResult
    func save(_ value: String, forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool {
        keychain.set(value, forKey: key, withAccess: access)
    }
    
    @discardableResult
    func save(_ value: Data, forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool {
        keychain.set(value, forKey: key, withAccess: access)
    }
    
    func getString(forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil) -> String? {
        keychain.get(key)
    }
    
    func getBool(forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool? {
        keychain.getBool(key)
    }
    
    func getData(forKey key: String, withAccess access: KeychainSwiftAccessOptions? = nil) -> Data? {
        keychain.getData(key)
    }
    
    @discardableResult
    func clearAllKeychain() -> Bool {
        keychain.clear()
    }
}
