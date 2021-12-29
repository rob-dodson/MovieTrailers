//
//  ViewController.swift
//  Movies
//
//  Created by Robert Dodson on 12/28/21.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var player: Player!
    
    var item : AVPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global(qos: .background).async
               {
                   self.play()
               }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func play()
    {
        item = AVPlayerItem(url: NSURL.init(string: "https://trailers.apple.com/movies/paramount/clifford-the-big-red-dog/clifford-the-big-red-dog-trailer-2_h640w.mov")! as URL)
        
        
        _ = item?.observe(\AVPlayerItem.status, changeHandler: { observedPlayerItem, change in
            if (observedPlayerItem.status == AVPlayerItem.Status.readyToPlay) {
                print("Current stream duration \(observedPlayerItem.duration.seconds)")
            }
        })
        
        player.player = AVPlayer(playerItem: item)
        
        player.player?.play()
    }
}

