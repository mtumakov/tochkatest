//
//  Item.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 26/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//

import Foundation

struct Item: Decodable {
    let title: String
    let description: String
    let urlToImage: URL?
    let publishedAt: Date
    
    init(title: String, description: String, urlToImage: URL?, publishedAt: Date) {
        self.title = title
        self.description = description
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
    }
}
