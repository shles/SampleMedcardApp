//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation

protocol MedCardOptions {

    var options: [MedCardOption] { get }

}

class SimpleMedCardOptions: MedCardOptions {
    var options: [MedCardOption] = [SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),
                                    SimpleMedCardOption(),]
    
}
