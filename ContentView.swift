import SwiftUI

struct ContentView: View {
    @State private var inbox: [Email] = [
        Email(
            from: "alice@gmail.com",
            subject: "Project update",
            preview: "Here is the latest status on...",
            body: "Hi team,\n\nHere is the latest status on the project. We completed the API integration and started QA on the new flows. Remaining items: performance tuning and accessibility checks.\n\nLet me know if you have questions.\n\nThanks,\nAlice"
        ),
        Email(
            from: "bob@gmail.com",
            subject: "Lunch tomorrow?",
            preview: "Are you free around noon...",
            body: "Hey there,\n\nAre you free around noon tomorrow? There’s a new place downtown I wanted to try. If that doesn’t work, we can do later in the afternoon.\n\nCheers,\nBob"
        ),
        Email(
            from: "team@newsletter.com",
            subject: "Weekly digest",
            preview: "Top stories this week...",
            body: "Your weekly digest is here!\n\n- Product updates and roadmap highlights\n- Tips & tricks for power users\n- Community spotlight\n\nRead more in the full post and let us know your feedback."
        )
    ]

    // Root screen state
    @State private var selectedEmail: Email? = nil
    @State private var isFetching = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                Divider()
                inboxList
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Image(systemName: "envelope.badge")
                .font(.title2)
                .foregroundStyle(.blue)
            Text("Mail Assistant")
                .font(.title2).bold()
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(action: fetchGmail) {
                Label("Get Gmail", systemImage: "arrow.down.circle")
            }
            .buttonStyle(.borderedProminent)
            .disabled(isFetching)
        }
        .padding()
        .background(.thinMaterial)
    }
    
    private func fetchGmail() {
        // TODO: Integrate Gmail API / OAuth flow
        isFetching = true
        defer { isFetching = false }
        // Simulate refresh
        inbox.shuffle()
    }

    private var inboxList: some View {
        List(selection: $selectedEmail) {
            Section("Inbox") {
                ForEach(inbox) { email in
                    NavigationLink(destination: ComposeView(email: email)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(email.from).font(.subheadline).foregroundStyle(.secondary)
                                Spacer()
                                Text(email.subject).font(.headline)
                            }
                            Text(email.preview)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Actions (placeholders)

}



// MARK: - Second Screen: Compose & Send

struct ComposeView: View {
    let email: Email
    @State private var composeText: String = ""
    @State private var isComposing = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            originalEmailCard
            composeArea
        }
        .navigationTitle("Reply")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: composeWithAI)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(email.subject).font(.headline)
                Text("From: \(email.from)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: composeWithAI) {
                Label("Draft with AI", systemImage: "wand.and.stars")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.thinMaterial)
    }

    private var originalEmailCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Original Email")
                .font(.headline)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text("From:").font(.subheadline).foregroundStyle(.secondary)
                    Text(email.from).font(.subheadline)
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("Subject:").font(.subheadline).foregroundStyle(.secondary)
                    Text(email.subject).font(.subheadline)
                }
                ScrollView {
                    Text(email.body)
                        .font(.footnote)
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 240)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .padding([.horizontal, .top])
    }

    private var composeArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $composeText)
                .frame(minHeight: 200)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.08)))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .padding()

            HStack {
                Spacer()
                Button(action: sendReply) {
                    Label("Send", systemImage: "paperplane.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(composeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding([.horizontal, .bottom])
        }
    }

    // MARK: - Actions (placeholders)
    private func composeWithAI() {
        Task {
            isComposing = true
            defer { isComposing = false }
            do {
                let draft = try await AIService.generateReply(for: email, tone: "professional")
                composeText = draft
            } catch {
                composeText = """
                Hi \(email.from.split(separator: "@").first ?? "there"),

                Thanks for your message about \(email.subject.lowercased()). Here are my thoughts...

                Best regards,
                Your Name
                """
                print("AI error:", error.localizedDescription)
            }
        }
    }

    private func sendReply() {
        // TODO: Send reply via Gmail API
        composeText = ""
    }
}

#Preview {
    ContentView()
}
