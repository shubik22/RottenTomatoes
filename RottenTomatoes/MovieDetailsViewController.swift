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

        var thumbnailPosterPath = movie.valueForKeyPath("posters.thumbnail") as! String
        let range = thumbnailPosterPath.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        let highQualityPosterPath = thumbnailPosterPath.stringByReplacingCharactersInRange(range!, withString: "https://content6.flixster.com/")

        let thumbnailPosterUrl = NSURL(string: thumbnailPosterPath)!
        let highQualityPosterUrl = NSURL(string: highQualityPosterPath)
        
        backgroundImageView.alpha = 0.0
        backgroundImageView.setImageWithURL(thumbnailPosterUrl)
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.backgroundImageView.alpha = 1.0
            }, completion: nil)
        
        backgroundImageView.setImageWithURLRequest(NSURLRequest(URL: highQualityPosterUrl!), placeholderImage: nil, success: { (request: NSURLRequest, response: NSHTTPURLResponse, image: UIImage) -> Void in
            self.backgroundImageView.image = image
            }) { (request: NSURLRequest, response: NSHTTPURLResponse, error: NSError) -> Void in
            print("Error fetching image: \(error.description)")
        }
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
