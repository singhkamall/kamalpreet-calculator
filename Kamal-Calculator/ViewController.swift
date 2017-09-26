//
//  ViewController.swift
//  Kamal-Calculator
//
//  Created by Student on 2017-09-19.
//  Copyright © 2017 Centennial College. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var userInput = [String]()
    
    @IBOutlet weak var lblDisplay: UILabel!
    @IBOutlet weak var btnDecimal: UIButton!
    
    private let decimalSeparator = NumberFormatter().decimalSeparator!
    var isUserTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func btnNum(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if isUserTyping {
            // when user continues his typing
            let currentDisplayText = lblDisplay.text!
            
            if decimalSeparator != digit || !currentDisplayText.contains(decimalSeparator) {
               lblDisplay.text = currentDisplayText + digit
            }
        }else{
            // user starts new typing
            switch digit{
            case decimalSeparator:
                lblDisplay.text = "0" + decimalSeparator
            case "0":
                if "0" == lblDisplay.text{
                    return
                }
                // continue
                fallthrough
            default:
                lblDisplay.text = digit
            }
            isUserTyping = true;
        }
    }
    
    @IBAction func btnOperators(_ sender: UIButton) {
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        displayValue = 0
        isUserTyping=false
        
    }
    
    var displayValue: Double{
        get{
            return (NumberFormatter().number(from:lblDisplay.text!)?.doubleValue)!
        }
        set{
            lblDisplay.text = String(newValue)
        }
    }
    
    
}
