//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Selectable {
    var isSelected: Observable<Bool> { get }

    func select()
}
