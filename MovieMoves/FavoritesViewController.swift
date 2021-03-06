//
//  FavoritesViewController.swift
//  MovieMoves
//
//  Created by Ankit Kumar on 4/25/16.
//  Copyright © 2016 Ankit Kumar. All rights reserved.
//

import UIKit

// MARK: - FavoritesViewController: UIViewController

class FavoritesViewController: UIViewController {
    
    // MARK: Properties
    
    var movies: [TMDBMovie] = [TMDBMovie]()
    
    // MARK: Outlets
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create and set the logout button
        parentViewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Reply, target: self, action: "logout")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        TMDBClient.sharedInstance().getFavoriteMovies { (movies, error) in
            if let movies = movies {
                self.movies = movies
                dispatch_async(dispatch_get_main_queue()) {
                    self.moviesTableView.reloadData()
                }
            } else {
                print(error)
            }
        }
    }
    
    // MARK: Logout
    
    func logout() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - FavoritesViewController: UITableViewDelegate, UITableViewDataSource

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get cell type  
        let cellReuseIdentifier = "FavoriteTableViewCell"
        let movie = movies[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        // Set cell defaults  
        cell.textLabel!.text = movie.title
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        cell.imageView!.image = UIImage(named: "Film")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        if let posterPath = movie.posterPath {
            TMDBClient.sharedInstance().taskForGETImage(TMDBClient.PosterSizes.RowPoster, filePath: posterPath, completionHandlerForImage: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                   dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView!.image = image
                    }
                } else {
                    print(error)
                }
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movies[indexPath.row]
        navigationController!.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}