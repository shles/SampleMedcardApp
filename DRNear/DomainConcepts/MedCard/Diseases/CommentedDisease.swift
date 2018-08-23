//
// Created by Артмеий Шлесберг on 23/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class CommentedDisease: Disease {

    private var origin: Disease
    let comment: String

    init(origin: Disease, comment: String) {
        self.origin = origin
        self.comment = comment
    }

    var name: String {
        return origin.name
    }
    var identification: String {
        return origin.identification
    }
    var isSelected: Variable<Bool> {
        return origin.isSelected
    }

    func select() {
        origin.select()
    }
}
