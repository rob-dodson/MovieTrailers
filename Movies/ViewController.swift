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
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    var item : AVPlayerItem!
    var model : Model!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        model = Model()
        do
        {
            try load()
        }
        catch
        {
            NSLog("Error loading trailer list")
        }
    }


    override var representedObject: Any?
    {
        didSet
        {
        // Update the view, if already loaded.
        }
    }


    func load() throws
    {
        var trailers = Array<Trailer>();
        
		//
		// json
		// 
        if let url = URL(string: "https://trailers.apple.com/trailers/home/feeds/just_added.json")
		{
            
			let json = try String(contentsOf: url)
			let jsonData = json.data(using: .utf8)!
            let jsontrailers : [Trailer] = try! JSONDecoder().decode([Trailer].self, from: jsonData)
            
            trailers.append(contentsOf: jsontrailers)
            NSLog("foo")
		}


		//
		// xml current
		//
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
        
        model.setup(list: trailers,controller:self)
        collectionView.dataSource = model
        collectionView.delegate = model
        collectionView.register(trailerViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dataSourceItem"))
    }
    
    
    func play(trailer:Trailer)
    {
        titleLabel.stringValue = trailer.title
        studioLabel.stringValue = trailer.studio
        directorLabel.stringValue = trailer.directors
        descriptionText.string = trailer.description ?? "no description"
        
        var cast = String()
        if trailer.actors != nil && trailer.actors.count > 0
        {
            var loop = 0
            for member in trailer.actors
            {
                if loop > 0 && loop < trailer.actors.count
                {
                    cast = cast + ", "
                }
                cast = cast + member
                loop = loop + 1
            }
        }
        else
        {
            cast = "none"
        }
        castLabel.stringValue = cast
        
        imageView.image = NSImage(contentsOf: URL(string: trailer.poster_2x)!)
        
        var releasedate = String()
        if trailer.trailers != nil && trailer.trailers.count > 0
        {
            let parts = trailer.releasedate.split(separator: " ")
            releasedate = String(format: "%@ %@",String(parts[2]),String(parts[3]))
        }
        else
        {
            releasedate = trailer.releasedate
        }
        
        if trailer.runtime == nil
        {
            infoLabel.stringValue = String(format: "%@ ・ %@ ・ %@",
                                       trailer.genre[0],releasedate,trailer.rating ?? "")
        }
        else
        {
            infoLabel.stringValue = String(format: "%@ ・ %@ ・ %@ ・ %@",
                                       trailer.genre[0],releasedate,trailer.runtime ?? "",trailer.rating ?? "")
        }
        
        var preview = String()
        if trailer.preview != nil
        {
            preview = trailer.preview
        }
        else
        {
            var s = trailer.trailers[0].url
            s = s?.replacingOccurrences(of: "/trailers", with: "")
            preview = "https://movietrailers.apple.com/movies" + s! + trailer.title.lowercased() + "-trailer-1_i320.m4v"
            preview = preview.replacingOccurrences(of: " ", with: "-")
        }
        print("Vid URL " + preview)
        
        item = AVPlayerItem(url: NSURL.init(string:preview)! as URL)
        player.player = AVPlayer(playerItem: item)
        player.player?.play()
        
        if trailer.description == nil
        {
            do
            {
                try getDescription(trailer: trailer)
            }
            catch
            {
                
            }
        }
    }
    
    func getDescription(trailer:Trailer) throws
    {
        /*
         
         https://trailers.apple.com/trailers/focus_features/the-northman/
         
        <meta name="Description" content="From visionary director Robert Eggers comes THE NORTHMAN, an action-filled epic that follows a young Viking prince on his quest to avenge his father’s murder.  With an all-star cast that includes Alexander Skarsgård, Nicole Kidman, Claes Bang, Anya Taylor-Joy, Ethan Hawke, Björk, and Willem Dafoe.">
         
         <span class="movie-rating rating-pg13"> pg13 </span>
         */
        if let url = URL(string:"https://trailers.apple.com" + trailer.location)
        {
            let html = try String(contentsOf: url, encoding: String.defaultCStringEncoding)
            
            print(url.description)
            print(html)
            
            let matches = html.match(regex: "<meta name=\"Description\".*>")
            if matches.count > 0
            {
                var desc = matches[0].description
                desc = desc.replacingOccurrences(of: "[\"<meta name=\\\"Description\\\" content=\\\"", with: "")
                desc = desc.replacingOccurrences(of: "\\\" />\"]", with: "")
                desc = desc.replacingOccurrences(of: "‚Äú", with: "\"")
                desc = desc.replacingOccurrences(of: "‚Äù", with: "\"")
                desc = desc.replacingOccurrences(of: "‚Äô", with: "'")
                desc = desc.replacingOccurrences(of: "\\\'", with: "'")
                desc = desc.replacingOccurrences(of: "\\\"", with: "\"")
                desc = desc.replacingOccurrences(of: " ‚Äì", with:",")
                
                descriptionText.string = desc
            }
        }
    }
}


extension String
{

    public func matchRegex(regex: String) throws -> [NSTextCheckingResult]
    {
        let re = try NSRegularExpression(pattern: regex, options: [])
        return re.matches(in: self, options:[], range:NSMakeRange(0,self.count))
    }


    public func match(regex: String) -> [[String]]
    {
        let nsString = self as NSString

        do
        {
            let re = try NSRegularExpression(pattern: regex,options: [])

            let matches = re.matches(in:self, options:[], range:NSMakeRange(0, count)).map
            { match in
                (0..<match.numberOfRanges).map
                {
                    match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0))
                }
            }

            return matches
        }
        catch
        {
            return []
        }
    }
}

