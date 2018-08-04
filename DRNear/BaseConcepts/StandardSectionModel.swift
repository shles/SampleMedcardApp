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
