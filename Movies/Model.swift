//
//  Model.swift
//  Movies
//
//  Created by Robert Dodson on 12/30/21.
//

import Foundation
import AppKit

class Model: NSObject, NSCollectionViewDataSource,NSCollectionViewDelegate
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
        item.image.image = NSImage(contentsOf: URL(string: trailer.poster)!)
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>)
    {
        let trailer = trailers[indexPaths.first!.item]
        controller.play(trailer: trailer)
    }
}
