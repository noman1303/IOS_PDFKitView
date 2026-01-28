//
//  SignatureView.swift
//  PDFKitView
//
//  Created by Noman belim on 28/01/26.
//

import SwiftUI
import PencilKit

struct SignatureView: UIViewRepresentable {
    let canvas = PKCanvasView()

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.backgroundColor = .clear
        canvas.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvas.drawingPolicy = .anyInput
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

// MARK: - Signature Canvas View with Actions
struct SignatureCanvasView: View {
    @State private var canvasView = PKCanvasView()
    @State private var hasDrawn = false
    var onComplete: (UIImage) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Canvas with placeholder
            ZStack {
                SignatureCanvasRepresentable(canvasView: $canvasView, hasDrawn: $hasDrawn)
                    .frame(minHeight: 300)
                
                if !hasDrawn {
                    Text("Draw your signature here")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.title3)
                        .allowsHitTesting(false)
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
            
            // Action Buttons
            HStack(spacing: 15) {
                Button {
                    canvasView.drawing = PKDrawing()
                    hasDrawn = false
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Clear")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                
                Button {
                    if hasDrawn {
                        // Get the drawing bounds
                        let drawingBounds = canvasView.drawing.bounds
                        
                        // Create image from drawing with proper bounds
                        let image = canvasView.drawing.image(
                            from: drawingBounds.isEmpty ? CGRect(x: 0, y: 0, width: 300, height: 150) : drawingBounds,
                            scale: 2.0
                        )
                        onComplete(image)
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Done")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(hasDrawn ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!hasDrawn)
            }
            .padding(.top, 15)
        }
    }
}

struct SignatureCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var hasDrawn: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        // Configure canvas for drawing
        canvasView.backgroundColor = .white
        canvasView.isOpaque = true
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        
        // IMPORTANT: Allow both touch and pencil input
        canvasView.drawingPolicy = .anyInput
        
        // Make sure it's user interaction enabled
        canvasView.isUserInteractionEnabled = true
        
        // Set delegate to track drawing changes
        canvasView.delegate = context.coordinator
        
        // Configure tool picker if available
        if let window = canvasView.window {
            let toolPicker = PKToolPicker.shared(for: window)
            toolPicker?.setVisible(false, forFirstResponder: canvasView)
            toolPicker?.addObserver(canvasView)
        }
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Ensure drawing policy is set
        uiView.drawingPolicy = .anyInput
        uiView.isUserInteractionEnabled = true
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SignatureCanvasRepresentable
        
        init(_ parent: SignatureCanvasRepresentable) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Update hasDrawn state when drawing changes
            parent.hasDrawn = !canvasView.drawing.bounds.isEmpty
            print("Drawing changed - bounds: \(canvasView.drawing.bounds)")
        }
    }
}
