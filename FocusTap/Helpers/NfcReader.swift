//
//  NfcReader.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//

import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
  @Published private(set) var message = "Waiting for NFC tag..."
  private var session: NFCNDEFReaderSession?
  private var onScanComplete: ((String) -> Void)?
  private var onWriteComplete: ((Bool) -> Void)?
  private var isWriting = false
  private var textToWrite: String?
  
  func scan(completion: @escaping (String) -> Void) {
    self.onScanComplete = completion
    self.isWriting = false
    startSession()
  }
  
  func write(_ text: String, completion: @escaping (Bool) -> Void) {
    self.onWriteComplete = completion
    self.textToWrite = text
    self.isWriting = true
    startSession()
  }
  
  private func startSession() {
    guard NFCNDEFReaderSession.readingAvailable else {
      NSLog("NFC is not available on this device")
      return
    }
    
    session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
    session?.alertMessage = isWriting ? 
    "Hold your iPhone near an NFC tag to write." : 
    "Hold your iPhone near an NFC tag to read."
    session?.begin()
  }
  
  private func processMessage(_ message: NFCNDEFMessage) {
    for record in message.records {
      if let text = extractText(from: record) {
        DispatchQueue.main.async {
          self.message = text
          self.onScanComplete?(text)
        }
        break
      }
    }
  }
  
  private func extractText(from record: NFCNDEFPayload) -> String? {
    switch record.typeNameFormat {
    case .nfcWellKnown:
      if let text = record.wellKnownTypeTextPayload().0 {
        return text
      } else if let url = record.wellKnownTypeURIPayload() {
        return url.absoluteString
      }
    case .absoluteURI:
      return String(data: record.payload, encoding: .utf8)
    default:
      return nil
    }
    return nil
  }
  
  private func handleReading(session: NFCNDEFReaderSession, tags: [NFCNDEFTag]) {
    guard let tag = tags.first, tags.count == 1 else {
      session.alertMessage = "More than 1 tag detected. Please try again with only one tag."
      session.invalidate()
      return
    }
    
    connectAndRead(tag: tag, session: session)
  }
  
  private func connectAndRead(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
    session.connect(to: tag) { [weak self] error in
      guard let self = self else { return }
      
      if let error = error {
        session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
        return
      }
      
      self.queryAndReadTag(tag: tag, session: session)
    }
  }
  
  private func queryAndReadTag(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
    tag.queryNDEFStatus { [weak self] status, _, error in
      guard let self = self else { return }
      
      if let error = error {
        session.invalidate(errorMessage: "Failed to query tag: \(error.localizedDescription)")
        return
      }
      
      switch status {
      case .notSupported:
        session.invalidate(errorMessage: "Tag is not NDEF compliant")
      case .readOnly, .readWrite:
        self.readTagContent(tag: tag, session: session)
      @unknown default:
        session.invalidate(errorMessage: "Unknown tag status")
      }
    }
  }
  
  private func readTagContent(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
    tag.readNDEF { [weak self] message, error in
      guard let self = self else { return }
      
      if let error = error {
        session.invalidate(errorMessage: "Read error: \(error.localizedDescription)")
      } else if let message = message {
        self.processMessage(message)
        session.alertMessage = "Tag read successfully!"
        session.invalidate()
      } else {
        session.invalidate(errorMessage: "No NDEF message found on tag")
      }
    }
  }
  
  private func handleWriting(session: NFCNDEFReaderSession, tags: [NFCNDEFTag]) {
    guard let tag = tags.first else {
      session.invalidate(errorMessage: "No tag detected")
      return
    }
    
    connectAndWrite(tag: tag, session: session)
  }
  
  private func connectAndWrite(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
    session.connect(to: tag) { [weak self] error in
      guard let self = self else { return }
      
      if let error = error {
        session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
        return
      }
      
      self.queryAndWriteTag(tag: tag, session: session)
    }
  }
  
  private func queryAndWriteTag(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
    tag.queryNDEFStatus { [weak self] status, _, error in
      guard let self = self else { return }
      
      if let error = error {
        session.invalidate(errorMessage: "Failed to query tag")
        return
      }
      
      switch status {
      case .notSupported:
        session.invalidate(errorMessage: "Tag is not NDEF compliant")
      case .readOnly:
        session.invalidate(errorMessage: "Tag is read-only")
      case .readWrite:
        self.writeTagContent(tag: tag, session: session)
      @unknown default:
        session.invalidate(errorMessage: "Unknown tag status")
      }
    }
  }
  
  private func writeTagContent(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
    guard let textToWrite = self.textToWrite,
          let payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: textToWrite)else {
      session.invalidate(errorMessage: "Unable to create payload with provided text: \(textToWrite ?? "No text provided")")
      return
    }

    let message = NFCNDEFMessage(records: [payload])
    
    tag.writeNDEF(message) { [weak self] error in
      guard let self = self else { return }
      
      if let error = error {
        session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
      } else {
        session.alertMessage = "Write successful!"
        session.invalidate()
      }
      
      DispatchQueue.main.async {
        self.onWriteComplete?(error == nil)
      }
    }
  }
  
  func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    guard !isWriting else { return }
    messages.forEach { processMessage($0) }
  }
  
  func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
    if isWriting {
      handleWriting(session: session, tags: tags)
    } else {
      handleReading(session: session, tags: tags)
    }
  }
  
  func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    if let readerError = error as? NFCReaderError,
       readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead,
       readerError.code != .readerSessionInvalidationErrorUserCanceled {
      NSLog("Session invalidated with error: \(error.localizedDescription)")
    }
    self.session = nil
  }
}
