//
//  GalleryTableViewCell.swift
//  Image_Gallery
//
//  Created by Artem Musel on 9/9/19.
//  Copyright © 2019 Artem Musel. All rights reserved.
//

import UIKit

class GalleryTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    //text in cell
    var title: String {
        set {
            textField?.text = newValue
        }
        get {
            return textField.text ?? ""
        }
    }

    override var isEditing: Bool {
        didSet {
            textField.isEnabled = isEditing
            
            if isEditing == true {
                textField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
    }
    
    //completion after editing end
    var resignationHandler: (()->Void)?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            textField.isEnabled = false
        }
    }
    
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        isEditing = false
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
