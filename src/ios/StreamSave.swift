import Foundation
import MobileCoreServices
import UniformTypeIdentifiers
import UIKit

@objc(StreamSave) class StreamSave: CDVPlugin, UIDocumentPickerDelegate {
    
    var commandCallback: CDVInvokedUrlCommand?
    var sourceURL: URL?
    
    @objc(exportFile:)
    func exportFile(command: CDVInvokedUrlCommand) {
        guard let args = command.arguments[0] as? [String: Any],
              let path = args["sourcePath"] as? String,
              let suggestedName = args["suggestedName"] as? String,
              let mimeType = args["mimeType"] as? String else {
            self.sendError("Missing required arguments", command)
            return
        }
        
        // Resolve file path from string
        let localURL: URL?
        if path.starts(with: "file://") {
            localURL = URL(string: path)
        } else {
            localURL = URL(fileURLWithPath: path)
        }

        guard let resolvedURL = localURL else {
            self.sendError("Invalid file path", command)
            return
        }

        self.commandCallback = command
        self.sourceURL = resolvedURL

        // Copy the file to a temporary location to give UIDocumentPicker access
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(suggestedName)

        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            try FileManager.default.copyItem(at: resolvedURL, to: tempURL)
        } catch {
            self.sendError("Failed to copy file to temp: \(error.localizedDescription)", command)
            return
        }

        DispatchQueue.main.async {
            let documentPicker: UIDocumentPickerViewController
            if #available(iOS 14.0, *) {
                documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])
            } else {
                documentPicker = UIDocumentPickerViewController(url: tempURL, in: .exportToService)
            }

            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.viewController.present(documentPicker, animated: true, completion: nil)
        }
    }

    // MARK: UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let command = self.commandCallback {
            let result = CDVPluginResult(status: .ok, messageAs: "File saved successfully")
            self.commandDelegate.send(result, callbackId: command.callbackId)
            self.commandCallback = nil
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if let command = self.commandCallback {
            let result = CDVPluginResult(status: .error, messageAs: "User cancelled")
            self.commandDelegate.send(result, callbackId: command.callbackId)
            self.commandCallback = nil
        }
    }

    // MARK: Error Helper

    private func sendError(_ message: String, _ command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: .error, messageAs: message)
        self.commandDelegate.send(result, callbackId: command.callbackId)
        self.commandCallback = nil
    }
}