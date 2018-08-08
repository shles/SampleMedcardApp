//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxSwift

class AuthorityFromAPI: Authority {

    private let tokenSubject = PublishSubject<Token>()
    private let authSubject = PublishSubject<Authority>()

    func wantsTFAuth() -> Observable<Authority> {
        return authSubject.asObservable()
    }

    func authenticated() -> Observable<Token> {
        return tokenSubject.asObservable()
    }

    func authWith(credentials: Credentials) {
        let session = URLSession()

        guard let url = URL(string: "http://eco-dev.siblion.ru:8080/auth/login") else {
            return
        }
        //TODO: insert actual credentials and add conditions obased on JWT - role
        let json: [String: Any] = [	"username": "admin",
                                       "password": "38Gjgeuftd!"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { [unowned self] data, response, error in
            guard let data = data, error == nil else {
                print(error)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            //TODO: decode JWT

            if let responseJSON = responseJSON as? [String: Any] {
                DispatchQueue.main.async {
                    self.tokenSubject.onNext(TokenFromString(string: responseJSON["access_token"] as? String ?? ""))
                }
            }
        }

        task.resume()
    }

    func confirm(code: String) {

    }
}
