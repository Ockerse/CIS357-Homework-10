//
//  SettingsViewController.swift
//  HW3-Solution
//
//  Created by Jonathan Engelsma on 9/10/18.
//  Copyright © 2018 Jonathan Engelsma. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsChanged(fromUnits: LengthUnit, toUnits: LengthUnit)
    func settingsChanged(fromUnits: VolumeUnit, toUnits: VolumeUnit)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var fromUnits: UILabel!
    @IBOutlet weak var toUnits: UILabel!
    var pickerData: [String] = [String]()
    var isFrom = true
    var mode : CalculatorMode = .Length {
        didSet {
            switch(mode) {
            case .Length:
                var vals : [String] = []
                for val in LengthUnit.allCases {
                    vals.append(val.rawValue)
                }
                pickerData = vals
            case .Volume:
                var vals : [String] = []
                for val in VolumeUnit.allCases {
                    vals.append(val.rawValue)
                }
                pickerData = vals
            }
        }
    }
    var fUnits : String?
    var tUnits: String?
    
    var delegate : SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        let tapFrom = UITapGestureRecognizer(target: self, action: #selector(self.fromTapped))
        self.fromUnits.addGestureRecognizer(tapFrom)
        
        let tapTo = UITapGestureRecognizer(target: self, action: #selector(self.toTapped))
        self.toUnits.addGestureRecognizer(tapTo)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hidePicker))
        self.view.addGestureRecognizer(tap)
        
        guard let fStr = self.fUnits, let tStr = tUnits else {
            return
        }
        self.fromUnits.text = fStr
        self.toUnits.text = tStr
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func fromTapped(sender: UITapGestureRecognizer){
        print("gesture recognizer tapped.")
        self.picker.isHidden = false
        self.picker.reloadAllComponents()
        self.picker.isHidden = false
        self.isFrom = true
        
    }
    
    @objc
    func toTapped(sender: UITapGestureRecognizer){
        print("gesture recognizer tapped.2")
        self.picker.reloadAllComponents()
        self.picker.isHidden = false
        self.isFrom = false
    }
    
    @objc
    func hidePicker(sender: UITapGestureRecognizer) {
        self.picker.isHidden = true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        //self.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        
        if let del = self.delegate {
//            del.settingsChanged(distanceUnits: self.dUnits!, bearingUnits: self.bUnits!)
            switch(mode) {
            case .Length:
                del.settingsChanged(fromUnits: LengthUnit(rawValue: fromUnits.text!)!, toUnits: LengthUnit(rawValue: toUnits.text!)!)
            case .Volume:
                del.settingsChanged(fromUnits: VolumeUnit(rawValue: fromUnits.text!)!, toUnits: VolumeUnit(rawValue: toUnits.text!)!)
            }
        }
        //self.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

extension SettingsViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in: UIPickerView) -> Int
    {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if self.isFrom {
            self.fromUnits.text = self.pickerData[row]
            self.fUnits = self.pickerData[row]
        } else {
            self.toUnits.text = self.pickerData[row]
            self.tUnits = self.pickerData[row]
        }
    }
}

