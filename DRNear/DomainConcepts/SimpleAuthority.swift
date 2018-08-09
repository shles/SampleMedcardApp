//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class SimpleAuthority: Authority {

    private let authSubject = PublishSubject<Void>()
    private let codeSubject = PublishSubject<Void>()

    func wantsTFAuth() -> Observable<Authority> {
        return codeSubject.asObservable().map { self }
    }

    func authenticate() -> Observable<Token> {
        return authSubject.asObservable().map { EmptyToken() }
    }

    func authWith(credentials: Credentials) {
        if credentials.login == "admin" {
            authSubject.onNext(())
        } else {
            codeSubject.onNext(())
        }
    }

    func confirm(code: String) {
        authSubject.onNext(())
    }
}
