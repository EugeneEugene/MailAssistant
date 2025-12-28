//
//  AIService.swift
//  MailAsistant
//
//  Created by Ledin, Evgenii on 28.12.2025.
//

import Foundation

struct AIService {
    enum AIError: Error {
        case missingAPIKey
        case BadResponse
    }

    static func apiKey() -> String? {
        if let plistKey = Bundle.main.object(
            forInfoDictionaryKey: "OpenAIAPIKey"
        ) as? String, !plistKey.isEmpty {
            return plistKey
        }
        return nil
    }

    static func generateReply(for email: Email, tone: String = "professional")
        async throws -> String
    {
        guard let key = apiKey() else { throw AIError.missingAPIKey }
        let url = URL(string: "https://api.openai.com/v1/responses")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: where the magic happens
        let prompt = """
            You are an assistant that drafts clear, \(tone) email replies.
            Original email:
            From: \(email.from)
            Subject: \(email.subject)

            \(email.body)

            Write a reply. Start with a greeting and end with a sign-off.

            and translate to russian
            """

        struct Payload: Encodable {
            let model: String
            let input: String
        }

        let payload = Payload(
            model: "gpt-4.1-mini",  // use a valid model for responses API
            input: prompt
        )

        request.httpBody = try JSONEncoder().encode(payload)
        let (data, response) = try await URLSession.shared.data(for: request)

        struct ResponseData: Decodable {
            struct Output: Decodable {
                struct Content: Decodable {
                    let type: String
                    let text: String?
                }
                let content: [Content]
            }
            let output: [Output]
        }

        //TODO: try maybe validate status code?
        let decoded = try JSONDecoder().decode(ResponseData.self, from: data)

        let reply = decoded.output
            .first?
            .content
            .first(where: { $0.type == "output_text" })?
            .text?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return reply
            ?? ""
    }
}
