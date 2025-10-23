# frozen_string_literal: true

require "rails_helper"
require_relative "../../../lib/everquest/constants"

RSpec.describe EverQuest do
  describe "CLASSES" do
    it "contains all 14 P99 classes" do
      expect(described_class::CLASSES.size).to eq(14)
    end

    it "includes core tank classes" do
      expect(described_class::CLASSES).to include("Warrior", "Shadow Knight", "Paladin")
    end

    it "includes priest classes" do
      expect(described_class::CLASSES).to include("Cleric", "Druid", "Shaman")
    end

    it "includes caster classes" do
      expect(described_class::CLASSES).to include("Wizard", "Magician", "Necromancer", "Enchanter")
    end

    it "includes hybrid/melee classes" do
      expect(described_class::CLASSES).to include("Ranger", "Monk", "Bard", "Rogue")
    end

    it "is frozen" do
      expect(described_class::CLASSES).to be_frozen
    end
  end

  describe "RACES" do
    it "contains all 12 P99 races" do
      expect(described_class::RACES.size).to eq(12)
    end

    it "includes all expected races" do
      expect(described_class::RACES).to include(
        "Human", "Barbarian", "Erudite", "Wood Elf", "High Elf", "Dark Elf",
        "Half Elf", "Dwarf", "Troll", "Ogre", "Halfling", "Gnome"
      )
    end

    it "is frozen" do
      expect(described_class::RACES).to be_frozen
    end
  end

  describe "SERVERS" do
    it "contains Blue and Green servers" do
      expect(described_class::SERVERS).to eq(%w[Blue Green])
    end

    it "is frozen" do
      expect(described_class::SERVERS).to be_frozen
    end
  end

  describe "level constants" do
    it "has correct max level" do
      expect(described_class::MAX_LEVEL).to eq(60)
    end

    it "has correct min level" do
      expect(described_class::MIN_LEVEL).to eq(1)
    end
  end

  describe "RAID_ZONES" do
    it "includes classic planes" do
      expect(described_class::RAID_ZONES).to include(
        "Plane of Fear",
        "Plane of Hate",
        "Plane of Sky"
      )
    end

    it "includes dragon lairs" do
      expect(described_class::RAID_ZONES).to include(
        "Nagafen's Lair",
        "Vox's Lair"
      )
    end

    it "is frozen" do
      expect(described_class::RAID_ZONES).to be_frozen
    end
  end

  describe "RAID_TARGETS" do
    it "includes classic dragons" do
      expect(described_class::RAID_TARGETS).to include(
        "Lord Nagafen",
        "Lady Vox"
      )
    end

    it "includes plane gods" do
      expect(described_class::RAID_TARGETS).to include(
        "Cazic-Thule",
        "Innoruuk"
      )
    end

    it "includes Kunark/Velious dragons" do
      expect(described_class::RAID_TARGETS).to include(
        "Trakanon",
        "Talendor",
        "Severilous",
        "Gorenaire"
      )
    end

    it "is frozen" do
      expect(described_class::RAID_TARGETS).to be_frozen
    end
  end
end
