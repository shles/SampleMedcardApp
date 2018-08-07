//
// Created by Артмеий Шлесберг on 07/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation

class CredentialsFrom: Credentials {

    let login: String
    let password: String

    init(login: String, password: String) {
        self.login = login
        self.password = password
    }

}
