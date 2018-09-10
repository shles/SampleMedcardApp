//
//  Consultations.swift
//  DRNear
//
//  Created by Igor Shmakov on 18/08/2018.
//  Copyright © 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Consultation: Named, Dated, Described, SystemRelated, Editable, Deletable, Identified, Interactive, Serializable, ContainFiles{

}

protocol ObservableConsultations: DatedListRepresentable {

    func asObservable() -> Observable<[Consultation]>

}

protocol SystemConsultation: Consultation {

    var doctor: Doctor { get }
    var diagnose: String { get }
    var recommendation: String { get }

    func like()
    func startChat()
    //FIXME: not shure
    func showRecord()
}

extension ObservableConsultations {
    func toListRepresentable() -> Observable<[DatedListApplicable]> {
        return asObservable().map { $0.map { $0 as DatedListApplicable } }
    }
}
