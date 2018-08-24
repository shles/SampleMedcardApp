//
//  InAppAuthorization.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class InAppAuthorization: Authorization {

    func auth(code: String) {

    }

    func wantsToPerform() -> Observable<Transition> {
        fatalError("wantsToPerform() has not been implemented")
    }
}
