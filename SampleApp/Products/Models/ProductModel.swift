//
//  ProductModel.swift
//  SampleApp
//
//  Created by Daniel Marco Rafanan on 8/25/22.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let productModel = try? newJSONDecoder().decode(ProductModel.self, from: jsonData)

import Foundation

// MARK: - ProductModel
struct ProductModel: Codable {
    var products: [Product]?
    var total, skip, limit: Int?
}

// MARK: - Product
struct Product: Codable {
    var id: Int?
    var title, productDescription: String?
    var price: Int?
    var discountPercentage, rating: Double?
    var stock: Int?
    var brand, category: String?
    var thumbnail: String?
    var images: [String]?

    enum CodingKeys: String, CodingKey {
        case id, title
        case productDescription
        case price, discountPercentage, rating, stock, brand, category, thumbnail, images
    }
}

