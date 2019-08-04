//
//  ApiCommunication.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 31/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//

import Foundation
import UIKit

class ApiComunication {
    let endObject: EndOfLoad
    
    init(end: EndOfLoad) {
        self.endObject = end
    }
    
    func sendRequest(pageSize: Int, page: Int, activityView: UIActivityIndicatorView) {
        let string = buildURL(baseURL: "https://newsapi.org/v2/top-headlines", pageSize: pageSize, page: page)
        guard let url = URL(string: string) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("cb07720519cc40d5bc51d2c8135d825e", forHTTPHeaderField: "x-api-key")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in

            guard error == nil else {
                print(error?.localizedDescription ?? "no desc")
                return
            }
            DispatchQueue.main.async {
                activityView.startAnimating()
            }
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            guard let newsInfo = try? decoder.decode(JsonResponse.self, from: data) else {
                print("Cant't parse json")
                return
            }
            print(newsInfo.articles)
            DispatchQueue.main.async {
                let dbOperations = DBOperations()
                if (newsInfo.articles.count == 0) {
                    self.endObject.isOver(value: true)
                }
                dbOperations.saveItems(itemArray: newsInfo.articles)
                activityView.stopAnimating()
            }
        }
        task.resume()
    }
    
    private func buildURL(baseURL: String, pageSize: Int, page: Int) -> String {
        return "\(baseURL)?language=RU&pageSize=\(pageSize)&page=\(page)"
    }
}

class JsonResponse: Decodable {
    let articles: [Item]
    var totalResults: Int
    
    public func setTotalResults(results: Int) {
        self.totalResults = results
    }
}

class EndOfLoad {
    var isOver: Bool = false
    
    public func isOver(value: Bool) {
        self.isOver = value
    }
}
