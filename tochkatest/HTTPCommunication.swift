//
//  HTTPCommunication.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 26/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//

import Foundation

class HTTPCommunication: NSObject {
    var completionHandler: ((Data) -> Void)!
    
    let url: String
    let search: String?
    let language: String
    let newsType: NewsType
    let pageSize: Int
    let page: Int
    
    init(url: String,
         search: String?,
         language: String,
         newsType: NewsType = NewsType.top,
         pageSize: Int,
         page: Int) {
        
        self.url = url
        self.search = search
        self.language = language
        self.newsType = newsType
        self.pageSize = pageSize
        self.page = page
    }
    
    func retrieveURL(_ url: URL, completionHandler: @escaping ((Data) -> Void)) {
        self.completionHandler = completionHandler
        var request: URLRequest = URLRequest(url: url)
        request.addValue("cb07720519cc40d5bc51d2c8135d825e", forHTTPHeaderField: "x-api-key")
        let conf: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: conf, delegate: self, delegateQueue: nil)
        let task: URLSessionDownloadTask = session.downloadTask(with: request)
        task.resume()
    }
}

extension HTTPCommunication: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data: Data = try Data(contentsOf: location)
            DispatchQueue.main.async(execute: {
                self.completionHandler(data)
            })
        } catch {
            print("Can't get data from location.")
        }
    }
    
    func baseURL() -> String {
        return url + "\(newsType.rawValue)"
    }
    
    func buildURL() -> String {
        guard search != nil else {
            return "\(baseURL())?language=\(language)&pageSize=\(pageSize)&page=\(page)"
        }
        return "\(baseURL())?language=\(language)&pageSize=\(pageSize)&page=\(page)&q=\(search!)"
    }
}

enum NewsType: String {
    case everything = "everything"
    case top = "top-headlines"
    case sources = "sources"
}
