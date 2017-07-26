//
//  CounterView.swift
//  Flo
//
//  Created by wangzhen on 2017/7/25.
//  Copyright © 2017年 wz. All rights reserved.
//

import UIKit

let NoOfGlasses = 8
let π:CGFloat = CGFloat(Double.pi)

@IBDesignable
class CounterView: UIView {

    @IBInspectable var counter: Int = 5 {
        didSet{
            if counter <= NoOfGlasses {
                setNeedsDisplay()
            }
        }
    }
    @IBInspectable var outlineColor: UIColor = UIColor.blue
    @IBInspectable var counterColor: UIColor = UIColor.orange
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = max(bounds.width, bounds.height)
        let arcWidth: CGFloat = 76

        let startAngle: CGFloat = 3 * π / 4
        let endAngle: CGFloat = π / 4
        
        let path = UIBezierPath(arcCenter: center, radius: radius/2-arcWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.stroke()
        
        //绘制outline
        //arc的总角度数
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle
        
        //每杯多少角度
        let arcLengthPerGlass = angleDifference / CGFloat(NoOfGlasses)
        
        //总角度
        let outlineEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle
        
        //绘制外边的arc
        let outlinePath = UIBezierPath(arcCenter: center,
                                       radius: bounds.width/2 - 2.5,
                                       startAngle: startAngle,
                                       endAngle: outlineEndAngle,
                                       clockwise: true)
        
        //绘制inner arc
        outlinePath.addArc(withCenter:center,
                                     radius: bounds.width/2 - arcWidth + 2.5,
                                     startAngle: outlineEndAngle,
                                     endAngle: startAngle,
                                     clockwise: false)
        
        //闭合path
        outlinePath.close()
        
        outlineColor.setStroke()
        outlinePath.lineWidth = 5.0
        outlinePath.stroke()
        
        
        //绘制刻度
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        outlineColor.setFill()
        
        let markerWidth:CGFloat = 5.0
        let markerSize:CGFloat = 10.0
        //左上角
        var markerPath = UIBezierPath(rect: CGRect(x: -markerWidth/2, y: 0, width: markerWidth, height: markerSize))
        
        context?.translateBy(x: rect.width/2, y: rect.height/2)
        
        for i in 1...NoOfGlasses {
            
            context?.saveGState()
         
            var angle = arcLengthPerGlass * CGFloat(i) + startAngle - π/2
            context?.rotate(by: angle)
            context?.translateBy(x: 0, y: rect.height/2 - markerSize)
            
            markerPath.fill()
            
            context?.restoreGState()
        }
        
        
        context?.restoreGState()
        
    }
 

}
