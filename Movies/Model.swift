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
    
    
    func setup(list:Array<Trailer>,controller:ViewController)
    {
        self.trailers = list
        self.controller = controller
        
        tempImage = NSImage(named:"temp")
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
            item.text.font = NSFont(name: "Helvetica Neue Condensed Bold", size: 14.0)
        }
        else if splitcount >= 6
        {
            item.text.font = NSFont(name: "Helvetica Neue Condensed Bold", size: 13.0)
        }
        else
        {
            item.text.font = NSFont(name: "Helvetica Neue Condensed Bold", size: 15.0)
        }
        
        DispatchQueue.global(qos: .userInitiated).async
        {
            let image = NSImage(contentsOf: URL(string: trailer.poster)!)
            DispatchQueue.main.async
            {
                item.image.image = image
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
