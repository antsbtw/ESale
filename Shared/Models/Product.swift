//
//  Product.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//

import Foundation

// MARK: - Product Model
struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let code: String
    let description: String
    let iconUrl: String?
    let isActive: Bool
    let createdAt: String?
    let updatedAt: String?
}

// MARK: - Product Create/Update Request
struct ProductRequest: Codable {
    let id: String?
    let name: String
    let code: String
    let description: String
    let iconUrl: String?
}
