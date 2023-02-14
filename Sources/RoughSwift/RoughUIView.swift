//
//  RoughUIView.swift
//  RoughSwift
//
//  Created by khoa on 26/03/2022.
//

import SwiftUI
import UIKit

final class RoughUIView: UIView {
    var drawbles: [Drawable]?

    var options: Options? {
        didSet {
            guard options != oldValue else {
                return
            }
            guard let drawbles, let options else {
                return
            }
            update(drawables: drawbles, options: options)
        }
    }

    var previousBounds: CGRect = .zero

    override func layoutSubviews() {
        super.layoutSubviews()

        if previousBounds != bounds {
            previousBounds = bounds

            if let drawbles = drawbles, let options = options {
                update(drawables: drawbles, options: options)
            }
        }
    }

    private func update(drawables: [Drawable], options: Options) {
        layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }

        let renderer = PathRenderer()
        let generator = Engine.shared.generator(size: bounds.size)
        for drawable in drawables {
            if let drawing = generator.generate(drawable: drawable, options: options) {
                let shapeLayer = CAShapeLayer()
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.frame = bounds
                shapeLayer.path = renderer.render(drawing: drawing).cgPath
                shapeLayer.strokeColor = options.fill.cgColor
//                shapeLayer.fillColor = options.s.cgColor
                layer.addSublayer(shapeLayer)
            }
        }
    }
}
