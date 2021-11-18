//
//  XWDTItem.swift
//  ITSC
//
//  Created by 严思远 on 2021/11/17.
//

import UIKit

class ListItem: NSObject, Encodable, Decodable {
    var title: String
    var date: String
    var link: URL
    
    init(title: String, date: String, link: URL) {
        self.title = title
        self.date = date
        self.link = link
    }
}
