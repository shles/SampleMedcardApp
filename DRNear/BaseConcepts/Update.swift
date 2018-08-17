//
// Created by Артмеий Шлесберг on 14/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol Update: TransitionSource {

    func addItem(item: Identified)

    func apply()

}

