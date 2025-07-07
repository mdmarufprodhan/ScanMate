//
//  ContentView.swift
//  ScanMate
//
//  Created by Maruf on 26/6/25.
//

import SwiftUI
import CoreData
import PDFKit

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ScannedDocumentEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ScannedDocumentEntity.date, ascending: false)],
        animation: .default
    )
    private var scannedDocs: FetchedResults<ScannedDocumentEntity>
    
    @State private var showingScanner = false
    
    var body: some View {
        NavigationView {
            VStack {
                if scannedDocs.isEmpty {
                    Spacer()
                    Text("No scanned documents yet.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Spacer()
                } else {
                    List {
                        ForEach(scannedDocs, id: \.self) { doc in
                            NavigationLink(destination: PDFViewerView(document: doc)) {
                                VStack(alignment: .leading) {
                                    TextField("Title", text: Binding(
                                        get: { doc.title ?? "Untitled" },
                                        set: { newValue in
                                            doc.title = newValue
                                            try? viewContext.save()
                                        })
                                    )
                                    .font(.headline)
                                    .textFieldStyle(.roundedBorder)
                                    
                                    if let date = doc.date {
                                        Text(date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                            }
                        }
                        .onDelete(perform: deleteDocuments)
                    }
                    
                }
                
                Button(action: {
                    showingScanner = true
                }) {
                    Text("Scan Document")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 10)
                .sheet(isPresented: $showingScanner) {
                    ScannerView { scannedImages in
                        saveScannedImagesAsPDF(scannedImages)
                    }
                }
            }
            .navigationTitle("My Documents")
            .toolbar {
                EditButton()
            }
        }
    }
    
    // MARK: - Save PDF
    private func saveScannedImagesAsPDF(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        let pdfDocument = PDFDocument()
        for (index, image) in images.enumerated() {
            if let page = PDFPage(image: image) {
                pdfDocument.insert(page, at: index)
            }
        }
        
        let filename = "Scan-\(UUID().uuidString).pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        pdfDocument.write(to: fileURL)
        
        let newDoc = ScannedDocumentEntity(context: viewContext)
        newDoc.id = UUID()
        newDoc.title = filename
        newDoc.date = Date()
        newDoc.filePath = fileURL.path
        
        try? viewContext.save()
    }
    
    // MARK: - Delete
    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            let document = scannedDocs[index]
            
            // Delete the file from disk
            if let path = document.filePath {
                try? FileManager.default.removeItem(atPath: path)
            }
            
            // Delete from Core Data
            viewContext.delete(document)
        }
        
        // Save the context
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete: \(error.localizedDescription)")
        }
    }
    
}
