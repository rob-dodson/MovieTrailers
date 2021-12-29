//
//  Trailer.swift
//  Movies
//
//  Created by Robert Dodson on 12/28/21.
//

import Foundation
import XMLMapper

class Trailer: XMLMappable
{
    
    var nodeName: String!
    var name: String!
    var rating: String!
    var description: String?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap)
    {
        name <- map["name"]
        rating <- map["rating"]
        description <- map["description"]
    }
}
