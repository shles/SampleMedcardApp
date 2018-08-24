//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

@testable import DRNear
import Foundation
import Nimble
import Quick
import RxSwift
import XCTest

//swiftlint:disable all
class SimpleAuthorizationTests: QuickSpec {

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

                authority.authenticate().subscribe(onNext: {
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

                    authority.authenticate().subscribe(onNext: {
                        token = $0
                    }).disposed(by: disposeBag)
                    authority.confirm(code: "1234")
                    expect(token != nil).to(be(true))
                }
            }
        }
    }
}

class APIAuthorizationTests: QuickSpec {

    override func spec() {
        describe("Authority") {
            var authority: Authority!
            var disposeBag: DisposeBag!
            var cred: Credentials!
            beforeEach {
                authority = AuthorityFromAPI()
                disposeBag = DisposeBag()
                cred = CredentialsFrom(login: "user", password: "SinlionBest!")

            }
            it("returns token with 'admin' login") {

                cred = CredentialsFrom(login: "admin", password: "38Gjgeuftd!")

                authority.authWith(credentials: cred)

                 XCTAssertNil(try? authority.authenticate().toBlocking(timeout: 5).first())
            }
            context("with other login") {
                it("asks to confirm code") {

                    authority.authWith(credentials: cred)
                    XCTAssertNil(try? authority.wantsTFAuth().toBlocking(timeout: 5).first())
                }
                it("auth's after confirmation") {

                    authority.confirm(code: "0114")
                    XCTAssertNil(try? authority.authenticate().toBlocking(timeout: 5).first())

                }
            }
        }
    }
}
//swiftlint:enable all
