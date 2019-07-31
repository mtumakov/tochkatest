//
//  Item.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 26/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//

import Foundation

struct Item {
    let title: String
    let content: String
    let imageLink: String?
    
    init(title: String, content: String, imageLink: String? = nil) {
        self.title = title
        self.content = content
        self.imageLink = imageLink
    }
}

class ItemArray {
    var arr: [Item]
    
    init(arr: [Item] = []) {
        self.arr = arr
    }
    
    public func add(_ item: Item) {
        for (index, element) in arr.enumerated() {
            if (element.title == item.title) {
                arr.remove(at: index)
            }
        }
        arr.append(item)
    }
    
    public func addAll(array: [Item]) {
        for item in array {
            add(item)
        }
    }
    
    public func remove(with title: String) {
        for (index, element) in arr.enumerated() {
            if element.title == title {
                arr.remove(at: index)
            }
        }
    }
}
