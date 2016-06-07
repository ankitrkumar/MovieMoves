//
//  MovieDetailViewController.swift
//  MovieMoves
//
//  Created by Ankit Kumar on 4/24/16.
//  Copyright © 2016 Ankit Kumar. All rights reserved.
//
import UIKit
import Cosmos

// MARK: - MovieDetailViewController: UIViewController

class MovieDetailViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: Properties
    
    var movie: TMDBMovie?
    var videos: [TMDBMovieVideo]?
    var isFavorite = false
    var isWatchlist = false
    
    // MARK: Outlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var toggleWatchlistButton: UIButton!
    @IBOutlet weak var toggleFavoriteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieReleaseYearLabel: UILabel!
    @IBOutlet weak var movieRating: CosmosView!
    @IBOutlet weak var movieOverviewTextView: UITextView!
    @IBOutlet weak var watchTrailer: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieRating.didFinishTouchingCosmos = ratingTouched
        movieRating.didTouchCosmos = ratingTouches
        navigationController!.navigationBar.translucent = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        
        // set the UI, then check if the movie is a favorite/watchlist and update the buttons!
        if let movie = movie {
            
            // set the title
            if let releaseYear = movie.releaseYear {
                navigationItem.title = "\(movie.title) (\(releaseYear))"
                self.movieReleaseYearLabel.text = releaseYear
                self.movieTitleLabel.text = movie.title
            } else {
                navigationItem.title = "\(movie.title)"
                self.movieReleaseYearLabel.text = ""
                self.movieTitleLabel.text = movie.title
            }
            if let rating = movie.vote_average {
                self.movieRating.rating = rating
                self.movieRating.text = "\(rating)/10"
            } else {
                self.movieRating.rating = 0
            }
            
            if let overview = movie.overview{
                self.movieOverviewTextView.text = overview
            } else{
                self.movieOverviewTextView.text = ""
            }
            // setting some default UI ...
            posterImageView.image = UIImage(named: "MissingPoster")
            isFavorite = false
            
            // is the movie a favorite?
            TMDBClient.sharedInstance().getFavoriteMovies { (movies, error) in
                if let movies = movies {
                    
                    for movie in movies {
                        if movie.id == self.movie!.id {
                            self.isFavorite = true
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.isFavorite {
                            self.toggleFavoriteButton.tintColor = nil
                        } else {
                            self.toggleFavoriteButton.tintColor = UIColor.blackColor()
                        }
                    }
                } else {
                    print(error)
                }
            }
            
            // is the movie on the watchlist?
            TMDBClient.sharedInstance().getWatchlistMovies { (movies, error) in
                if let movies = movies {
                    
                    for movie in movies {
                        if movie.id == self.movie!.id {
                            self.isWatchlist = true
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.isWatchlist {
                            self.toggleWatchlistButton.tintColor = nil
                        } else {
                            self.toggleWatchlistButton.tintColor = UIColor.blackColor()
                        }
                    }
                } else {
                    print(error)
                }
            }
            
            // set the poster image
            if let posterPath = movie.posterPath {
                TMDBClient.sharedInstance().taskForGETImage(TMDBClient.PosterSizes.DetailPoster, filePath: posterPath, completionHandlerForImage: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicator.alpha = 0.0
                            self.activityIndicator.stopAnimating()
                            self.posterImageView.image = image
                        }
                    }
                })
            } else {
                activityIndicator.alpha = 0.0
                activityIndicator.stopAnimating()
            }
        }
        
        // get the trailer videos
        TMDBClient.sharedInstance().getMovieVideos(self.movie!.id) { (videos, error) in
            if let videos = videos {
                self.videos = videos
                dispatch_async(dispatch_get_main_queue()) {
                    if videos.count <= 0
                    {
                        self.watchTrailer.enabled = false
                    }
                }
            } else {
                print(error)
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.movieOverviewTextView.setContentOffset(CGPointZero, animated: true)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVideo"
        {
            if let videoViewController = segue.destinationViewController as? VideoViewController
            {
                videoViewController.movieVideo = videos
                videoViewController.popoverPresentationController!.delegate = self
                videoViewController.preferredContentSize = CGSize(width: 320, height: 186)
            }
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: Functions
    
    private func ratingTouched(rating: Double)
    {
        TMDBClient.sharedInstance().postMovieRating(self.movie!, ratingValue: rating) { (statusCode, error) in
            if let error = error {
                print(error)
            } else {
            }
        }
    }
    
    private func ratingTouches(rating: Double)
    {
        self.movieRating.rating = rating
        self.movieRating.text = "\(rating)/10"
    }
    
    // MARK: Actions
    
    @IBAction func watchTrailer(sender: UIButton) {
        self.performSegueWithIdentifier("showVideo", sender: self)
    }
    
    @IBAction func toggleFavorite(sender: AnyObject) {
        
        let shouldFavorite = !isFavorite
        
        TMDBClient.sharedInstance().postToFavorites(movie!, favorite: shouldFavorite) { (statusCode, error) in
            if let error = error {
                print(error)
            } else {
                if statusCode == 1 || statusCode == 12 || statusCode == 13 {
                    self.isFavorite = shouldFavorite
                    dispatch_async(dispatch_get_main_queue()) {
                        self.toggleFavoriteButton.tintColor = (shouldFavorite) ? nil : UIColor.blackColor()
                    }
                } else {
                    print("Unexpected status code \(statusCode)")
                }
            }
        }
    }
    
    @IBAction func toggleWatchlist(sender: AnyObject) {
        
        let shouldWatchlist = !isWatchlist
        
        TMDBClient.sharedInstance().postToWatchlist(movie!, watchlist: shouldWatchlist) { (statusCode, error) in
            if let error = error {
                print(error)
            } else {
                if statusCode == 1 || statusCode == 12 || statusCode == 13 {
                    self.isWatchlist = shouldWatchlist
                    dispatch_async(dispatch_get_main_queue()) {
                        self.toggleWatchlistButton.tintColor = (shouldWatchlist) ? nil : UIColor.blackColor()
                    }
                } else {
                    print("Unexpected status code \(statusCode)")
                }
            }
        }
    }
}