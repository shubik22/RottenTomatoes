//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Sam Sweeney on 9/17/15.
//  Copyright © 2015 Wealthfront. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    enum MovieGroup : String {
        case BoxOffice = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
        case TopDvds = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
    }
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var currentMovieGroup: MovieGroup?
    
    @IBAction func boxOfficeButtonClicked(sender: UIBarButtonItem) {
        currentMovieGroup = MovieGroup.BoxOffice
        setTitle()
        loadMovies()
    }

    @IBAction func dvdButtonClicked(sender: AnyObject) {
        currentMovieGroup = MovieGroup.TopDvds
        setTitle()
        loadMovies()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentMovieGroup == nil) {
            currentMovieGroup = MovieGroup.BoxOffice
        }

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        tableView.dataSource = self
        tableView.delegate = self

        setTitle()
        loadMovies()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as! String
        cell.synopsisLabel.text = movie["synopsis"] as! String
        
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterView.setImageWithURL(posterUrl)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func loadMovies() {
        JTProgressHUD.show()
        
        let url = NSURL(string: currentMovieGroup!.rawValue)
        let task =  NSURLSession.sharedSession().dataTaskWithRequest(
            NSURLRequest(URL: url!),
            completionHandler: {
                (data, response, error) -> Void in
                if let data = data {
                    dispatch_async(dispatch_get_main_queue()) {
                        do {
                            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                                self.movies = json["movies"] as? [NSDictionary]
                                self.tableView.reloadData()
                                
                                self.errorView.hidden = true
                                self.errorView.alpha = 0
                                
                                JTProgressHUD.hideWithTransition(JTProgressHUDTransition.Fade)
                            }
                        } catch {
                            print("Error loading json....")
                        }
                    }
                    
                } else if let _ = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.errorView.hidden = false
                        UIView.animateWithDuration(1.0, animations: { () -> Void in
                            self.errorView.alpha = 0.99
                        })
                        JTProgressHUD.hideWithTransition(JTProgressHUDTransition.Fade)
                    }
                }
                
        })
        task.resume()
    }

    func setTitle() {
        if (currentMovieGroup == MovieGroup.BoxOffice) {
            self.navigationItem.title = "Movies - Box Office"
        } else if (currentMovieGroup == MovieGroup.TopDvds) {
            self.navigationItem.title = "Movies - Top DVDs"
        }
    }

    func onRefresh() {
        loadMovies()
        self.refreshControl.endRefreshing()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        let movie = movies![indexPath!.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
