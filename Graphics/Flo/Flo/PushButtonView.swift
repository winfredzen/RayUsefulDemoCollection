//
//  PushButtonView.swift
//  Flo
//
//  Created by wangzhen on 2017/7/25.
//  Copyright © 2017年 wz. All rights reserved.
//

import UIKit

/// 自定义add button
@IBDesignable
class PushButtonView: UIButton {

    
    @IBInspectable var fillColor: UIColor = UIColor.green
    @IBInspectable var isAddButton: Bool = true
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
        

        //加号
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.8
        
        let plusPath = UIBezierPath()
        plusPath.lineWidth = plusHeight


        //水平线
        plusPath.move(to: CGPoint(x: bounds.width/2-plusWidth/2+0.5, y: bounds.height/2+0.5))
        plusPath.addLine(to: CGPoint(x: bounds.width/2+plusWidth/2+0.5, y: bounds.height/2+0.5))
        
        if isAddButton {
            //垂直线
            plusPath.move(to: CGPoint(x:bounds.width/2 + 0.5, y:bounds.height/2 - plusWidth/2 + 0.5))
            
            plusPath.addLine(to: CGPoint(x:bounds.width/2 + 0.5, y:bounds.height/2 + plusWidth/2 + 0.5))
        }
        
        
        UIColor.white.setStroke()
        plusPath.stroke()
        
        
    }

}









