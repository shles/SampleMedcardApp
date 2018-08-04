//
// Created by Артмеий Шлесберг on 03/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation

protocol Applicable {

    associatedtype ApplicationTargetType

    func apply(target: ApplicationTargetType)

}