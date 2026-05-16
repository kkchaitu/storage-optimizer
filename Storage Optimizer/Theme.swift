import SwiftUI

struct Theme {
    static let primary = Color(red: 150/255, green: 122/255, blue: 220/255)
    static let background = Color("Background")
    static let surface = Color.white
    static let textPrimary = Color(red: 33/255, green: 33/255, blue: 33/255)
    static let textSecondary = Color(red: 110/255, green: 110/255, blue: 110/255)
    static let accent = Color(red: 150/255, green: 122/255, blue: 220/255)
    static let lightLavender = Color(red: 240/255, green: 236/255, blue: 249/255)
}

extension View {
    func lavenderCardStyle() -> some View {
        self
            .padding()
            .background(Theme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 8)
    }
}
