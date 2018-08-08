//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

@testable import DRNear
import Foundation
import Nimble
import Quick
import XCTest
import RxSwift

class AuthorizationTests: QuickSpec {

    override func spec() {
        describe("Authority") {
            var authority: Authority!
            var disposeBag: DisposeBag!
            var cred: Credentials!
            beforeEach {
                authority = SimpleAuthority()
                disposeBag = DisposeBag()
                cred = CredentialsFrom(login: "user", password: "1234")

            }
            it("returns token with 'admin' login") {

                cred = CredentialsFrom(login: "admin", password: "1234")
                var token: Token?

                authority.authenticated().subscribe(onNext: {
                    token = $0
                }).disposed(by: disposeBag)
                authority.authWith(credentials: cred)
                expect(token != nil).to(be(true))
            }
            context("with other login") {
                it("asks to confirm code") {

                    var authToConfirm: Authority?

                    authority.wantsTFAuth().subscribe(onNext: {
                        authToConfirm = $0
                    }).disposed(by: disposeBag)
                    authority.authWith(credentials: cred)
                    expect(authToConfirm != nil).to(be(true))
                }
                it("auth's after confirmation") {
                    var token: Token?

                    authority.authenticated().subscribe(onNext: {
                        token = $0
                    }).disposed(by: disposeBag)
                    authority.confirm(code: "1234")
                    expect(token != nil).to(be(true))
                }
            }
        }
    }
}
