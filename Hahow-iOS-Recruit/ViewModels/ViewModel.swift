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

}

protocol ViewModelOutput {

}

protocol ViewModelPrototype {
    var input: ViewModelInput { get }
    var output: ViewModelOutput { get }
}

// MARK: - View model

class ViewModel: ViewModelPrototype {

    var input: ViewModelInput { self }
    var output: ViewModelOutput { self }

    private let disposeBag = DisposeBag()
}

// MARK: - Input & Output

extension ViewModel: ViewModelInput {

}

extension ViewModel: ViewModelOutput {

}

// MARK: - Private function

private extension ViewModel {

}
