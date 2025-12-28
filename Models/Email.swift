//
//  Email.swift
//  MailAsistant
//
//  Created by Ledin, Evgenii on 27.12.2025.
//

import Foundation

struct Email: Identifiable, Hashable {
    let id = UUID()
    let from: String
    let subject: String
    let preview: String
    let body: String
}
