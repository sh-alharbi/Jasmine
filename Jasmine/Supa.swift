//
//  Supa.swift
//  testf
//
//  Created by Shahad Alharbi on 11/5/25.
//

import Supabase
import Foundation

enum Supa {
  static let client = SupabaseClient(
    supabaseURL: URL(string: "https://sdeapmgcniyyzbqtjybh.supabase.co")!, // url of our project in supa
    supabaseKey:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkZWFwbWdjbml5eXpicXRqeWJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNTAwNTYsImV4cCI6MjA3NzkyNjA1Nn0.fE6Vp1EN6AFAb05E8AJUl8Xt9f3S2WNxwlp9XuqFlbA" // anon key
  )
}
