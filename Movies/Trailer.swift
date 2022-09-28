//
//  Trailer.swift
//  Movies
//
//  Created by Robert Dodson on 12/28/21.
// 
// can be inited from json Decodable or from xml via mapdata() and mapinfo()
//

import Foundation

import SWXMLHash

struct preview : Decodable
{
    var postdate : String!
    var url      : String!
    var type     : String!
    var exclusive : Bool
    var hd        : Bool
}


class Trailer : Decodable
{
    var title       : String!
    var runtime     : String!
    var rating      : String!
    var studio      : String!
    var postdate    : String!
    var releasedate : String!
    var copyright   : String!
    var directors   : String!
    var location    : String!
    var description : String!
    var actors      : [String]!
    var genre       : [String]!
    var poster      : String!
    var poster_2x   : String!
    var preview     : String!
    var moviesite   : String!
    var trailers    : [preview]!
    
    
    func mapdata(map: XMLIndexer)
    {
        poster      = map["poster"]["location"].element!.text
        poster_2x = map["poster"]["xlarge"].element!.text
        preview     = map["preview"]["large"].element!.text
        
        actors = Array<String>()
        var loop = 0
        for member in map["cast"]["name"].all
        {
            actors.append(member.element!.text)
            loop = loop + 1
        }
        
        genre = Array<String>()
        loop = 0
        for genrename in map["genre"]["name"].all
        {
            genre.append(genrename.element!.text)
            loop = loop + 1
        }
    }
    
    
    func mapinfo(map: XMLIndexer)
    {
       title       = map["title"].element!.text
       rating      = map["rating"].element!.text
       studio      = map["studio"].element!.text
       postdate    = map["postdate"].element!.text
       copyright   = map["copyright"].element!.text
       directors   = map["director"].element!.text
       description = map["description"].element!.text
        
        let time = map["runtime"].element!.text
        let parts = time.split(separator:":")
        runtime = String(parts[0]) + " hr " + String(parts[1]) + " min"
        
        let date = map["releasedate"].element!.text
        if (date.count > 3)
        {
            let parts1 = date.split(separator:"-")
            releasedate = String(parts1[0])
        }
        else
        {
            releasedate  = " - "
        }
   }
    
    
    func makePosterURL(big:Bool) -> URL
    {
        var url : URL!
        
        if let posterString = (big == true) ? poster_2x : poster
        {
            if posterString.hasPrefix("/trailers")
            {
                url = URL(string: "https://trailers.apple.com/" + posterString)!
            }
            else
            {
                url = URL(string: posterString)!
            }
        }
        
        return url
    }

}

