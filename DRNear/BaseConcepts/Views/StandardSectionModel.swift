//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxDataSources

struct StandardSectionModel<T>: SectionModelType {
    var items: [T]

    init(original: StandardSectionModel<T>, items: [T]) {
        self = original
        self.items = items
    }

    init(items: [T]) {
        self.items = items
    }

}

struct SingleAnimatedSectionModel<ItemType: IdentifiableType & Equatable>: AnimatableSectionModelType {

    typealias Item = ItemType

    let items: [Item]

    init(original: SingleAnimatedSectionModel, items: [Item]) {
        self.identity = original.identity
        self.items = items
    }

    init(items: [Item]) {
        self.identity = 0
        self.items = items
    }

    let identity: Int
}
