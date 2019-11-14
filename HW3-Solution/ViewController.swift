//
//  ViewController.swift
//  HW3-Solution
//
//  Created by Jonathan Engelsma on 9/7/18.
//  Copyright © 2018 Jonathan Engelsma. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, SettingsViewControllerDelegate, HistoryTableViewControllerDelegate {

   fileprivate var ref : DatabaseReference?



    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var fromUnits: UILabel!
    @IBOutlet weak var toUnits: UILabel!
    @IBOutlet weak var calculatorHeader: UILabel!
    
    //var entries : [Conversion] = []
    var entries : [Conversion] = [
        Conversion(fromVal: 1, toVal: 1760, mode: .Length, fromUnits: LengthUnit.Miles.rawValue, toUnits: LengthUnit.Yards.rawValue, timestamp: Date.distantPast),
        Conversion(fromVal: 1, toVal: 4, mode: .Volume, fromUnits: VolumeUnit.Gallons.rawValue, toUnits: VolumeUnit.Quarts.rawValue, timestamp: Date.distantFuture)]
    
    var currentMode : CalculatorMode = .Length
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toField.delegate = self
        fromField.delegate = self
        self.view.backgroundColor = BACKGROUND_COLOR
        self.ref = Database.database().reference()
        self.registerForFireBaseUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func selectEntry(entry: Conversion) {
        fromField.text = "\(entry.fromVal)"
        toField.text = "\(entry.toVal)"
        fromUnits.text = entry.fromUnits
        toUnits.text = entry.toUnits
        currentMode = entry.mode
        calculatorHeader.text = "\(currentMode.rawValue) Conversion Calculator"
    }
    
    @IBAction func calculatePressed(_ sender: UIButton) {
        // determine source value of data for conversion and dest value for conversion
        var dest : UITextField?

        var val = ""
        if let fromVal = fromField.text {
            if fromVal != "" {
                val = fromVal
                dest = toField
            }
        }
        if let toVal = toField.text {
            if toVal != "" {
                val = toVal
                dest = fromField
            }
        }
        if dest != nil {
            switch(currentMode) {
            case .Length:
                var fUnits, tUnits : LengthUnit
                if dest == toField {
                    fUnits = LengthUnit(rawValue: fromUnits.text!)!
                    tUnits = LengthUnit(rawValue: toUnits.text!)!
                } else {
                    fUnits = LengthUnit(rawValue: toUnits.text!)!
                    tUnits = LengthUnit(rawValue: fromUnits.text!)!
                }
                if let fromVal = Double(val) {
                    let convKey =  LengthConversionKey(toUnits: tUnits, fromUnits: fUnits)
                    let toVal = fromVal * lengthConversionTable[convKey]!;
                    dest?.text = "\(toVal)"
                    let entry = Conversion(fromVal: fromVal, toVal: toVal, mode: .Length,
                    fromUnits: fUnits.rawValue, toUnits: tUnits.rawValue, timestamp: Date())
                    let newChild = self.ref?.child("history").childByAutoId()
                                        newChild?.setValue(self.toDictionary(vals: entry))

                }
                
            case .Volume:
                var fUnits, tUnits : VolumeUnit
                if dest == toField {
                    fUnits = VolumeUnit(rawValue: fromUnits.text!)!
                    tUnits = VolumeUnit(rawValue: toUnits.text!)!
                } else {
                    fUnits = VolumeUnit(rawValue: toUnits.text!)!
                    tUnits = VolumeUnit(rawValue: fromUnits.text!)!
                }
                if let fromVal = Double(val) {
                    let convKey =  VolumeConversionKey(toUnits: tUnits, fromUnits: fUnits)
                    let toVal = fromVal * volumeConversionTable[convKey]!;
                    dest?.text = "\(toVal)"
                    let entry = Conversion(fromVal: fromVal, toVal: toVal, mode: .Volume,
                    fromUnits: fUnits.rawValue, toUnits: tUnits.rawValue, timestamp: Date())
                    let newChild = self.ref?.child("history").childByAutoId()
                                        newChild?.setValue(self.toDictionary(vals: entry))

                }
            }
        }
        self.view.endEditing(true)
    }
    
    func toDictionary(vals: Conversion) -> NSDictionary {
                  return [
                      "timestamp": NSString(string: (vals.timestamp.iso8601)),
                      "origFromVal" : NSNumber(value: vals.fromVal),
                      "origToVal" : NSNumber(value: vals.toVal),
                      "origMode" : vals.mode.rawValue,
                      "origFromUnits" : vals.fromUnits,
                      "origToUnits" : vals.toUnits
                  ]
              }
       
    
    @IBAction func clearPressed(_ sender: UIButton) {
        self.fromField.text = ""
        self.toField.text = ""
        self.view.endEditing(true)
        switch(currentMode) {
        case .Volume:
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
        case .Length:
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
        }
    }
    
    @IBAction func modePressed(_ sender: UIButton) {
        clearPressed(sender)
        switch (currentMode) {
        case .Length:
            currentMode = .Volume
            fromUnits.text = VolumeUnit.Gallons.rawValue
            toUnits.text = VolumeUnit.Liters.rawValue
//            fromField.placeholder =
//            toField.placeholder = "Enter volume in \(toUnits.text!)"
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter volume in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            
        case .Volume:
            currentMode = .Length
            fromUnits.text = LengthUnit.Yards.rawValue
            toUnits.text = LengthUnit.Meters.rawValue
//            fromField.placeholder = "Enter length in \(fromUnits.text!)"
//            toField.placeholder = "Enter length in \(toUnits.text!)"
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(fromUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
            fromField.attributedPlaceholder =
                NSAttributedString(string: "Enter length in \(toUnits.text!)", attributes: [NSAttributedStringKey.foregroundColor :
                    FOREGROUND_COLOR])
        }

        calculatorHeader.text = "\(currentMode.rawValue) Conversion Calculator"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            if let  target = segue.destination as? SettingsViewController {
                target.mode = currentMode
                target.fUnits = fromUnits.text
                target.tUnits = toUnits.text
                target.delegate = self
            }
        } else if segue.identifier == "historySegue" {
            if let  target = segue.destination as? HistoryTableViewController {
                target.entries = entries
                target.historyDelegate = self
            }
        }
    }
    
    func settingsChanged(fromUnits: LengthUnit, toUnits: LengthUnit)
    {
        self.fromUnits.text = fromUnits.rawValue
        self.toUnits.text = toUnits.rawValue
    }
    
    func settingsChanged(fromUnits: VolumeUnit, toUnits: VolumeUnit)
    {
        self.fromUnits.text = fromUnits.rawValue
        self.toUnits.text = toUnits.rawValue
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == toField) {
            fromField.text = ""
        } else {
            toField.text = ""
        }
    }
    
    fileprivate func registerForFireBaseUpdates()
     {
         self.ref!.child("history").observe(.value, with: { snapshot in
             if let postDict = snapshot.value as? [String : AnyObject] {
                 var tmpItems = [Conversion]()
                 for (_,val) in postDict.enumerated() {
                     let entry = val.1 as! Dictionary<String,AnyObject>
                     let timestamp = entry["timestamp"] as! String?
                     let origFromVal = entry["origFromVal"] as! Double?
                     let origToVal = entry["origToVal"] as! Double?
                     let origFromUnits = entry["origFromUnits"] as! String?
                     let origToUnits = entry["origToUnits"] as! String?
                     let origMode = entry["origMode"] as! String?
                     
                     tmpItems.append(Conversion(fromVal: origFromVal!, toVal: origToVal!, mode: CalculatorMode(rawValue: origMode!)!, fromUnits: origFromUnits!, toUnits: origToUnits!, timestamp: (timestamp?.dateFromISO8601)!))
                 }
                 self.entries = tmpItems
             }
         })
         
       
    }
        
}

