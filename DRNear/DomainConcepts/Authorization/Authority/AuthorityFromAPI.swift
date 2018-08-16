//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import JWTDecode
import RxSwift

//TODO: redisign completly

class AuthorityFromAPI: Authority {

    private let authSubject = PublishSubject<Authority>()
    private let tokenSubject = PublishSubject<Token>()

    private var credentials = Variable<Credentials>.init(CredentialsFrom(login: "", password: ""))

    func wantsTFAuth() -> Observable<Authority> {
        return authSubject.asObservable()
    }

    func authenticate() -> Observable<Token> {

        return Observable.merge([
            credentials.asObservable().skip(1)
                .flatMap { credentials in
            Observable.create { [unowned self] observer in

            guard let url = URL(string: "http://eco-dev.siblion.ru:8080/auth/login") else {
                observer.onError(ResponseError())
                return Disposables.create()
            }

            var headers = ["Content-Type": "application/json;charset=UTF-8"]
            if let xsrf = UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
                headers["X-XSRF-TOKEN"] = xsrf
            } else {
                self.clear()
            }

            Alamofire.request(url,
                              method: .post,
                              parameters: [ "username": credentials.login,
                                            "password": credentials.password],
                              encoding: JSONEncoding.default,
                              headers: headers)
                .responseData(completionHandler: { response in
                    guard let data = response.data, response.error == nil else {
                        print(response.error)
                        observer.onError(ResponseError())
                        return
                    }

                    if let response = response.response, let fields = response.allHeaderFields as? [String: String] {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response.url!)

                        HTTPCookieStorage.shared.setCookies(cookies, for: response.url, mainDocumentURL: nil)
                        for cookie in cookies {
                            var cookieProperties = [HTTPCookiePropertyKey: Any]()
                            cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
                            cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
                            cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain
                            cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
                            cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version)
                            cookieProperties[HTTPCookiePropertyKey.expires] = NSDate().addingTimeInterval(31_536_000)

                            let newCookie = HTTPCookie(properties: cookieProperties)
                            HTTPCookieStorage.shared.setCookie(newCookie!)

                            if cookie.name == "XSRF-TOKEN" {
                                UserDefaults.standard.set(cookie.value, forKey: "X-XSRF-TOKEN")
                            }
                            print("name: \(cookie.name) value: \(cookie.value)")
                        }
                    }

                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

                    if let responseJSON = responseJSON as? [String: Any] {
                        if let token = responseJSON["access_token"] as? String {
                            let jwt = try? decode(jwt: token)
                            if let authorities = jwt?.body["authorities"] as? [String] {
                                if let _ = authorities.first(where: { $0 == "ROLE_USER" }) {
//                                    DispatchQueue.main.async {
                                        observer.onNext(TokenFromString(string: token))
//                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.authSubject.onNext(self)
                                    }
                                }
                            }
                        } else {
                            observer.onError(ResponseError())
                        }
                    }
                })
            return Disposables.create()
        }
       .do(onError: { _ in
            let cookieStore = HTTPCookieStorage.shared
        if let cookie = cookieStore.cookies?.first(where: { $0.name == "XSRF-TOKEN" }), cookie.value != UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
            for cookie in cookieStore.cookies ?? [] {
                cookieStore.deleteCookie(cookie)
            }
            UserDefaults.standard.set(nil, forKey: "X-XSRF-TOKEN")
        }
        }).retry(2)
        },
            tokenSubject.asObservable()])
    }

    func clear() {
        let cookieStore = HTTPCookieStorage.shared
        for cookie in cookieStore.cookies ?? [] {
            cookieStore.deleteCookie(cookie)
        }
        UserDefaults.standard.set(nil, forKey: "X-XSRF-TOKEN")
    }

    func authWith(credentials: Credentials) {

        self.credentials.value = credentials

    }

    func confirm(code: String) {

        guard let url = URL(string: "http://eco-dev.siblion.ru:8080/auth/login") else {
            return
        }

        var headers = ["Content-Type": "application/json;charset=UTF-8"]
        if let xsrf = UserDefaults.standard.string(forKey: "X-XSRF-TOKEN") {
            headers["X-XSRF-TOKEN"] = xsrf
        }

        Alamofire.request(url,
                          method: .post,
                          parameters: [ "username": credentials.value.login,
                                        "password": credentials.value.password,
                                        "code": code],
                          encoding: JSONEncoding.default,
                          headers: headers)
            .responseData(completionHandler: { response in
                guard let data = response.data, response.error == nil else {
                    print(response.error)
                    return
                }

                if let response = response.response, let fields = response.allHeaderFields as? [String: String] {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response.url!)

                    HTTPCookieStorage.shared.setCookies(cookies, for: response.url, mainDocumentURL: nil)
                    for cookie in cookies {
                        var cookieProperties = [HTTPCookiePropertyKey: Any]()
                        cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
                        cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
                        cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain
                        cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
                        cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version)
                        cookieProperties[HTTPCookiePropertyKey.expires] = NSDate().addingTimeInterval(31_536_000)

                        let newCookie = HTTPCookie(properties: cookieProperties)
                        HTTPCookieStorage.shared.setCookie(newCookie!)

                        print("name: \(cookie.name) value: \(cookie.value)")
                    }
                }

                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])

                if let responseJSON = responseJSON as? [String: Any] {
                    let token = responseJSON["access_token"] as? String ?? ""
                    let jwt = try? decode(jwt: token)
                    if let authorities = jwt?.body["authorities"] as? [String] {
                        if let _ = authorities.first(where: { $0 == "ROLE_USER" }) {
                            DispatchQueue.main.async {
                                self.tokenSubject.onNext(TokenFromString(string: token))
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.authSubject.onNext(self)
                            }
                        }
                    }
                }
            })
    }
}
