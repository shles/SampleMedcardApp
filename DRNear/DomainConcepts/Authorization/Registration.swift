//
// Created by Артмеий Шлесберг on 19/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

enum Gender {

}

protocol AccountInformation {

    var name: String {get}
    var lastName: String {get}
    var birthDate: Date {get}
    var gender: Gender {get}

    //TODO: create another process for optional info
//    var email: String?
//    var secondName: String?
//    var photo: UIImage?

}

protocol Registration: TransitionSource {

    func register(number: String)

    func confirmNumber(code: String)

    func commitAccountInformation(information: AccountInformation)

    func createPincode(code: String)

    func confirmPincode(code: String)

    func activateTouchID()

    func activateFaceID()

    func proceedToAccount()

}
