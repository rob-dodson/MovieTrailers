//
//  trailerViewItem.swift
//  Movies
//
//  Created by Robert Dodson on 12/30/21.
//

import Cocoa

class trailerViewItem: NSCollectionViewItem
{

    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var text: NSTextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    //
    // highlight selected item
    //
    override var isSelected: Bool
    {
        didSet
        {
          self.view.layer?.backgroundColor = (isSelected ? NSColor.systemGray.cgColor : NSColor.clear.cgColor)
        }
      }
    
}
