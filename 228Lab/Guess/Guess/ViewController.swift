//
//  ViewController.swift
//  Guess
//
//  Created by 舟喆 吴 on 01/05/2019.
//  Copyright © 2019 Zhouzhe Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var qLabel: UILabel!
    
    @IBOutlet weak var inputField: UITextField!
    
    
    
    @IBOutlet weak var guessBtn: UIButton!
   
    @IBOutlet weak var outputLabel: UILabel!
    
    let myDice = Int.random(in: 1..<7)+Int.random(in: 1..<7);
    @IBAction func actBtn(_ sender: Any) {
        
        inputField.resignFirstResponder()
        guard let yourGuess = inputField.text else {
            return;
        }
        
        if let yourGuessInt = Int(yourGuess){
            if yourGuessInt>1&&yourGuessInt<13{
                if yourGuessInt==myDice{
                    outputLabel.text? = "Congratulations! Your guess is corret!"
                }
                else{
                    outputLabel.text? = "Sorry, your guess is \(yourGuessInt), but answer is \(myDice)."
                }
            }else{
                outputLabel.text? = "Sorry, your input is incorrect, please try again."
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.keyboardType = UIKeyboardType.numberPad
        inputField.clearsOnBeginEditing = true;
        // Do any additional setup after loading the view.
    }


}

