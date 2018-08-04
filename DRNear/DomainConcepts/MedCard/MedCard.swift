//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol MedCard {

    var options: Observable<MedCardOptions> { get }

}
