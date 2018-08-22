//
//  AllergiesUpdate.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class AllergiesUpdate: Update {
    
    private var itemsToCommit = [ClarifiedAllergy]()
    private let token: Token
    private let disposeBag = DisposeBag()

    private let transitionSubject = PublishSubject<Transition>()
    init(token: Token) {
        self.token = token
    }
    
    func addItem(item: Identified) {
        //TODO: this makes this solution worse, possible all of them should be Generic
        if let item = item as? Allergy {
            transitionSubject.onNext(PresentTransition(leadingTo: {
                ViewController(presentation: CommentPresentation(title: "Комментарий", gradient: [.peach, .wheat], onAccept: { [unowned self] in
                    self.itemsToCommit += [ClarifiedAllergy(origin: item, clarification: $0)]
                }))
            }))
        }
    }
    
    func apply() {
        /*
          {
    "allergyIntoleranceStatus": {
      "code": "string",
      "name": "string"
    },
    "category": {
      "code": "string",
      "name": "string"
    },
    "clarification": "string",
    "digitalMedicalRecordId": 0,
    "id": 0
  }
        */

        if let request = try? AuthorizedRequest(
            path: "/eco-emc/api/my/allergies",
            method: .post,
            token: token,
            parameters: itemsToCommit.map {
                [
                    "allergyIntoleranceStatus": [
                        "code": $0.status?.code ?? "",
                        "name": $0.status?.name ?? ""
                    ],
                    "category": [
                        "code": $0.category?.code ?? "",
                        "name": $0.category?.name ?? ""
                    ],
                    "clarification": $0.clarification,
                    "digitalMedicalRecordId": 0,
                    "id": 0
                ]
            }.asParameters(),
            encoding: ArrayEncoding()
            ) {
            request.make().subscribe(onNext: { [unowned self] _ in
                self.transitionSubject.onNext(PopTransition())
            }, onError: { [unowned self] _ in
                self.transitionSubject.onNext(PopTransition())
            }).disposed(by: disposeBag)
        }
        
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
