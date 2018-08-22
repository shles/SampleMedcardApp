//
//  VaccinationUpdate.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class VaccinationUpdate: Update {
    
    private var itemsToCommit = [Vaccination]()
    private let token: Token
    private let disposeBag = DisposeBag()
    private var transitionSubject = PublishSubject<Transition>()

    init(token: Token) {
        self.token = token
    }
    
    func addItem(item: Identified) {
        if let item = item as? Vaccination {
            transitionSubject.onNext(PresentTransition(leadingTo: {
                ViewController(presentation: DateSelectionPresentation(title: "Дата прививки", gradient: [.peach, .wheat], onAccept: { [unowned self] in
                    print($0)
                }))
            }))
        }
    }
    
    func apply() {
        if let request = try? AuthorizedRequest(
            path: "/eco-emc/api/my/vaccinations",
            method: .post,
            token: token,
            parameters: itemsToCommit.map { _ in "" }.asParameters(),
            encoding: ArrayEncoding()
            ) {
            request.make().subscribe(onNext: { _ in

            }).disposed(by: disposeBag)
        }
        transitionSubject.onNext(PopTransition())
        
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
