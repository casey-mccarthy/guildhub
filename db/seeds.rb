# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load EverQuest constants
require_relative "../lib/ever_quest"

puts "🎮 GuildHub - Project 1999 DKP System"
puts "=" * 50

# NOTE: Seed data will be expanded as models are created
# Future seed data will include:
# - Sample Guild with DKP configuration
# - Sample Event Types (raids)
# - Sample Characters with P99 classes/races
# - Sample Raids and attendance records
# - Sample Items and awards

puts "\n✅ EverQuest Constants Loaded:"
puts "   - Classes: #{EverQuest::CLASSES.size} (#{EverQuest::CLASSES.first} to #{EverQuest::CLASSES.last})"
puts "   - Races: #{EverQuest::RACES.size} (#{EverQuest::RACES.first} to #{EverQuest::RACES.last})"
puts "   - Servers: #{EverQuest::SERVERS.join(", ")}"
puts "   - Level Range: #{EverQuest::MIN_LEVEL}-#{EverQuest::MAX_LEVEL}"
puts "   - Raid Zones: #{EverQuest::RAID_ZONES.size} zones available"

puts "\n💡 Note: Additional seed data will be added as models are created in Phase 2"
puts "=" * 50
