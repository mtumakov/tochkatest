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
    let publishedAt: String
    let time: Double?
    
    init(title: String, description: String, urlToImage: URL?, at: String, time: Double? = 0) {
        self.title = title
        self.description = description
        self.urlToImage = urlToImage
        self.publishedAt = at
        self.time = time
    }
    
    /*
     Возвращает дату в формате миллисекунд с 1970 года для сортировки списка по времени
     newsapi.org может возвращать дату в трех форматах
     @string - текстовое значение даты
     */
    func getDate(from string: String) -> Double {
        let formatter = DateFormatter()
        var stringDate = string
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if stringDate.contains("+") {
            stringDate = stringDate.substring(to: stringDate.firstIndex(of: "+")!)
            stringDate.append("Z")
        } else if stringDate.contains(".") {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        }
        print("stringDate - \(stringDate)")
        return formatter.date(from: stringDate)!.timeIntervalSince1970
    }
}
