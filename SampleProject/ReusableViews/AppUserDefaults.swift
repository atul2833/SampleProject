//
//  Utilities.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 01/01/24.
//

import UIKit

class AppUserDefaults: NSObject {
    
    static let shared = AppUserDefaults()
    let UserDafaults = UserDefaults.standard

    func UDSave(_ value: Any?,forKey: UDKeys) {
        guard let value = value else { return }
        UserDafaults.setValue(value, forKey: forKey.rawValue)
        UserDafaults.synchronize()
    }
    
    func UDValue(_ forKey: UDKeys) -> Any {
        let value = UserDafaults.value(forKey: forKey.rawValue)
        return value
    }
    
    func UDClear(_ forKey: UDKeys) {
        let deviceToken = UDValue(.deviceToken)
        let dictionary = UserDafaults.dictionaryRepresentation()
        UserDafaults.removeObject(forKey: forKey.rawValue)
    
        UDSave(deviceToken, forKey: .deviceToken)
        UserDafaults.synchronize()
    }
    
    func clearAllUD() {
      //  let deviceToken = UDValue(.deviceToken)
        let dictionary = UserDafaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            UserDafaults.removeObject(forKey: key)
        }
       // UDSave(deviceToken, forKey: .deviceToken)
        UserDafaults.synchronize()
    }
}

