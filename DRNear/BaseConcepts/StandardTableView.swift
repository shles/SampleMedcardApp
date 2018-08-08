//
//  StandardTableView.swift
//  DiscountMarket
//
//  Created by Timofey on 5/31/17.
//  Copyright © 2017 Jufy. All rights reserved.
//

import RxSwift
import UIKit

class StandardTableView: UITableView {

    private let disposeBag = DisposeBag()

    init(style: UITableViewStyle = .plain, footerView: UIView? = UIView(frame: .zero)) {
        super.init(frame: .zero, style: style)
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = 55
        separatorInset = .init(top: 0, left: 16, bottom: 0, right: 0)
        separatorColor = .shadow

        rx.itemSelected.subscribe(onNext: { [unowned self] ip in
            self.deselectRow(at: ip, animated: true)
        }).disposed(by: disposeBag)

        tableFooterView = footerView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
