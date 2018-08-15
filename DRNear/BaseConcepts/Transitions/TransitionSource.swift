//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import UIKit



protocol TransitionSource {

    func wantsToPerform() -> Observable<Transition>

}
