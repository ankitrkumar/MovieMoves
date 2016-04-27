//
//  YoutubeViewController.swift
//  MovieMoves
//
//  Created by Ankit Kumar on 4/27/16.
//  Copyright © 2016 Ankit Kumar. All rights reserved.
//

import UIKit

// MARK: - VideoViewController: UIViewController
class VideoViewController: UIViewController {

    var movieVideo : [TMDBMovieVideo]!
    
    //MARK :Outlet
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = 320
        let height = 186
        let frame = 0
        let randomTrailer = Int(arc4random_uniform(UInt32(movieVideo.count)))
        webView.allowsInlineMediaPlayback = true
        let code:NSString = "<iframe width=\(width) height= \(height) src=\(movieVideo[randomTrailer].url!) frameborder=\(frame) allowfullscreen></iframe>"
        self.webView.loadHTMLString(code as String, baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
