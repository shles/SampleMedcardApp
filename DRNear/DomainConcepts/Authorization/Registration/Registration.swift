//
// Created by Артмеий Шлесберг on 19/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

enum Gender {

    case male, female

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

struct AccountInformationFrom: AccountInformation {
    private(set) var name: String = ""
    private(set) var lastName: String = ""
    private(set) var birthDate: Date = Date()
    private(set) var gender: Gender = .male
}

protocol NumberRegistration: TransitionSource {
    func register(number: String)
}

protocol NumberConfirmation: TransitionSource {
    func confirmNumber(code: String)
}


protocol AccountCommitment: TransitionSource {
    func commitAccountInformation(information: AccountInformation)
}

protocol LoginMethodsApplication: TransitionSource {

    func createPincode(code: String)

    func confirmPincode(code: String)

    func activateTouchID()

    func activateFaceID()

    func proceedToAccount()

}

protocol Authorization: TransitionSource {

    func auth(code: String)

    //TODO: check another methods process
}
