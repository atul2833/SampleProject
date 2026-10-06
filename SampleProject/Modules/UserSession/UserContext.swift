//
//  UserSession.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 29/01/2024.
//

import Foundation
import Combine

struct UserInformation {
    var profileModel: ProfileInfoModel?
}

final class UserContext {
    private var userInformationSubject = CurrentValueSubject<UserInformation, Never>(UserInformation())
    
    private init() { }
    
    func update(_ builder: (UserContextBuilder) -> UserContextBuilder) {
        userInformationSubject.send(builder(UserContextBuilder(userInformation: getUserInformation())).build())
    }
    
    func getUserInformation() -> UserInformation {
        return userInformationSubject.value
    }
    
    static func create(with userInformation: UserInformation) -> UserContext {
        let context = UserContext()
        context.userInformationSubject.send(userInformation)
        return context
    }
    
    func observeUserInformation() -> AnyPublisher<UserInformation, Never> {
        return userInformationSubject.eraseToAnyPublisher()
    }
}

 //MARK: - UserContextBuilder
final class UserContextBuilder {
    private var userInformation: UserInformation
    
    init(userInformation: UserInformation) {
        self.userInformation = userInformation
    }
   
    func updateProfileModel(_ profileModel: ProfileInfoModel) -> UserContextBuilder {
        userInformation.profileModel = profileModel
        return self
    }

    func build() -> UserInformation {
        return userInformation
    }
}
