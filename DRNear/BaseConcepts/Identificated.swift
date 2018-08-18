//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxDataSources

protocol Identified {

    var identification: String { get }

    func isEqual(to other: Identified) -> Bool

}

extension Identified {

    func isEqual(to other: Identified) -> Bool {
        return self.identification == other.identification
    }

}
