//
//  File.swift
//  
//
//  Created by Mason Sun on 2023/2/14.
//

import SwiftUI

struct DrawingView: View {
    let drawing: Drawing

    var body: some View {
        ForEach(drawing.sets.indices, id: \.self) { index in
            RoughShape(
                set: drawing.sets[index],
                options: drawing.options
            )
        }
    }
}

public struct RoughShape: View {
    let set: OperationSet
    let options: Options

    @ViewBuilder
    public var body: some View {
        let path = SwiftUI.Path(generateBezierPath().cgPath)
        switch set.type {
        case .path:
            path.stroke(
                Color(options.stroke),
                lineWidth: CGFloat(options.strokeWidth)
            )
        case .fillSketch:
            path.stroke(
                Color(options.fill),
                lineWidth: CGFloat(max(options.fillWeight, options.strokeWidth / 2))
            )
        case .fillPath:
            path.fill(Color(options.fill))
        case .path2DFill:
            path.fill(Color(options.fill))
        case .path2DPattern:
            path.stroke(
                Color(options.fill),
                lineWidth: CGFloat(max(options.fillWeight, options.strokeWidth / 2))
            )
        }
    }

    private func generateBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        set.operations.forEach { op in
            operate(op: op, path: path)
        }
        return path
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

extension Point {
    func toCGPoint() -> CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

// https://github.com/onmyway133/blog/issues/232

extension CGRect {
    var center: CGPoint {
        return CGPoint( x: self.size.width/2.0,y: self.size.height/2.0)
    }
}

extension CGPoint {
    func vector(to p1:CGPoint) -> CGVector {
        return CGVector(dx: p1.x - x, dy: p1.y - y)
    }
}

extension UIBezierPath {
    func moveCenter(to:CGPoint) -> Self {
        let bounds = self.cgPath.boundingBox
        let center = bounds.center

        let zeroedTo = CGPoint(x: to.x - bounds.origin.x, y: to.y - bounds.origin.y)
        let vector = center.vector(to: zeroedTo)

        _ = offset(to: CGSize(width: vector.dx, height: vector.dy))
        return self
    }

    func offset(to offset:CGSize) -> Self {
        let t = CGAffineTransform(translationX: offset.width, y: offset.height)
        _ = applyCentered(transform: t)
        return self
    }

    func fit(into:CGRect) -> Self {
        let bounds = self.cgPath.boundingBox

        let sw     = into.size.width/bounds.width
        let sh     = into.size.height/bounds.height
        let factor = min(sw, max(sh, 0.0))

        return scale(x: factor, y: factor)
    }

    func scale(x:CGFloat, y:CGFloat) -> Self{
        let scale = CGAffineTransform(scaleX: x, y: y)
        _ = applyCentered(transform: scale)
        return self
    }


    func applyCentered(transform: @autoclosure () -> CGAffineTransform ) -> Self{
        let bound  = self.cgPath.boundingBox
        let center = CGPoint(x: bound.midX, y: bound.midY)
        var xform  = CGAffineTransform.identity

        xform = xform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        xform = xform.concatenating(transform())
        xform = xform.concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        apply(xform)

        return self
    }
}
