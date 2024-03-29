//
//  ViewController.swift
//  MovieTrailers
//
//  Created by Robert Dodson on 12/28/21.
//

import Cocoa
import AVFoundation
import SWXMLHash
import RegexBuilder


class ViewController: NSViewController, NSSearchFieldDelegate
{

    @IBOutlet weak var player: Player!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var studioLabel: NSTextField!
    @IBOutlet weak var directorLabel: NSTextField!
    @IBOutlet weak var castLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet var descriptionText: NSTextView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var websiteLabel: ClickableLabel!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var errorLabel: NSTextField!
    
    var item : AVPlayerItem!
    var model : Model!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        model = Model()
        
        titleLabel.stringValue = " "
        studioLabel.stringValue = " "
        directorLabel.stringValue = " "
        castLabel.stringValue = " "
        infoLabel.stringValue = " "
        websiteLabel.isHidden = true
        descriptionText.string = " " // making it "" resets the font colors and sizes
        
        searchField.delegate = self
        searchField.sendsWholeSearchString = false
        searchField.sendsSearchStringImmediately = false
        
        errorLabel.isHidden = true
        
        DispatchQueue.global().async
        {
            do
            {
                try self.load()
            }
            catch
            {
                print("Error in load()")
            }
        }
    }

    
    //
    // search field
    //
    @IBAction func searchAction(_ sender: Any)
    {
        model.search(searchString:searchField.stringValue)
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField)
    {
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField)
    {
    }
    
   
    //
    // load trailers
    //
    func load() throws
    {
        var trailers = Array<Trailer>();
        
		//
		// json for just_added list
		// 
        if let url = URL(string: "https://trailers.apple.com/trailers/home/feeds/just_added.json")
		{
            
			let json = try String(contentsOf: url)
			let jsonData = json.data(using: .utf8)!
            do
            {
                let jsontrailers : [Trailer] = try JSONDecoder().decode([Trailer].self, from: jsonData)
                trailers.append(contentsOf: jsontrailers)
            }
            catch
            {
                print("json error: \(error)")
                DispatchQueue.main.async
                {
                    self.errorLabel.isHidden = false
                    self.errorLabel.stringValue = "Sorry, Apple no longer maintains the website this app uses. [json error]"
                }
            }
            
            
		}


		//
		// xml current list
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
        
        DispatchQueue.main.async
        {
            self.collectionView.dataSource = self.model
            self.collectionView.delegate = self.model
            self.collectionView.register(trailerViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dataSourceItem"))
        }
    }
    
    
	//
	// Update UI and play the trailer
	//
    func play(trailer:Trailer)
    {
		//
		// main data
		//
        titleLabel.stringValue = trailer.title
        studioLabel.stringValue = trailer.studio
        directorLabel.stringValue = trailer.directors
        descriptionText.string = trailer.description ?? "no description"
        errorLabel.isHidden = true

        
        //
        // clickable labels
		//
        websiteLabel.isHidden = true
        if var website = trailer.moviesite
        {
            if !website.hasPrefix("http")
            {
                website = "https://" + website
            }
            
            if let url = URL(string: website)
            {
                websiteLabel.isHidden = false
                websiteLabel.setURL(url:url)
            }
        }
        
        
        //
		// cast
		//
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
        

		//
		// large poster
        //
        let url = trailer.makePosterURL(big: true)
        
        let session = URLSession.shared.dataTask(with: URLRequest(url: url))
        { data, response, error in
            
            if data != nil
            {
                if let image = NSImage(data: data!)
                {
                    DispatchQueue.main.async
                    {
                        self.imageView.image = image
                    }
                }
            }
        }
        session.resume()
        
        
		//
		// misc info
		//
        var releasedate = String()
        if trailer.trailers != nil && trailer.trailers.count > 0
        {
            if trailer.releasedate.count > 1
            {
                let parts = trailer.releasedate.split(separator: " ")
                releasedate = String(format: "%@ %@",String(parts[2]),String(parts[3]))
            }
            else
            {
                releasedate = "no release date"
            }
        }
        else
        {
            releasedate = trailer.releasedate
        }
        
        if trailer.runtime == nil
        {
            if trailer.genre.count > 0
            {
                infoLabel.stringValue = String(format: "%@ ・ %@ ・ %@",
                                       trailer.genre[0],releasedate,trailer.rating ?? "")
            }
            else
            {
                infoLabel.stringValue = String(format: "%@ ・ %@",
                                       releasedate,trailer.rating ?? "")
            }
        }
        else
        {
            infoLabel.stringValue = String(format: "%@ ・ %@ ・ %@ ・ %@",
                                       trailer.genre[0],releasedate,trailer.runtime ?? "",trailer.rating ?? "")
        }
        
    
		//
		// try to create the correct URL to the preview video file
		//
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
        preview = preview.replacingOccurrences(of: "'", with: "")
       
        
        print("Trailer preview URL" + preview)
        if let url = URL(string:preview)
        {
            item = AVPlayerItem(url: url)
            if player.player == nil
            {
                player.player = AVPlayer(playerItem: item)
            }
            else
            {
                player.player?.replaceCurrentItem(with: item) 
            }
            player.player?.play()
            
            DispatchQueue.global().async
            {
                sleep(2)
                if self.item.status != .readyToPlay
                {
                    DispatchQueue.main.async
                    {
                        self.errorLabel.isHidden = false
                        self.errorLabel.stringValue = "Sorry, the trailer won't load."
                    }
                }
            }
        }
        else
        {
            errorLabel.isHidden = false
            errorLabel.stringValue = "Sorry, I can't find the trailer."

            player.player?.pause()
            player.player =  AVPlayer(playerItem: nil)
        }

        
		//
		// description - we have it from the xml or will scrape from Apple's trailer page
		//
        if trailer.description == nil
        {
            getDescription(trailer: trailer)
        }
    }

    
    /*
     Sample description

     https://trailers.apple.com/trailers/focus_features/the-northman/
     
    <meta name="Description" content="From visionary director Robert Eggers comes THE NORTHMAN, an action-filled epic that follows a young Viking prince on his quest to avenge his father’s murder.  With an all-star cast that includes Alexander Skarsgård, Nicole Kidman, Claes Bang, Anya Taylor-Joy, Ethan Hawke, Björk, and Willem Dafoe.">

     */
    func getDescription(trailer:Trailer)
    {
        if let url = URL(string:"https://trailers.apple.com" + trailer.location)
        {
            let session = URLSession.shared.dataTask(with: URLRequest(url: url))
            { data, response, error in
                
                if data != nil
                {
                    if let html = String(data: data!, encoding: .utf8)
                    {
                        print("html url: " + url.description)
                        
                        let matches = html.match(regex: "<meta name=\"Description\".*>")
                        if matches.count > 0
                            {
                            var desc = matches[0].description
                            
                            //
                            // strip out cruft from desc
                            //
                            desc = desc.replacingOccurrences(of: "[\"<meta name=\\\"Description\\\" content=\\\"", with: "")
                            desc = desc.replacingOccurrences(of: "\\\" />\"]", with: "")
                            
                            //
                            // replace special symbol codes with the symbol
                            //
                            desc = desc.replacingOccurrences(of: "‚Äú", with: "\"")
                            desc = desc.replacingOccurrences(of: "‚Äù", with: "\"")
                            desc = desc.replacingOccurrences(of: "‚Äô", with: "'")
                            desc = desc.replacingOccurrences(of: "\\\'", with: "'")
                            desc = desc.replacingOccurrences(of: "\\\"", with: "\"")
                            desc = desc.replacingOccurrences(of: " ‚Äì", with:",")
                            desc = desc.replacingOccurrences(of: "¬Æ", with:"®")
                            desc = desc.replacingOccurrences(of: "√Ø", with:"ï")
                            
                            DispatchQueue.main.async
                            {
                                self.descriptionText.string = desc
                            }
                        }
                    }
                }
            }
            session.resume()
        }
    }
}

func fixDesc(description:String) -> String
{
    var desc = description
    
    //
    // strip out cruft from desc
    //
    desc = desc.replacingOccurrences(of: "[\"<meta name=\\\"Description\\\" content=\\\"", with: "")
    desc = desc.replacingOccurrences(of: "\\\" />\"]", with: "")

    //
    // replace special symbol codes with the symbol
    //
    desc = desc.replacingOccurrences(of: "‚Äú", with: "\"")
    desc = desc.replacingOccurrences(of: "‚Äù", with: "\"")
    desc = desc.replacingOccurrences(of: "‚Äô", with: "'")
    desc = desc.replacingOccurrences(of: "\\\'", with: "'")
    desc = desc.replacingOccurrences(of: "\\\"", with: "\"")
    desc = desc.replacingOccurrences(of: " ‚Äì", with:",")
    desc = desc.replacingOccurrences(of: "¬Æ", with:"®")
    desc = desc.replacingOccurrences(of: "√Ø", with:"ï")
    desc = desc.replacingOccurrences(of: "¬†", with:" ")
    desc = desc.replacingOccurrences(of: "√©", with:"é")
    desc = desc.replacingOccurrences(of: "√®", with:"è")
    return desc
}


