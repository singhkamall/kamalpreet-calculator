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

    private enum Operation{
        case binary((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations:Dictionary<String,Operation>=[
        "x": Operation.binary(*, { $0 + "x" + $1 }),
        "/": Operation.binary(/, { $0 + "/" + $1 }),
        "+": Operation.binary(+, { $0 + "+" + $1 }),
        "-": Operation.binary(-, { $0 + "-" + $1 }),
        "=": Operation.equals,
    ]

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
        if isUserTyping{
            setOperand(displayValue)
            isUserTyping=false
        }
        if let mathSymbol = sender.currentTitle{
            performOperation(mathSymbol)
        }
        
        displayResult()
    }
    
    private func displayResult(){
        let eval = evaluate()
        if let result = eval.result{
            
        displayValue = result
        }
        
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String, error: String?)
    {
        var accumulator: (Double, String)?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        var error: String?
        
        struct PendingBinaryOperation {
            let symbol: String
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            let firstOperand: (Double, String)
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        func performPendingBinaryOperation() {
            if nil != pendingBinaryOperation && nil != accumulator {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        var result: Double? {
            if nil != accumulator {
                return accumulator!.0
            }
            return nil
        }
        
        var description: String? {
            if nil != pendingBinaryOperation {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }
        }
        
        for element in stack {
            switch element {
            case .operand(let value):
                accumulator = (value, "\(value)")
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .binary(let function, let description):
                        performPendingBinaryOperation()
                        if nil != accumulator {
                            pendingBinaryOperation = PendingBinaryOperation(symbol: symbol, function: function, description: description, firstOperand: accumulator!)
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    }
                }
            case .variable(let symbol):
                if let value = variables?[symbol] {
                    accumulator = (value, symbol)
                } else {
                    accumulator = (0, symbol)
                }
            }
        }
        
        return (result, nil != pendingBinaryOperation, description ?? "", error)
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
    
    private var stack = [Element]()
    private enum Element{
        case operation(String)
        case operand(Double)
        case variable(String)
    }
    func setOperand(_ operand: Double){
        stack.append(Element.operand(operand))
    }
    func setOperand(variable named: String){
        stack.append(Element.variable(named))
    }
    func performOperation(_ symbol:String){
        stack.append(Element.operation(symbol))
    }
}
