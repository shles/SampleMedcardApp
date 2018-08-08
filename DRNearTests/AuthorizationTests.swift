//
// Created by Артмеий Шлесберг on 06/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble
@testable import DRNear

class AuthorizationTests: QuickSpec {

    override func spec() {
        describe("Authority") {
            var authority: Authority!
            beforeEach {
                authority = SimpleAuthority()
            }
            it("returns token with 'admin' login") {
                
                let cred = CredentialsFrom(login: "admin", password: "1234")
                var token: Token?
                
                authority.authenticated().subscribe(onNext: {
                    token = $0
                })
                authority.authWith(credentials: cred)
                expect(token != nil).to(be(true))
            }
            context("with other login") {
                
                let cred = CredentialsFrom(login: "user", password: "1234")
                
                it("asks to confirm code"){
                    
                    var authToConfirm: Authority?

                    authority.wantsTFAuth().subscribe(onNext: {
                        authToConfirm = $0
                    })
                    authority.authWith(credentials: cred)
                    expect(authToConfirm != nil).to(be(true))
                }
                it("auth's after confirmation") {
                    var token: Token?
                    
                    authority.authenticated().subscribe(onNext: {
                        token = $0
                    })
                    authority.confirm(code: "1234")
                    expect(token != nil).to(be(true))
                }
            }
        }
    }
}
