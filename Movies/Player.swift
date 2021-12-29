//
//  Player.swift
//  Movies
//
//  Created by Robert Dodson on 12/28/21.
//

import Cocoa
import AVKit

class Player: AVPlayerView
{
    required init(coder:NSCoder)
    {
        super.init(coder: coder)!
    }
}
