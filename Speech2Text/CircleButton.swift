 //
//  CircleButton.swift
//  Speech2Text
//
//  Created by Abed on 28/12/2016.
//  Copyright © 2016 Webiaturist. All rights reserved.
//

import UIKit

@IBDesignable
class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 25.0 {
        didSet{
            setupView()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }

    func setupView(){
        layer.cornerRadius = cornerRadius
    }
}
