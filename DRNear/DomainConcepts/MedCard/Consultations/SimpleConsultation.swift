//
//  SimpleConsultation.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class SimpleConsultation: Consultation {
    
    private(set) var name: String = "Врач-педиатр"
    private(set) var date: Date = Date()
    var description: String = "Первичная консультация"
    
    private var deletionSubject = PublishSubject<Void>()
    
    func delete() {
        deletionSubject.onNext(())
    }
    
    func wantsToPerform() -> Observable<Transition> {
        return deletionSubject.map { [unowned self] _ in
            PresentTransition(
                leadingTo: { ViewController(
                    presentation: DeletionPresentation(
                        title: "Вы уверены, что хотите удалить \"\(self.name)\"?",
                        onAccept: { }
                    )
                    )}
            )
        }
    }
    
    private(set) var isRelatedToSystem: Bool = false
    
    func edit() {
        
    }
    
    private(set) var identification: String = ""
}

class SimpleMyConsultations: ObservableConsultations {
    
    private let tests = [SimpleConsultation(),
                         SimpleConsultation(),
                         SimpleConsultation()]
    
    func asObservable() -> Observable<[Consultation]> {
        return Observable.just(tests)
    }
}
