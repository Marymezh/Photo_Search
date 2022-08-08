//
//  APIResponse.swift
//  Images_Collection
//
//  Created by Мария Межова on 08.08.2022.
//

import Foundation

struct APIResponse: Codable {
    let results: [Result]
}

struct Result: Codable {
    let urls: URLS
}

struct URLS: Codable {
    let regular: String
}
