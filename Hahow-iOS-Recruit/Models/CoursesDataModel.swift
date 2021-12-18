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
    case design = "design"
    case language = "language"
    case music = "music"
    case programming = "programming"
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
