//
//  RangeSlider.swift
//  RangeSliderExample
//
//  Created by Juliya on 27.07.17.
//  Copyright © 2017 Juliya. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSlider: UIControl {

    var minimumValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    var maximumValue: Double = 24.0 {
        didSet {
            updateLayerFrames()
        }
    }

    var lowerValue = 2.0 {
        didSet {
            updateLayerFrames()
        }
    }

    var upperValue = 16.0 {
        didSet {
            updateLayerFrames()
        }
    }
    var trackTintColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    var trackHighlightTintColor = UIColor.red {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    var thumbTintColor = UIColor.red {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }

    
    var curvaceousness: CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
            
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
            
        }
    }

    var thumbWidth: CGFloat {
        return CGFloat(bounds.width/1.5)
    }
    var markerWidth: CGFloat {
        return CGFloat(bounds.width/2.2)
    }
    
    
    var ifSet = false
    var tripDays: Int = 0
    var dayLabelLayers = [CATextLayer]()
    var dayMarkerLayers = [RangeSliderDayMarkerLayer]()
    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer()
    let upperThumbLayer = RangeSliderThumbLayer()
    var lowerTimeThumb = TimeThumbView()
    var upperTimeThumb = TimeThumbView()
    var previousLocation = CGPoint()
    

   
    init (frame: CGRect, tripDays: Int) {
        self.tripDays = tripDays
        
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
        
        for i in 0...tripDays {
            dayMarkerLayers.append(RangeSliderDayMarkerLayer(color: RangeSliderDayMarkerColors.colorsArray[i]))
            dayLabelLayers.append(CATextLayer())
        }
        
        if let topTimeThumb = Bundle.main.loadNibNamed("TimeThumbView", owner: nil, options: nil)?.first as? TimeThumbView {
            upperTimeThumb = topTimeThumb
            upperTimeThumb.timeLabel.text = String(Int(upperValue)) + ":00 "
            addSubview(upperTimeThumb)
        }
        
        if let bottomTimeTumb = Bundle.main.loadNibNamed("TimeThumbView", owner: nil, options: nil)?.first as? TimeThumbView {
            lowerTimeThumb = bottomTimeTumb
            lowerTimeThumb.timeLabel.text = String(Int(lowerValue)) + ":00 "
            addSubview(lowerTimeThumb)
        }
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func onPress()
    {
        sendActions(for: .touchDown)
    }
    
    func setMarkers() {
        //marker created
        if dayMarkerLayers.count == 0 {
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        for i in 0...tripDays {
            let dayMarkerLayer = dayMarkerLayers[i]
            dayMarkerLayer.rangeSlider = self
            dayMarkerLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(dayMarkerLayer)

            let dayMarkerCenter = CGFloat(round(positionForValueOfMarker(value: 0.0 + Double(i) * maximumValue)))
            dayMarkerLayer.frame = CGRect(x: round((bounds.width - markerWidth) / 2), y: round(dayMarkerCenter - markerWidth/2.0), width: round(markerWidth), height: round(markerWidth))
            
            dayMarkerLayer.setNeedsDisplay()
            if i != tripDays {
            let dayLabelLayer = dayLabelLayers[i]
            dayLabelLayer.font = UIFont(name: "Arial", size: 16)
            dayLabelLayer.fontSize = 16
            dayLabelLayer.frame = CGRect(x: round(bounds.width - 2 * thumbWidth), y: round(dayMarkerCenter - markerWidth/1.5) , width: round(thumbWidth), height: round(thumbWidth))
            dayLabelLayer.string = String(i+1)
            dayLabelLayer.foregroundColor = RangeSliderDayMarkerColors.colorsArray[i]
            dayLabelLayer.alignmentMode = "center"
            
            layer.addSublayer(dayLabelLayer)
                
                
            }
        }
        
        CATransaction.commit()
    }
    
   
    func updateLayerFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        trackLayer.frame = bounds.insetBy(dx: bounds.width / 2.2, dy: 0.0)
        trackLayer.setNeedsDisplay()

        let lowerThumbCenter = CGFloat(positionForValue(value: lowerValue))
        
        lowerThumbLayer.frame = CGRect(x: (bounds.width - thumbWidth) / 2, y: lowerThumbCenter - thumbWidth / 2.0, width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        lowerTimeThumb.frame = CGRect(x: lowerThumbLayer.frame.maxX + 3.0, y: lowerThumbLayer.frame.minY + 4.0, width: lowerTimeThumb.bounds.width, height: lowerTimeThumb.bounds.height)
        lowerTimeThumb.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(value: upperValue))
        upperThumbLayer.frame = CGRect(x: (bounds.width - thumbWidth) / 2, y: upperThumbCenter - thumbWidth/2.0, width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
        
        upperTimeThumb.frame = CGRect(x: upperThumbLayer.frame.maxX + 3.0, y: upperThumbLayer.frame.minY + 4.0, width: upperTimeThumb.bounds.width, height: upperTimeThumb.bounds.height)
        upperTimeThumb.setNeedsDisplay()
        
        setMarkers()
        
        CATransaction.commit()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        }
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = Double(location.y - previousLocation.y)
        let deltaValue = (maximumValue * Double(tripDays) - minimumValue) * deltaLocation / Double(bounds.height - thumbWidth)
        
        previousLocation = location
        
        if lowerThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            var timeForLabel = Int(lowerValue)
            while timeForLabel >= 24 {
                timeForLabel -= 24
            }
            lowerTimeThumb.timeLabel.text = String(timeForLabel) + ":00 "
        } else if upperThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue, upperValue: maximumValue * Double(tripDays))
            var timeForLabel = Int(upperValue)
            while timeForLabel >= 24 {
                timeForLabel -= 24
            }
            upperTimeThumb.timeLabel.text = String(timeForLabel) + ":00 "
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        
        sendActions(for: .valueChanged)
        
        
        return true
        
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
    
    func positionForValueOfMarker(value: Double) -> Double {
        return Double(bounds.height - markerWidth) * (value - minimumValue) / (maximumValue * Double(tripDays) - minimumValue) + Double(markerWidth / 2.0)
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.height - thumbWidth) * (value - minimumValue) / (maximumValue * Double(tripDays) - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    
    
    
}


















