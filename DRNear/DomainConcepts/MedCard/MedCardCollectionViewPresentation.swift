//
// Created by Артмеий Шлесберг on 02/08/2018.
// Copyright (c) 2018 Shlesberg. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import UIKit
import RxCocoa

class MedCardCollectionViewPresentation: NSObject, Presentation, UICollectionViewDelegateFlowLayout {

    var view: UIView {
        return collectionView
    }

    private let collectionView: UICollectionView
    private let disposeBag = DisposeBag()
    private let wantsToPushSubject = PublishSubject<UIViewController>()
    private let medCardOptions: ObservableMedCardOptions

    init(medCardOptions: ObservableMedCardOptions) {

        self.medCardOptions = medCardOptions

        let layout = UICollectionViewFlowLayout()

        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init()

        let dataSource = RxCollectionViewSectionedReloadDataSource<StandardSectionModel<MedCardOption>>(
                configureCell: { ds, cv, ip, option in
                    let cell = cv.dequeueReusableCellOfType(MedCardOptionCollectionViewCell.self, for: ip)
                    MedCardOptionApplicableToCollectionViewCell(origin: option).apply(target: cell)
                    return cell
        })

        self.medCardOptions.asObservable()
            .map {
                [StandardSectionModel(items: $0.options)]
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(MedCardOption.self)
            .subscribe(onNext: { option in
                option.interact()
            })
            .disposed(by: disposeBag)
        
        self.medCardOptions.asObservable()
            .flatMap {
                Observable.merge($0.options.map { $0.wantsToPush().debug() })
            }
            .bind(to: wantsToPushSubject)
            .disposed(by: disposeBag)

        collectionView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        collectionView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        collectionView.backgroundColor = .white

    }

    func wantsToPush() -> Observable<UIViewController> {
        return wantsToPushSubject.asObservable()
    }

    func wantsToPresent() -> Observable<UIViewController> {
        return Observable<UIViewController>.never()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.0 - 16, height: 184)
    }
    
}
