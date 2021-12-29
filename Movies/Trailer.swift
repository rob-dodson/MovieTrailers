//
//  Trailer.swift
//  Movies
//
//  Created by Robert Dodson on 12/28/21.
//

import Foundation

import SWXMLHash


class Trailer
{
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
    
    
    func mapdata(map: XMLIndexer)
    {
        cast        = map["cast"].element!.text
        genre       = map["genre"].element!.text
        poster      = map["poster"]["location"].element!.text
        largePoster = map["poster"]["xlarge"].element!.text
        preview     = map["preview"]["large"].element!.text
    }
    
    
    func mapinfo(map: XMLIndexer)
    {
       title       = map["title"].element!.text
       runtime     = map["runtime"].element!.text
       rating      = map["rating"].element!.text
       studio      = map["studio"].element!.text
       postDate    = map["postdate"].element!.text
       releaseDate = map["releasedate"].element!.text
       copyright   = map["copyright"].element!.text
       director    = map["director"].element!.text
       description = map["description"].element!.text
      
   }
}
