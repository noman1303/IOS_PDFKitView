//
//  ContentView.swift
//  PDFKitView
//
//  Created by Noman belim on 28/01/26.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

enum AnnotationMode {
    case none
    case highlight
    case underline
    case note
    case signature
}

struct ContentView: View {
    @State private var pdfURL: URL?
    @State private var showPicker = false
    @State private var pdfDocument: PDFDocument?
    @State private var annotationMode: AnnotationMode = .none
    @State private var highlightColor: UIColor = .yellow
    @State private var showColorPicker = false
    @State private var showNotePicker = false
    @State private var noteText = ""
    @State private var notePoint: CGPoint = .zero
    @State private var selectedPage: PDFPage?
    @State private var showSignature = false
    @State private var showSaveAlert = false
    @State private var signaturePoint: CGPoint = .zero

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let document = pdfDocument {
                    PDFKitRepresentable(
                        document: document,
                        annotationMode: $annotationMode,
                        highlightColor: $highlightColor,
                        onNoteRequest: { page, point in
                            selectedPage = page
                            notePoint = point
                            showNotePicker = true
                        },
                        onSignatureRequest: { page, point in
                            selectedPage = page
                            signaturePoint = point
                            showSignature = true
                        }
                    )
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No PDF Selected")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Tap the document icon to open a PDF")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Toolbar
                if pdfDocument != nil {
                    toolbarView
                }
            }
            .navigationTitle("PDF Viewer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPicker = true
                    } label: {
                        Image(systemName: "doc")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        savePDF()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .disabled(pdfDocument == nil)
                }
            }
        }
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleFileResult(result)
        }
        .sheet(isPresented: $showNotePicker) {
            noteInputView
        }
        .sheet(isPresented: $showSignature) {
            signatureView
        }
        .alert("PDF Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your PDF with annotations has been saved successfully")
        }
    }
    
    // MARK: - Toolbar View
    private var toolbarView: some View {
        HStack(spacing: 15) {
            // Highlight Button
            Button {
                annotationMode = annotationMode == .highlight ? .none : .highlight
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "highlighter")
                        .font(.title3)
                    Text("Highlight")
                        .font(.caption2)
                }
                .foregroundColor(annotationMode == .highlight ? .blue : .primary)
                .frame(maxWidth: .infinity)
            }
            
            // Underline Button
            Button {
                annotationMode = annotationMode == .underline ? .none : .underline
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "underline")
                        .font(.title3)
                    Text("Underline")
                        .font(.caption2)
                }
                .foregroundColor(annotationMode == .underline ? .blue : .primary)
                .frame(maxWidth: .infinity)
            }
            
            // Color Picker
            Button {
                showColorPicker.toggle()
            } label: {
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color(highlightColor))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Text("Color")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }
            .popover(isPresented: $showColorPicker) {
                colorPickerView
                    .frame(width: 300, height: 200)
            }
            
            // Note Button
            Button {
                annotationMode = annotationMode == .note ? .none : .note
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "note.text")
                        .font(.title3)
                    Text("Note")
                        .font(.caption2)
                }
                .foregroundColor(annotationMode == .note ? .blue : .primary)
                .frame(maxWidth: .infinity)
            }
//            
//            // Signature Button
//            Button {
//                annotationMode = annotationMode == .signature ? .none : .signature
//            } label: {
//                VStack(spacing: 4) {
//                    Image(systemName: "signature")
//                        .font(.title3)
//                    Text("Sign")
//                        .font(.caption2)
//                }
//                .foregroundColor(annotationMode == .signature ? .blue : .primary)
//                .frame(maxWidth: .infinity)
//            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Color Picker View
    private var colorPickerView: some View {
        VStack(spacing: 15) {
            Text("Select Highlight Color")
                .font(.headline)
                .padding(.top)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 15) {
                ForEach(Array(availableColors.enumerated()), id: \.offset) { index, color in
                    Circle()
                        .fill(Color(color))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(highlightColor.isEqual(to: color) ? Color.blue : Color.gray, lineWidth: highlightColor.isEqual(to: color) ? 3 : 1)
                        )
                        .onTapGesture {
                            highlightColor = color
                            showColorPicker = false
                        }
                }
            }
            .padding()
        }
    }
    
    private var availableColors: [UIColor] {
        [.yellow, .green, .cyan, .blue, .purple, .red, .orange, .magenta]
    }
    
    // MARK: - Note Input View
    private var noteInputView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Note")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextEditor(text: $noteText)
                    .frame(height: 150)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Button {
                    addNote()
                } label: {
                    Text("Add Note")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(noteText.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(noteText.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                trailing: Button("Cancel") {
                    noteText = ""
                    showNotePicker = false
                    annotationMode = .none
                }
            )
        }
    }
    
    // MARK: - Signature View
    private var signatureView: some View {
        NavigationView {
            VStack {
                Text("Draw Your Signature")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                
                Text("Tap on the PDF where you want to place it, then draw your signature here")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                SignatureCanvasView { image in
                    addSignature(image: image)
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationBarItems(
                trailing: Button("Cancel") {
                    showSignature = false
                    annotationMode = .none
                }
            )
        }
    }
    
    // MARK: - Helper Functions
    private func handleFileResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            pdfURL = url
            pdfDocument = PDFDocument(url: url)
            
        case .failure(let error):
            print("File import error:", error.localizedDescription)
        }
    }
    
    private func addNote() {
        guard let page = selectedPage else { return }
        
        let note = PDFAnnotation(
            bounds: CGRect(x: notePoint.x, y: notePoint.y, width: 200, height: 50),
            forType: .freeText,
            withProperties: nil
        )
        note.contents = noteText
        note.font = UIFont.systemFont(ofSize: 14)
        note.color = .yellow
        note.fontColor = .black
        page.addAnnotation(note)
        
        noteText = ""
        showNotePicker = false
        annotationMode = .none
    }
    
    private func addSignature(image: UIImage) {
        guard let page = selectedPage else {
            print("No page selected")
            return
        }
        
        // Adjust the signature size and position
        let signatureWidth: CGFloat = 150
        let signatureHeight: CGFloat = 75
        
        // Create bounds for the signature
        let bounds = CGRect(
            x: signaturePoint.x - signatureWidth / 2,
            y: signaturePoint.y - signatureHeight / 2,
            width: signatureWidth,
            height: signatureHeight
        )
        
        // Create image annotation
        let annotation = ImageStampAnnotation(with: image, forBounds: bounds, withProperties: nil)
        page.addAnnotation(annotation)
        
        showSignature = false
        annotationMode = .none
        
        print("Signature added at: \(signaturePoint)")
    }
    
    private func savePDF() {
        guard let document = pdfDocument else { return }
        
        // Create a temporary URL for saving
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "annotated_\(Date().timeIntervalSince1970).pdf"
        let saveURL = documentsPath.appendingPathComponent(fileName)
        
        // Write the PDF with annotations
        if document.write(to: saveURL) {
            print("PDF saved to: \(saveURL.path)")
            showSaveAlert = true
        } else {
            print("Failed to save PDF")
        }
    }
}

// MARK: - PDF Kit Representable
struct PDFKitRepresentable: UIViewRepresentable {
    let document: PDFDocument
    @Binding var annotationMode: AnnotationMode
    @Binding var highlightColor: UIColor
    var onNoteRequest: (PDFPage, CGPoint) -> Void
    var onSignatureRequest: (PDFPage, CGPoint) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.enableDataDetectors = true
        
        // Add tap gesture for notes and signatures
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        pdfView.addGestureRecognizer(tapGesture)
        
        context.coordinator.pdfView = pdfView
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        context.coordinator.parent = self
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: PDFKitRepresentable
        weak var pdfView: PDFView?
        
        init(_ parent: PDFKitRepresentable) {
            self.parent = parent
            super.init()
        }
        
        // Allow tap gesture to work alongside PDF view's gestures
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let pdfView = pdfView else { return }
            
            let location = gesture.location(in: pdfView)
            guard let page = pdfView.page(for: location, nearest: true) else { return }
            let pagePoint = pdfView.convert(location, to: page)
            
            print("Tap detected - Mode: \(parent.annotationMode), Point: \(pagePoint)")
            
            switch parent.annotationMode {
            case .highlight, .underline:
                // Add highlight/underline if there's a selection
                if let selection = pdfView.currentSelection {
                    addAnnotation(selection: selection, isUnderline: parent.annotationMode == .underline)
                }
            case .note:
                print("Note mode - requesting note input")
                parent.onNoteRequest(page, pagePoint)
            case .signature:
                print("Signature mode - requesting signature")
                parent.onSignatureRequest(page, pagePoint)
            case .none:
                break
            }
        }
        
        private func addAnnotation(selection: PDFSelection, isUnderline: Bool) {
            selection.pages.forEach { page in
                let bounds = selection.bounds(for: page)
                let annotation = PDFAnnotation(
                    bounds: bounds,
                    forType: isUnderline ? .underline : .highlight,
                    withProperties: nil
                )
                annotation.color = parent.highlightColor
                page.addAnnotation(annotation)
            }
            pdfView?.clearSelection()
        }
    }
}

// MARK: - Image Stamp Annotation
class ImageStampAnnotation: PDFAnnotation {
    var image: UIImage?
    
    convenience init(with image: UIImage, forBounds bounds: CGRect, withProperties properties: [AnyHashable: Any]?) {
        self.init(bounds: bounds, forType: .stamp, withProperties: properties)
        self.image = image
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let image = image?.cgImage else {
            print("No image to draw")
            return
        }
        
        UIGraphicsPushContext(context)
        context.saveGState()
        
        // Draw image in the annotation bounds
        let drawingRect = bounds
        context.draw(image, in: drawingRect)
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}

// Extension to make UIColor identifiable for color picker
extension UIColor {
    func isEqual(to color: UIColor) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
    }
}

#Preview {
    ContentView()
}
