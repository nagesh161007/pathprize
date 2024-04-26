//
//  supabase.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/18/24.
//

import Foundation

import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://fbtrxsiffjdpeybbxalp.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZidHJ4c2lmZmpkcGV5YmJ4YWxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTkyMDUzMzgsImV4cCI6MjAxNDc4MTMzOH0.WrD2hQon8qH0ig37pgSVlkzzIOi23NUtie9bcKSyQV0"
)
