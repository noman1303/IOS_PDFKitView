//
//  DocumentPicker.swift
//  PDFKitView
//
//  Created by Noman belim on 28/01/26.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

final class DocumentPicker: NSObject, UIDocumentPickerDelegate {
    private let onPick: (URL) -> Void

    init(onPick: @escaping (URL) -> Void) {
        self.onPick = onPick
    }

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }
        onPick(url)
    }

    func documentPickerWasCancelled(
        _ controller: UIDocumentPickerViewController
    ) {
        controller.dismiss(animated: true)
    }
}
