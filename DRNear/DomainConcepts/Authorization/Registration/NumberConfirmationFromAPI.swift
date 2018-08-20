//
//  NumberConfirmationFromAPI.swift
//  DRNear
//
//  Created by Igor Shmakov on 20/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class NumberConfirmationFromAPI: NumberConfirmation {
    
    private let disposeBag = DisposeBag()
    private var number = ""
    
    init(number: String) {
        self.number = number
    }
    
    func confirmNumber(code: String) {
        guard let request = try? UnauthorizedRequest(path: "???",
                                                     method: .post,
                                                     parameters: ["number": self.number,
                                                                  "code": code]) else { return }
        request.make().subscribe({ _ in
           
            /*
            if alreadyRegisterd {
                let appSetup = ApplicationSetup()
            } else {
                let commitmentStep = AccountCommitmentFromAPI()
            }
            */
            
            let commitmentStep = AccountCommitmentFromAPI()
           
        } ).disposed(by: disposeBag)
    }
    
    func wantsToPerform() -> Observable<Transition> {
        fatalError("wantsToPerform() has not been implemented")
    }
    
}
