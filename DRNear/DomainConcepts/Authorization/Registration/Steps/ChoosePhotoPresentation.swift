//
// Created by Артмеий Шлесберг on 06/09/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class ChoosePhotoPresentation: Presentation {
    private(set) var view: UIView = UIView()

    init() {
        fatalError("not implemented")
    }

    func willAppear() {
    }

    func wantsToPerform() -> RxSwift.Observable<Transition> {
        fatalError("wantsToPerform() has not been implemented")
    }
}
