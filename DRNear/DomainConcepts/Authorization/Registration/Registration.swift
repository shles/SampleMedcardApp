//
// Created by Артмеий Шлесберг on 19/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

enum Gender: String {

    case male, female
}

protocol AccountInformation: Serializable {

    var name: String { get }
    var lastName: String { get }
    var middleName: String { get }
    var birthDate: Date { get }
    var gender: Gender { get }

    //TODO: create another process for optional info
//    var email: String?
//    var secondName: String?
//    var photo: UIImage?

}

struct AccountInformationFrom: AccountInformation {
    private(set) var name: String = "Вася"
    private(set) var lastName: String = "Пупкин"
    private(set) var middleName: String = "Михайлович"
    private(set) var birthDate: Date = Date()
    private(set) var gender: Gender = .male
    
    var json: [String : Any] {
        var parameters = [String : Any]()
        parameters["firstName"] = name
        parameters["lastName"] = lastName
        parameters["middleName"] = middleName
        parameters["birthDate"] = birthDate.string
        parameters["gender"] = gender.rawValue
        return parameters
    }
    
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
    
    func authWithFaceId()
    
    func authWithTouchId()
}
