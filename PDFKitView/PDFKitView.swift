//
//  PDFKitView.swift
//  PDFKitView
//
//  Created by Noman belim on 28/01/26.
//

import SwiftUI
import PDFKit

// Basic PDF viewing - annotation functionality now handled in ContentView
struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.enableDataDetectors = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Utility Functions for PDF Annotations
extension PDFPage {
    /// Add highlight annotation to selected text
    func addHighlight(selection: PDFSelection, color: UIColor) {
        let bounds = selection.bounds(for: self)
        let annotation = PDFAnnotation(
            bounds: bounds,
            forType: .highlight,
            withProperties: nil
        )
        annotation.color = color
        addAnnotation(annotation)
    }
    
    /// Add underline annotation to selected text
    func addUnderline(selection: PDFSelection, color: UIColor) {
        let bounds = selection.bounds(for: self)
        let annotation = PDFAnnotation(
            bounds: bounds,
            forType: .underline,
            withProperties: nil
        )
        annotation.color = color
        addAnnotation(annotation)
    }
    
    /// Add text note annotation at specific point
    func addTextNote(text: String, at point: CGPoint, size: CGSize = CGSize(width: 200, height: 50)) {
        let note = PDFAnnotation(
            bounds: CGRect(origin: point, size: size),
            forType: .freeText,
            withProperties: nil
        )
        note.contents = text
        note.font = UIFont.systemFont(ofSize: 14)
        note.color = .yellow
        note.fontColor = .black
        addAnnotation(note)
    }
}

// MARK: - Utility Functions for PDF Document
extension PDFDocument {
    /// Save PDF document with all annotations
    func saveWithAnnotations(to url: URL) -> Bool {
        return write(to: url)
    }
}
