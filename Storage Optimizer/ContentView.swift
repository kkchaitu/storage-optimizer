import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = PhotoScanner()
    @State private var selectedCategory: ScanCategory? = nil
    @State private var showSuccess = false
    @State private var recoveredBytes: Int = 0

    var body: some View {
        NavigationStack {
            DashboardView(selectedCategory: $selectedCategory, recoveredBytes: $recoveredBytes, scanner: scanner)
                .navigationTitle("Storage Optimizer")
                .toolbarBackground(Theme.primary, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: PhotoScannerView(scanner: scanner)) {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.white)
                        }
                    }
                }
                .navigationDestination(isPresented: Binding(
                    get: { selectedCategory != nil },
                    set: { if !$0 { selectedCategory = nil } }
                )) {
                    if let category = selectedCategory {
                        ReviewView(category: category, scanner: scanner, recoveredBytes: $recoveredBytes, showSuccess: $showSuccess)
                    }
                }
                .sheet(isPresented: $showSuccess) {
                    SuccessView(recoveredBytes: recoveredBytes)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
