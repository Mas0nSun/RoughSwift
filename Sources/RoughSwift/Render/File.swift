//
//  File.swift
//  
//
//  Created by Mason Sun on 2023/2/14.
//

import SwiftUI

public struct RoughShape: Shape {
    let drawing: Drawing
    let options: Options

    public func path(in rect: CGRect) -> SwiftUI.Path {
        let paths = PathRenderer().render(drawing: drawing)
        // TODO:
        // 1. Convert BezierPath to Shape
        // 2. Apply color for single Shape
        // 3. Combine Shapes to RoughView
        var result = SwiftUI.Path()
        paths.forEach { s, path in
            var path = SwiftUI.Path(path.cgPath)
            switch s.type {
            case .path:
//                path.lineWidth = CGFloat(options.strokeWidth)
            case .fillSketch:
                fillSketch(path: path, options: options)
            case .fillPath:
                fillPath(options: options)
            case .path2DFill:
                fillPath(options: options)
            case .path2DPattern:
                fillSketch(path: path, options: options)
            }
            result.addPath(<#T##path: Path##Path#>)
        }
        return result
    }
}

public struct PathRenderer {
    public func render(drawing: Drawing) -> [(OperationSet, UIBezierPath)] {
        return drawing.sets.map {
            ($0, shapeLayer(set: $0, options: drawing.options))
        }
    }

    private func shapeLayer(set: OperationSet, options: Options) -> UIBezierPath {
        let path = UIBezierPath()
        switch set.type {
        case .path:
            path.lineWidth = CGFloat(options.strokeWidth)
        case .fillSketch:
            fillSketch(path: path, options: options)
        case .fillPath:
            fillPath(options: options)
        case .path2DFill:
            fillPath(options: options)
        case .path2DPattern:
            fillSketch(path: path, options: options)
        }
        set.operations.forEach { op in
            operate(op: op, path: path)
        }
        return path
    }

    /// Sketch style fill, using many stroke paths
    private func fillSketch(path: UIBezierPath, options: Options) {
        var fweight = options.fillWeight
        if (fweight < 0) {
            fweight = options.strokeWidth / 2
        }
        path.lineWidth = CGFloat(fweight)
    }

    /// Solid fill, using fill layer
    private func fillPath(options: Options) {
        
    }

    private func operate(op: Operation, path: UIBezierPath) {
        switch op {
        case let op as Move:
            path.move(to: op.point.toCGPoint())
        case let op as LineTo:
            path.addLine(to: op.point.toCGPoint())
        case let op as BezierCurveTo:
            path.addCurve(
                to: op.point.toCGPoint(),
                controlPoint1: op.controlPoint1.toCGPoint(),
                controlPoint2: op.controlPoint2.toCGPoint()
            )
        case let op as QuadraticCurveTo:
            path.addQuadCurve(
                to: op.point.toCGPoint(),
                controlPoint: op.controlPoint.toCGPoint()
            )
        default:
            break
        }
    }
}
