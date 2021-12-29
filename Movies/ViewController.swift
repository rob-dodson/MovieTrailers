//
//  ViewController.swift
//  Movies
//
//  Created by Robert Dodson on 12/28/21.
//

import Cocoa
import AVFoundation
import SWXMLHash

class ViewController: NSViewController {

    @IBOutlet weak var player: Player!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var studioLabel: NSTextField!
    @IBOutlet weak var ratingLabel: NSTextField!
    @IBOutlet weak var runtimeLabel: NSTextField!
    @IBOutlet weak var releaseDateLabel: NSTextField!
    @IBOutlet weak var directorLabel: NSTextField!
    @IBOutlet weak var castLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var trailerList: NSCollectionView!
    @IBOutlet weak var imageWell: NSImageView!
    
    
    var item : AVPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async
               {
                   do
                   {
                       try self.play()
                   }
                   catch
                   {
                       
                   }
               }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func play() throws
    {
        var trailers = Array<Trailer>();
        
        if let url = URL(string: "https://trailers.apple.com/trailers/home/xml/current_720p.xml")
        {
           let xmlToParse = try String(contentsOf:url)
            let xml = XMLHash.parse(xmlToParse)
            
            let xmltrailers = xml["records"]["movieinfo"]
            
            for xmltrailer in xmltrailers.all
            {
                let trailer = Trailer()
                
                let info = xmltrailer["info"]
                
                trailer.mapdata(map:xmltrailer)
                trailer.mapinfo(map:info)
                
                trailers.append(trailer)
            }
        }

        let index = Int(arc4random_uniform(UInt32(trailers.count)))
        let trailer = trailers[index]
        titleLabel.stringValue = trailer.title
        ratingLabel.stringValue = trailer.rating
        runtimeLabel.stringValue = trailer.runtime
        studioLabel.stringValue = trailer.studio
        releaseDateLabel.stringValue = trailer.releaseDate
        directorLabel.stringValue = trailer.director
        descriptionLabel.stringValue = trailer.description
        imageWell.image = NSImage(contentsOf: URL(string: trailer.poster)!)
        
        item = AVPlayerItem(url: NSURL.init(string:trailer.preview)! as URL)
        
        _ = item?.observe(\AVPlayerItem.status, changeHandler:
		{ observedPlayerItem, change in
            if (observedPlayerItem.status == AVPlayerItem.Status.readyToPlay) 
			{
                print("Current stream duration \(observedPlayerItem.duration.seconds)")
            }
        })
        
        player.player = AVPlayer(playerItem: item)
        
        player.player?.play()
    }
}

