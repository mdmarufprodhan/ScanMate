//
//  PDFViewerView.swift
//  ScanMate
//
//  Created by Maruf on 26/6/25.
//
import SwiftUI
import PDFKit

struct PDFViewerView: View {
    let document: ScannedDocumentEntity
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showDeleteAlert = false
    @State private var showOCR = false
    @State private var previewImage: UIImage?
    
    var body: some View {
        VStack {
            if let pdfURL = getPDFURL() {
                PDFKitView(url: pdfURL)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                Text("Unable to load PDF.")
                    .foregroundColor(.red)
            }
            
            // 🔍 OCR Button (visible if preview image loaded)
            if let previewImage = previewImage {
                NavigationLink(destination: OCRView(image: previewImage), isActive: $showOCR) {
                    EmptyView()
                }
                
                Button("Extract Text from PDF") {
                    showOCR = true
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .navigationTitle(document.title ?? "PDF Document")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if let url = getPDFURL() {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete this PDF?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteDocument()
            }
            Button("Cancel", role: .cancel) { }
        }
        .onAppear {
            loadPreviewImage()
        }
    }
    
    private func getPDFURL() -> URL? {
        guard let path = document.filePath else { return nil }
        return URL(fileURLWithPath: path)
    }
    
    private func deleteDocument() {
        if let path = document.filePath {
            try? FileManager.default.removeItem(atPath: path)
        }
        
        viewContext.delete(document)
        try? viewContext.save()
        dismiss()
    }
    
    private func loadPreviewImage() {
        guard let url = getPDFURL(), let doc = PDFDocument(url: url),
              let page = doc.page(at: 0) else { return }
        
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
        self.previewImage = img
    }
}
