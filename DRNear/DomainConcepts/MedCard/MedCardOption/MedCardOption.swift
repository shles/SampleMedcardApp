//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import UIKit
import RxSwift

protocol MedCardOption: Named, TransitionSource, ContainingImage, Interactive {

    var gradientColors: [UIColor] { get }

}
