//
//  OCRView.swift
//  ScanMate
//
//  Created by Maruf on 26/6/25.
//

import SwiftUI
import Vision

struct OCRView: View {
    let image: UIImage
    @State private var extractedText: String = "Extracting..."
    
    var body: some View {
        ScrollView {
            Text(extractedText)
                .padding()
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .navigationTitle("Extracted Text")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    UIPasteboard.general.string = extractedText
                }) {
                    Image(systemName: "doc.on.doc")
                }
                
                ShareLink(item: extractedText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            performOCR()
        }
    }
    
    private func performOCR() {
        guard let cgImage = image.cgImage else {
            extractedText = "Invalid image."
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                extractedText = "OCR Error: \(error.localizedDescription)"
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                extractedText = "No text found."
                return
            }
            
            let recognizedText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            
            DispatchQueue.main.async {
                extractedText = recognizedText.isEmpty ? "No text found." : recognizedText
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en", "bn"] // ✅ Use lowercase language codes
        request.usesLanguageCorrection = true
        request.revision = VNRecognizeTextRequestRevision3
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    extractedText = "Failed to perform OCR."
                }
            }
        }
    }
}
