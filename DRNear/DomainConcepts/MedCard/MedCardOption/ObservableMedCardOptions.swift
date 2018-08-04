//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
protocol ObservableMedCardOptions {

    func asObservable() -> Observable<MedCardOptions>
}

class SimpleObservableMedCardOptions: ObservableMedCardOptions {
    
    private let options = SimpleMedCardOptions()
    func asObservable() -> Observable<MedCardOptions> {
        return Observable.just(options)
    }

}
