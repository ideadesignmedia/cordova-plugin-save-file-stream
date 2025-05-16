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
              let mimeType = args["mimeType"] as? String
        else {
            self.sendError("Missing arguments", command)
            return
        }

        guard let localURL = URL(string: path.replacingOccurrences(of: "cdvfile://localhost/", with: self.commandDelegate.path(forResource: "")!)) else {
            self.sendError("Invalid file path", command)
            return
        }

        self.sourceURL = localURL
        self.commandCallback = command

        // Pick destination for export
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedName)

        do {
            if FileManager.default.fileExists(atPath: tempFileURL.path) {
                try FileManager.default.removeItem(at: tempFileURL)
            }
            try FileManager.default.copyItem(at: localURL, to: tempFileURL)
        } catch {
            self.sendError("Failed to prepare temp file: \(error.localizedDescription)", command)
            return
        }

        DispatchQueue.main.async {
            let documentPicker: UIDocumentPickerViewController

            if #available(iOS 14.0, *) {
                documentPicker = UIDocumentPickerViewController(forExporting: [tempFileURL])
            } else {
                documentPicker = UIDocumentPickerViewController(url: tempFileURL, in: .exportToService)
            }

            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet

            self.viewController.present(documentPicker, animated: true, completion: nil)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if let command = commandCallback {
            sendError("User canceled", command)
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let command = commandCallback {
            let result = CDVPluginResult(status: .ok, messageAs: "File saved")
            self.commandDelegate.send(result, callbackId: command.callbackId)
        }
    }

    private func sendError(_ message: String, _ command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: .error, messageAs: message)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
}