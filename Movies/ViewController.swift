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
    @IBOutlet weak var directorLabel: NSTextField!
    @IBOutlet weak var castLabel: NSTextField!
    @IBOutlet weak var trailerList: NSCollectionView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet var descriptionText: NSTextView!
    
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
        studioLabel.stringValue = trailer.studio
        directorLabel.stringValue = trailer.director
        descriptionText.string = trailer.description
        castLabel.stringValue = trailer.cast
        imageView.image = NSImage(contentsOf: URL(string: trailer.largePoster)!)
        
        
        infoLabel.stringValue = String(format: "%@ ・ %@ ・ %@ ・ %@", trailer.genre,trailer.releaseDate,trailer.runtime,trailer.rating)
        
        item = AVPlayerItem(url: NSURL.init(string:trailer.preview)! as URL)
        /*
        _ = item?.observe(\AVPlayerItem.status, changeHandler:
		{ observedPlayerItem, change in
            if (observedPlayerItem.status == AVPlayerItem.Status.readyToPlay) 
			{
                print("Current stream duration \(observedPlayerItem.duration.seconds)")
            }
        })
         */
        
        player.player = AVPlayer(playerItem: item)
        
        player.player?.play()
    }
}

