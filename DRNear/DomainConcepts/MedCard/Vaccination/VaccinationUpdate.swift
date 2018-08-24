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
                    self.itemsToCommit += [MyVaccinationFrom(name: item.name, id: item.identification, code: item.identification, date: $0, token: self.token)]
                }))
            }))
        }
    }

    func apply() {

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        if let request = try? AuthorizedRequest(

            path: "/eco-emc/api/my/vaccinations",
            method: .post,
            token: token,
            parameters: itemsToCommit.map { ["name": ["code": $0.identification], "date": formatter.string(from: $0.date)] }.asParameters(),
            encoding: ArrayEncoding()
            ) {
            request.make().subscribe(onNext: { [unowned self] _ in
                self.transitionSubject.onNext(PopTransition())
            }, onError: {
                self.transitionSubject.onNext(ErrorAlertTransition(error: $0))
            }).disposed(by: disposeBag)
        }
    }

    func wantsToPerform() -> Observable<Transition> {
        return transitionSubject
    }
}
