//
//  Product.swift
//  ShoppingAI
//
//  Created by 김은찬 on 7/13/25.
//

import SwiftUI

struct Product: Identifiable, Equatable {
    let id: UUID
    var image: UIImage?
    var name: String
    var price: String
    var url: String
    var purchaseDesire: Int
    var usageContext: String
    var features: String
    var category: String

    // Equatable
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}
