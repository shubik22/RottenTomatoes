//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Sam Sweeney on 9/17/15.
//  Copyright © 2015 Wealthfront. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    enum MovieGroup : String {
        case BoxOffice = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"
        case TopDvds = "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json"
    }
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var currentMovieGroup: MovieGroup?
    
    @IBAction func onTap(sender: AnyObject) {
        searchBar.resignFirstResponder()
    }

    @IBAction func boxOfficeButtonClicked(sender: UIBarButtonItem) {
        currentMovieGroup = MovieGroup.BoxOffice
        boxOfficeButtonItem.tintColor = UIColor.blueColor()
        dvdButtonItem.tintColor = UIColor.blackColor()
        setTitle()
        loadMovies()
    }

    @IBAction func dvdButtonClicked(sender: AnyObject) {
        currentMovieGroup = MovieGroup.TopDvds
        boxOfficeButtonItem.tintColor = UIColor.blackColor()
        dvdButtonItem.tintColor = UIColor.blueColor()
        setTitle()
        loadMovies()
    }

    @IBOutlet weak var boxOfficeButtonItem: UIBarButtonItem!
    @IBOutlet weak var dvdButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
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

        searchBar.delegate = self

        setTitle()
        loadMovies()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let moviesToUse = (filteredMovies != nil) ? filteredMovies! : movies!
    
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = moviesToUse[indexPath.row]
        cell.titleLabel.text = movie["title"] as! String
        cell.synopsisLabel.text = movie["synopsis"] as! String
        
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterView.setImageWithURL(posterUrl)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterMoviesWithText(searchText)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filterMoviesWithText("")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func filterMoviesWithText(searchText: String?) {
        if searchText != nil && searchText! != "" {
            filteredMovies = movies?.filter({ (movie) -> Bool in
                let title = movie["title"] as! String
                return title.rangeOfString(searchText!) != nil
            })
        } else {
            filteredMovies = movies
        }

        tableView.reloadData()
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
                                self.filteredMovies = self.movies
                                self.tableView.reloadData()
                                self.filterMoviesWithText(self.searchBar.text)
                                
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
        
        let movie = filteredMovies![indexPath!.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
