//
//  HomeViewController.swift
//  ProConnect
//
//  Created by Gautham Vejandla on 6/16/17.
//  Copyright © 2017 Steris. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    var images = [String]()
    var labels = [String]()
    var ratings = [Int]()
    var menuShowing = false
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsetsMake(15, 16, 10, 16)
        mainCollectionView.collectionViewLayout = layout
    }
    
    @IBAction func openMenu(_ sender: Any) {
        if menuShowing{
            leadingConstraint.constant = -250
            UIView.animate(withDuration: 0.05, animations: {
                self.view.layoutIfNeeded()
            })
        }else{
            leadingConstraint.constant = 0
            
            UIView.animate(withDuration: 0.05, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        menuShowing = !menuShowing
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! MainGridViewCell
        //cell.maingridimage.image = UIImage(named: images[indexPath.row])
        print(images)
        if images.count > 0 {
        self.loadFromURL(picurl: images[indexPath.row], callback: { (image: UIImage) -> () in
            cell.maingridimage.image = image
        })
        cell.maingridlabel.text = labels[indexPath.row]
            cell.maingridrating.text = String(ratings[indexPath.row])
        }
        // cell.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        cell.layer.borderWidth = 0.5
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width/2) - 20
        return CGSize(width: width, height: width+20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item is", labels[indexPath.row])
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toDetailSegue", sender: self)
        }
    }
    
    
    func loadFromURL(picurl : String, callback: @escaping (UIImage)->()) {
        let newurl = picurl.replacingOccurrences(of: " ", with: "%20")
        let forecastURL = NSURL(string: newurl+"")
        DispatchQueue.global(qos: .background).async(execute: {
            
            let imageData = NSData (contentsOf: forecastURL! as URL)
            if let data = imageData {
                DispatchQueue.main.async(execute: {
                    if let image = UIImage(data: data as Data) {
                        callback(image)
                    }
                })
            }
        })
    }
    
    
    func getData(){
        guard let url = URL(string: "http://jaffareviews.com/api/Movie/GetNewReleases") else { return }
        
        let session = URLSession.shared
        
        session.dataTask(with: url) { (data, respose, error) in
            if data != nil {
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]

                    let movies = json?["movies"] as? [[String: Any]]
                    
                        for movie in movies! {
                            if let name = movie["MovieName"] as? String {
                                self.labels.append(name)
                                //print(name)
                            }
                            if let pic = movie["MovieImage"] as? String {
                                self.images.append(pic)
                            }
                            if let rating = movie["AvgRating"] as? Int {
                                print(rating)
                                self.ratings.append(rating)
                                
                            }
                        }
                    self.mainCollectionView.reloadData()
                    
                } catch{
                    print(error)
                }
            }
        }.resume()
    }
}
