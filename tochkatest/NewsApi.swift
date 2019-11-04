//
//  NewsApi.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 04.11.2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//

import Foundation

class NewsApi: NSObject {
    var completionHandler: ((Data) -> Void)!
    let code = "cb07720519cc40d5bc51d2c8135d825e"
    
    func retrieveURL(_ url: URL, completionHandler: @escaping ((Data) -> Void)) {
        self.completionHandler = completionHandler
        var request: URLRequest = URLRequest(url: url)
        request.addValue(code, forHTTPHeaderField: "x-api-key")
        let conf: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: conf, delegate: self, delegateQueue: nil)
        let task: URLSessionDownloadTask = session.downloadTask(with: request)
        task.resume()
    }
    
}

extension NewsApi: URLSessionDownloadDelegate {
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
}
