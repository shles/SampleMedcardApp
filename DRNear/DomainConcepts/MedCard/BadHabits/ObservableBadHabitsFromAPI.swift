//
// Created by Артмеий Шлесберг on 08/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift
import SwiftyJSON

class ObservableBadHabitsFromAPI: ObservableBadHabits, ObservableType {

    typealias E = [BadHabit]
    private let token: Token
    private let request: Request

    init(token: Token) throws {

        request = try AuthorizedRequest(
                path: "/eco-emc/api/medical-records/952/bad-habits",
                method: .get,
                token: token,
                parameters: ["type": "detached"],
                encoding: URLEncoding.default
        )
        self.token = token
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == [BadHabit] {
        return request.make()
                .map { json in

                    json.arrayValue.map { (json: JSON) in
                        BadHabitFrom(
                                name: json["name"].string  ?? "",
                                id: json["code"].string ?? "",
                                token: self.token
                        )
                    }
                }.subscribe(observer)
    }
}
