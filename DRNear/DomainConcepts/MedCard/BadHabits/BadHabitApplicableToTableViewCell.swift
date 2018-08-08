//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class BadHabitApplicableToTableViewCell: Applicable, BadHabit {

    typealias ApplicationTargetType = SimpleTickedCell

    private var origin: BadHabit

    init(origin: BadHabit) {
        self.origin = origin
    }

    func apply(target: ApplicationTargetType) {
        target.configure(item: self)
    }

    var name: String {
        return origin.name
    }
    var identification: String {
        return origin.identification
    }
    var isSelected: Observable<Bool> {
        return origin.isSelected
    }

    func select() {

    }
}
