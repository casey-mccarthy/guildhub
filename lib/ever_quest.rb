# frozen_string_literal: true

module EverQuest
  # Project 1999 EverQuest Classes
  CLASSES = [
    "Warrior",
    "Cleric",
    "Paladin",
    "Ranger",
    "Shadow Knight",
    "Druid",
    "Monk",
    "Bard",
    "Rogue",
    "Shaman",
    "Necromancer",
    "Wizard",
    "Magician",
    "Enchanter"
  ].freeze

  # Project 1999 EverQuest Races
  RACES = [
    "Human",
    "Barbarian",
    "Erudite",
    "Wood Elf",
    "High Elf",
    "Dark Elf",
    "Half Elf",
    "Dwarf",
    "Troll",
    "Ogre",
    "Halfling",
    "Gnome"
  ].freeze

  # P99 Servers
  SERVERS = %w[
    Blue
    Green
  ].freeze

  # Level cap for P99
  MAX_LEVEL = 60
  MIN_LEVEL = 1

  # Common raid zones
  RAID_ZONES = [
    "Plane of Fear",
    "Plane of Hate",
    "Plane of Sky",
    "Nagafen's Lair",
    "Vox's Lair",
    "Plane of Growth",
    "Kunark Dragons",
    "Velious Dragons",
    "Sleeper's Tomb",
    "Veeshan's Peak"
  ].freeze

  # Common raid targets
  RAID_TARGETS = [
    "Lord Nagafen",
    "Lady Vox",
    "Cazic-Thule",
    "Innoruuk",
    "Fear Golems",
    "Hate Raid",
    "Eye of Veeshan",
    "Talendor",
    "Severilous",
    "Gorenaire",
    "Trakanon",
    "Kerafyrm (The Sleeper)"
  ].freeze
end
