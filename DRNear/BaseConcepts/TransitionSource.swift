//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol TransitionSource {

    func wantsToPush() -> Observable<UIViewController>
    func wantsToPresent() -> Observable<UIViewController>
    func wantsToPop() -> Observable<Void>
    func wantsToBeDismissed() -> Observable<Void>

}
