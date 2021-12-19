//
//  CoursesDataModel.swift
//  Hahow-iOS-Recruit
//
//  Created by Fish Shih on 2021/12/19.
//

import Foundation

// MARK: - CoursesDataModel

struct CoursesDataModel: Codable {
    let data: [CategoryItem]
}

// MARK: - CategoryItem

struct CategoryItem: Codable {
    let category: Category
    let courses: [Course]
}

enum Category: String, Codable {

    case programming = "programming"
    case language = "language"
    case design = "design"
    case music = "music"

    var title: String {
        switch self {
        case .programming:
            return "程式"
        case .language:
            return "語言"
        case .design:
            return "設計"
        case .music:
            return "音樂"
        }
    }
}

// MARK: - Course

struct Course: Codable {

    let title: String
    let coverImageURL: String
    let name: String
    let category: Category

    enum CodingKeys: String, CodingKey {
        case title
        case coverImageURL = "coverImageUrl"
        case name, category
    }
}
