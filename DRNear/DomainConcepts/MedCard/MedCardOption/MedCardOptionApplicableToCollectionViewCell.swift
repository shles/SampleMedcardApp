//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
//TODO: get rid
class MedCardOptionApplicableToCollectionViewCell: MedCardOption, Applicable {

    private let origin: MedCardOption

    typealias ApplicationTargetType = MedCardOptionCollectionViewCell

    init(origin: MedCardOption) {
        self.origin = origin
    }

    func apply(target: ApplicationTargetType) {
        target.configure(medCardOption: self)
    }

    var gradientColors: [UIColor] {
        return origin.gradientColors
    }
    var name: String {
        return origin.name
    }

    var image: ObservableImage {
        return origin.image
    }

    func interact() {
        origin.interact()
    }

    func wantsToPerform() -> Observable<Transition> {
        return origin.wantsToPerform()
    }
}
