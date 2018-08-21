//
//  Consultations.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Consultation: Named, Dated, Described, SystemRelated, Editable, Deletable, Identified, Interactive {
    
}

protocol ObservableConsultations: DatedListRepresentable {
    
    func asObservable() -> Observable<[Consultation]>
    
}

extension ObservableConsultations {
    func toListRepresentable() -> Observable<[DatedListApplicable]> {
        return asObservable().map { $0.map { $0 as DatedListApplicable } }
    }
}
