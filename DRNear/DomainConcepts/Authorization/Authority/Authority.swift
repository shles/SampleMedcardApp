//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

protocol Authority {

    func wantsTFAuth() -> Observable<Authority>
    func authenticate() -> Observable<Token>

    func authWith(credentials: Credentials)

    func confirm(code: String)

}
