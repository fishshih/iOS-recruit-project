//
//  CoursesDataLoader.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/20.
//

import Foundation
import RxSwift
import RxCocoa

protocol CoursesDataLoaderPrototype {

    var result: Observable<CoursesDataModel> { get }

    func load()
}

struct CoursesDataLoader: CoursesDataLoaderPrototype {
    
    var result: Observable<CoursesDataModel> {
        _result.asObservable()
    }

    func load() {

        FileLoader
            .load(name: "data", ext: "json") {
                (result: Result<CoursesDataModel, FileLoader.Failure>) in

                switch result {
                case .success(let model):
                    self._result.accept(model)
                case .failure(let failure):
                    print("😎 fileLoader failure = ", failure)
                }
            }
    }

    // MARK: Private

    private let _result = PublishRelay<CoursesDataModel>()
}
