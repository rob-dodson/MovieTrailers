//
//  ClickableLabel.swift
//  MovieTrailers
//
//  Created by Robert Dodson on 1/1/22.
//

import Foundation
import AppKit

class ClickableLabel : NSTextField
{
    var url : URL!
    
    func setURL(url:URL)
    {
        self.url = url
    }
    
    override func mouseDown(with event: NSEvent)
    {
        NSWorkspace.shared.open(url)
    }
}
