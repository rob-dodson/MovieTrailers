//
//  Model.swift
//  Movies
//
//  Created by Robert Dodson on 12/30/21.
//

import Foundation
import AppKit

class Model: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate
{
    var trailers : Array<Trailer>!
    var tempImage : NSImage!
    var controller : ViewController!
    var fontsmall  : NSFont!
    var fontmed  : NSFont!
    var fontlarge  : NSFont!
    var cache : NSCache<NSString,NSImage>!

    
    func setup(list:Array<Trailer>,controller:ViewController)
    {
        self.trailers = list
        self.controller = controller
        
        cache = NSCache()
        tempImage = NSImage(named:"temp")
        fontsmall = NSFont(name: "Helvetica Neue Condensed Bold", size: 13.0)
        fontmed = NSFont(name: "Helvetica Neue Condensed Bold", size: 14.0)
        fontlarge = NSFont(name: "Helvetica Neue Condensed Bold", size: 15.0)
    
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return trailers.count
    }
    

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dataSourceItem"), for: indexPath) as! trailerViewItem
        
        let trailer = trailers[indexPath.item]
        item.text.stringValue = trailer.title
        
        let splitcount = trailer.title.split(separator: " ").count
        if splitcount >=  4 && splitcount < 6
        {
            item.text.font = fontsmall
        }
        else if splitcount >= 6
        {
            item.text.font = fontmed
        }
        else
        {
            item.text.font = fontlarge
        }
        
        let image = cache.object(forKey: trailer.title as NSString)
        if image != nil
        {
            item.image.image = image
        }
        else
        {
            item.image.image = nil
            
            DispatchQueue.global(qos: .userInitiated).async
            {
                let image = NSImage(contentsOf: URL(string: trailer.poster)!)
                let key = trailer.title as NSString
                self.cache.setObject(image!, forKey: key)

                DispatchQueue.main.async
                {
                    item.image.image = image
                }
            }
        }
        return item
    }

    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>)
    {
        let trailer = trailers[indexPaths.first!.item]
        controller.play(trailer: trailer)
    }
}
