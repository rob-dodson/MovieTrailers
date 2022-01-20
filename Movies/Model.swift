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
    var visibletrailers : Array<Trailer>!
    var tempImage : NSImage!
    var controller : ViewController!
    var fontsmall  : NSFont!
    var fontmed  : NSFont!
    var fontlarge  : NSFont!
    var cache : NSCache<NSString,NSImage>!
    
    func setup(list:Array<Trailer>,controller:ViewController)
    {
        self.trailers = list
        
        visibletrailers = Array<Trailer>()
        for trailer in trailers
        {
            visibletrailers.append(trailer)
        }
        
        self.controller = controller
        
        cache = NSCache()
        
        
        tempImage = NSImage(named:"temp")
        fontsmall = NSFont(name: "Helvetica Neue Condensed Bold", size: 13.0)
        fontmed = NSFont(name: "Helvetica Neue Condensed Bold", size: 14.0)
        fontlarge = NSFont(name: "Helvetica Neue Condensed Bold", size: 15.0)
    }
    
    
    func search(searchString:String)
    {
        visibletrailers = Array<Trailer>()
        for trailer in trailers
        {
            if trailer.title.uppercased().contains(searchString.uppercased()) || searchString == ""
            {
                visibletrailers.append(trailer)
            }
        }
        
        controller.collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return visibletrailers.count
    }
    

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
    {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dataSourceItem"), for: indexPath) as! trailerViewItem
        let trailer = visibletrailers[indexPath.item]
        
       
		//
		// adjust font size for title if too long. 
		// Just based on word count, not too smart.
		//
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
        

		//
		// poster image from cache or load the url
		//
        let image = cache.object(forKey: trailer.title as NSString)
        if image != nil
        {
            item.image.image = image
        }
        else
        {
            item.image.image = nil
            
			//
			// background load of poster image
			//
            DispatchQueue.global(qos: .userInitiated).async
            {
                var url : URL
                
                if ftrailer.poster.hasPrefix("/trailers")
                {
                    url = URL(string: "https://trailers.apple.com/" + trailer.poster)!
                }
                else
                {
                    url = URL(string:trailer.poster)!
                }
                
                if let image = NSImage(contentsOf: url)
                {
                    let key = trailer.title as NSString
                    self.cache.setObject(image, forKey: key)

                    DispatchQueue.main.async
                    {
                        item.image.image = image
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        item.image.image = self.tempImage
                    }
                }
            }
        }

        return item
    }

    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>)
    {
        let trailer = visibletrailers[indexPaths.first!.item]
        controller.play(trailer: trailer)
    }
}
