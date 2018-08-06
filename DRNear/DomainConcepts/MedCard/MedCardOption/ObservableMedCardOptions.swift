//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol MedCard {

    func options() -> Observable<[MedCardOption]>
}

class MedCardFrom: MedCard {

    private let items: [MedCardOption]

    init(options: [MedCardOption]) {
        self.items = options
    }
    func options() -> Observable<[MedCardOption]> {
        return Observable.just(items)
    }

}
