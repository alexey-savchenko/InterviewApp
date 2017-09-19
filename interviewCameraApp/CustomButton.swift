//
//  CustomButton.swift
//  CheckMyTrack
//
//  Created by Alexey Savchenko on 04.05.17.
//  Copyright © 2017 Alexey Savchenko. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func prepareForInterfaceBuilder() {

    backgroundColor = BGColor
    layer.cornerRadius = cornerRadius
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet{
      layer.cornerRadius = cornerRadius
      if cornerRadius > 0 {
        clipsToBounds = true
      }
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet{
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor = .clear {
    didSet{
      layer.borderColor = borderColor.cgColor
    }
  }
  
  @IBInspectable var BGColor: UIColor = .white{
    didSet{
      backgroundColor = BGColor
      
    }
  }
  
  @IBInspectable var imageContentMode: UIViewContentMode = .center {
    didSet{
      imageView?.contentMode = imageContentMode

    }
  }
  
}
