import SwiftUI

struct SuccessView: View {
    let recoveredBytes: Int

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(Theme.primary)
                .padding()
                .background(Theme.primary.opacity(0.15))
                .clipShape(Circle())

            VStack(spacing: 10) {
                Text("Storage reclaimed")
                    .font(.title.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                Text("You recovered \(formattedBytes) of space with a safer cleanup.")
                    .font(.body)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button(action: {}) {
                Text("Back to Dashboard")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary)
                    .cornerRadius(16)
            }
            .padding(.horizontal)

            Spacer(minLength: 20)
        }
        .padding()
        .background(Theme.lightLavender.opacity(0.3).edgesIgnoringSafeArea(.all))
    }

    private var formattedBytes: String {
        let megabytes = Double(recoveredBytes) / 1_000_000
        if megabytes >= 1 {
            return String(format: "%.1f MB", megabytes)
        }
        return "\(recoveredBytes) bytes"
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView(recoveredBytes: 1_250_000)
    }
}
