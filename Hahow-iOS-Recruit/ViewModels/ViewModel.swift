// 
//  ViewModel.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Prototype

protocol ViewModelInput {

    // 此案例中，沒有 input 互動需求

    // 案例：
    // func reloadData()
    // func didSelected(course: Course)
}

protocol ViewModelOutput {
    var coursesData: Observable<CoursesDataModel?> { get }
}

protocol ViewModelPrototype {

    // 將功能拆解為 input & output
    // 在 viewController 使用時
    // 便可限制於僅透過 viewModel.input or viewModel.output
    // 也可方便未來以 mock 作測試

    var input: ViewModelInput { get }
    var output: ViewModelOutput { get }
}

// MARK: - View model

class ViewModel: ViewModelPrototype {

    var input: ViewModelInput { self }
    var output: ViewModelOutput { self }

    // 以 protocol 形式宣告，為未來測試提供靈活性
    init(dataLoader: CoursesDataLoaderPrototype?) {

        self.dataLoader = dataLoader

        guard let dataLoader = self.dataLoader else { return }

        bind(dataLoader: dataLoader)
    }

    private var dataLoader: CoursesDataLoaderPrototype?

    private let data = BehaviorRelay<CoursesDataModel?>(value: nil)

    private let disposeBag = DisposeBag()
}

// MARK: - Input & Output

extension ViewModel: ViewModelInput { }

extension ViewModel: ViewModelOutput {

    var coursesData: Observable<CoursesDataModel?> {
        data.asObservable()
    }
}

// MARK: - Private function

private extension ViewModel {

    func bind(dataLoader: CoursesDataLoaderPrototype) {

        dataLoader
            .result
            .bind(to: data)
            .disposed(by: disposeBag)

        dataLoader.load()
    }
}
