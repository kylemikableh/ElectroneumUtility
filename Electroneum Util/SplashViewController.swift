//
//  ViewController.swift
//  Electroneum Util
//
//  Created by Kyle Mikolajczyk on 1/4/18.
//  Copyright © 2018 Kyle Mikolajczyk. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, UITextFieldDelegate
{
    var paidNum: Double = 1
    var balanceNum: Double = 1
        var priceDouble: Double = 1
    
    @IBOutlet weak var walletIdTextField: UITextField!
    
    @IBOutlet weak var paid: UILabel!
    @IBOutlet weak var pending: UILabel!
    @IBOutlet weak var hashRate: UILabel!
    
    @IBOutlet weak var etnValue: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var waitingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.walletIdTextField.delegate = self
        waitingIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didResignFirstResponder(_ sender: UIButton)
    {
        walletIdTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        waitingIndicator.startAnimating()
        walletIdTextField.resignFirstResponder()
        setLablesHidden(isItHidden: true)
        gatherWalletData(id: walletIdTextField.text!)
        gatherCoinData()
        return true
    }
    
    func gatherWalletData(id: String)
    {
        print("https://api.etn.spacepools.org/v1/stats/address/\(id)")
        let url = NSURL(string: "https://api.etn.spacepools.org/v1/stats/address/\(id)")
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if error != nil
            {
                print("error \(String(describing: error))")
                self.setLablesHidden(isItHidden: true)
                self.errorOccured()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
            {
                if let stats = json!["stats"] as! [String:Any]?
                {
                    print(stats.keys)
                    
                    //Paid
                    let paidText = stats["paid"] as! String!
                    self.paidNum = Double(paidText! + "")!/100
                    
                    //Pending
                    let balanceText = stats["balance"] as! String!
                    self.balanceNum = Double(balanceText! + "")!/100
                    
                    //Est. Hash Rate
                    let hashRateText = stats["hashrate"] as! String!
                    
                    DispatchQueue.main.async
                        {
                            self.paid.text = "Total Paid: \(String(describing: self.paidNum)) ETN"
                            self.pending.text = "Pending: \(String(describing: self.balanceNum)) ETN"
                            self.hashRate.text = "Est. Hash Rate: \(hashRateText ?? "error")"
                            let totalMoney = (self.paidNum + self.balanceNum) * self.priceDouble
                            print(totalMoney)
                            self.total.text = "Est. Total: $\(String(describing: totalMoney))"
                            self.setLablesHidden(isItHidden: false)
                    }
                }
                else
                {
                    self.setLablesHidden(isItHidden: true)
                    self.errorOccured()
                    self.waitingIndicator.isHidden = true
                    return
                }
            }
            else
            {
                print("error \(String(describing: error))")
                self.setLablesHidden(isItHidden: true)
                self.errorOccured()
                return
            }
        }).resume()
    }
    func gatherCoinData()
    {
        print("https://api.coinmarketcap.com/v1/ticker/electroneum/")
        let url = NSURL(string: "https://api.coinmarketcap.com/v1/ticker/electroneum/")
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if error != nil
            {
                print("error \(String(describing: error))")
                self.setLablesHidden(isItHidden: true)
                self.errorOccured()
                return
            }
            var json: [Any]?
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any]
            }
            catch
            {
                print(error)
                print("error \(String(describing: error))")
                self.setLablesHidden(isItHidden: true)
                self.errorOccured()
                return

            }
            print(json?.first ?? "Error")
            let item = json?.first as? [String: Any]
            let priceUSD = item!["price_usd"] as! String!
            self.priceDouble = Double(priceUSD! + "")!
            DispatchQueue.main.async
            {
                self.etnValue.text = "ETN Value: $\(String(describing: self.priceDouble))"
            }
        }).resume()
    }
    
    func setLablesHidden(isItHidden: Bool)
    {
        waitingIndicator.isHidden = !isItHidden
        self.paid.isHidden = isItHidden
        self.pending.isHidden = isItHidden
        self.hashRate.isHidden = isItHidden
        self.total.isHidden = isItHidden
        self.etnValue.isHidden = isItHidden
        self.statsLabel.isHidden = isItHidden
    }
    
    func errorOccured()
    {
        let alertController = UIAlertController(title: "Uh oh!", message:
            "Failed to get Electroneum data. Is the wallet id correct?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: { action in
            self.pressed()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    func pressed()
    {
        waitingIndicator.stopAnimating()
        waitingIndicator.isHidden = true
    }
}

