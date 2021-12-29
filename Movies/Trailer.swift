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
        genre       = map["genre"]["name"][0].element!.text
        poster      = map["poster"]["location"].element!.text
        largePoster = map["poster"]["xlarge"].element!.text
        preview     = map["preview"]["large"].element!.text
        
        cast = String()
        var loop = 0
        for member in map["cast"]["name"].all
        {
            if cast.count > 0 && loop < cast.count
            {
                cast = cast + ", "
            }
            cast = cast + member.element!.text
            loop = loop + 1
            if loop > 5
            {
                break;
            }
        }
    }
    
    
    func mapinfo(map: XMLIndexer)
    {
       title       = map["title"].element!.text
       rating      = map["rating"].element!.text
       studio      = map["studio"].element!.text
       postDate    = map["postdate"].element!.text
       copyright   = map["copyright"].element!.text
       director    = map["director"].element!.text
       description = map["description"].element!.text
        
        let time = map["runtime"].element!.text
        let parts = time.split(separator:":")
        runtime = String(parts[0]) + " hr " + String(parts[1]) + " min"
        
        let date = map["releasedate"].element!.text
        let parts1 = date.split(separator:"-")
        releaseDate = String(parts1[0])
   }
}
