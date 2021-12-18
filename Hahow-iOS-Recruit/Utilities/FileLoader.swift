//
//  FileLoader.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import Foundation

struct FileLoader {

    /// Failure
    enum Failure: Error {
        case invaildURL
        case decodeFail(Error)
    }

    static func load(
        from bundle: Bundle = .main,
        name: String,
        ext: String,
        _ complete: @escaping (Result<Data, Failure>) -> Void
    ) {

        DispatchQueue.global(qos: .default).async {

            guard
                let url = bundle.url(forResource: name, withExtension: ext)
            else {
                complete(.failure(.invaildURL))
                return
            }

            do {
                let data = try Data(contentsOf: url)
                complete(.success(data))
                return
            } catch {
                complete(.failure(.invaildURL))
                return
            }
        }
    }

    static func load<T: Decodable>(
        from bundle: Bundle = .main,
        name: String,
        ext: String,
        decoder: JSONDecoder = JSONDecoder(),
        _ complete: @escaping (Result<T, Failure>) -> Void
    ) {

        load(from: bundle, name: name, ext: ext) {

            let result = $0
                .flatMap { data -> Result<T, Failure> in
                    Result {
                        try decoder.decode(T.self, from: data)
                    }
                    .mapError {
                        Failure.decodeFail($0)
                    }
                }

            complete(result)
        }
    }
}
