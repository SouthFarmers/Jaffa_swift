//
//  ViewController.swift
//  ProConnect
//
//  Created by Gautham Vejandla on 6/14/17.
//  Copyright © 2017 Steris. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernamefield: UITextField!
    @IBOutlet weak var passwordfield: UITextField!
    @IBOutlet weak var rememberme: UISwitch!
    @IBOutlet weak var signinbutton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
        
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(_ sender: Any) {
        
        let username = usernamefield.text
        let userPassword = passwordfield.text
        
        if (username?.isEmpty)! || (userPassword?.isEmpty)! {
            self.showerror(userMessage: "All fields are required")
            return;
        }
        
        
    activityIndicator.startAnimating();
        
        let base64 = encodeString(usernamefield.text!+":"+passwordfield.text!);
        guard let url = URL(string: "https://thingworxdev.steris.com/Thingworx/Things/SterisMobileHelper/Services/CheckLogin?method=POST&x-thingworx-session=true&Content-Type=application/json&Accept=application/json&Username="+usernamefield.text!+"&Password="+passwordfield.text!) else {return}
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("Basic "+base64, forHTTPHeaderField: "Authorization")
        
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            let status = (response as! HTTPURLResponse).statusCode
            
            if status == 200 {
                print(status)
                if self.rememberme.isOn{
                    let defaults = UserDefaults.standard
                    defaults.set(base64, forKey: "auth")
                }
                DispatchQueue.main.async() {
                    self.gotoHome()
                }
                
                
            }else{
                DispatchQueue.main.async() {
                    //self.displayMyAlertMessage("Wrong name or password")
                    self.showerror(userMessage: "Login failed, try again!")
                }
                
            }
            
        }.resume()

        
    }
    
    func stoploading(){
        
       
    }
    
    func showerror(userMessage:String){
         activityIndicator.isHidden = true
        activityIndicator.stopAnimating();
        let alert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func  encodeString(_ val : String) -> String  {
        let utf8str = val.data(using: String.Encoding.utf8)
        let base64Encoded = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return base64Encoded!
    }
    
    func gotoHome(){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating();
        performSegue(withIdentifier: "toHomeSegue", sender: self)
    }

}

