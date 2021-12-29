//
//  Trailer.swift
//  Movies
//
//  Created by Robert Dodson on 12/28/21.
//

import Foundation
import XMLMapper

class TrailerList : XMLMappable
{
    var nodeName: String!

    var trailers: [Trailer]?

    required init?(map: XMLMap) {}

    func mapping(map: XMLMap)
    {
        trailers <- map["movieinfo"]
    }
}


class Trailer: XMLMappable
{
    var nodeName    : String!
    
    var title       : String!
    var runtime     : String!
    var rating      : String!
    var studio      : String!
    var postDate    : String!
    var releaseDate : String!
    var copyright   : String!
    var director    : String!
    var description : String!
    var cast        : String!
    var genre       : String!
    var poster      : String!
    var largePoster : String!
    var preview     : String!
    
    
    required init?(map: XMLMap) {}

    
    func mapping(map: XMLMap)
    {
        nodeName <- map["name"]
        
        title       <- map["title"]
        runtime     <- map["runtime"]
        rating      <- map["rating"]
        studio      <- map["studio"]
        postDate    <- map["postDate"]
        releaseDate <- map["releaseDate"]
        copyright   <- map["copyright"]
        director    <- map["director"]
        description <- map["description"]
        cast        <- map["cast"]
        genre       <- map["genre"]
        poster      <- map["poster.location"]
        largePoster <- map["poster.xlarge"]
        preview     <- map["preview"]
    }
}
