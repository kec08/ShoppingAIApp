//
//  Bundle+Secrets.swift
//  ShoppingAI
//
//  Created by 김은찬 on 7/14/25.
//

import Foundation

extension Bundle {
    var openAIKey: String {
        guard let url = self.url(forResource: "Secretss", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let key = plist["OPENAI_API_KEY"] as? String else {
            fatalError("Secretss.plist에 OPENAI_API_KEY가 없거나 로드에 실패했습니다.")
        }
        return key
    }
}


