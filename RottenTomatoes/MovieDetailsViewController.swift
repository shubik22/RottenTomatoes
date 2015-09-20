//
//  MovieDetailsViewController.swift
//  RottenTomatoes
//
//  Created by Sam Sweeney on 9/17/15.
//  Copyright © 2015 Wealthfront. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String

        var posterPath = movie.valueForKeyPath("posters.thumbnail") as! String
        let range = posterPath.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            posterPath = posterPath.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }

        let posterUrl = NSURL(string: posterPath)!
        backgroundImageView.setImageWithURL(posterUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
