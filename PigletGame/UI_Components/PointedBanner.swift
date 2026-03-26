//
//  PointedBanner.swift
//  PigletGame
//
//  Created by Adriel de Souza on 24/03/26.
//


import SwiftUI

struct PointedBanner: Shape {
    /// Controls how deep the bottom point goes. 
    /// 0.25 means the side edges stop 25% of the shape's total width above the very bottom.
    var pointDropRatio: CGFloat = 0.25
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Calculate the vertical drop for the bottom-left and bottom-right corners
        let pointDrop = rect.width * pointDropRatio
        
        // 1. Start at top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // 2. Line to top-right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // 3. Line down to bottom-right (stopping just short of the very bottom)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - pointDrop))
        
        // 4. Line to the bottom-center tip
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        // 5. Line up to bottom-left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - pointDrop))
        
        // 6. Close the path back to top-left
        path.closeSubpath()
        
        return path
    }
}

#Preview{
    PointedBanner()
}
