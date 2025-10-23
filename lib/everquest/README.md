# EverQuest Constants

This directory contains Project 1999-specific EverQuest constants and utilities.

## Files

### `constants.rb`

Defines all P99 EverQuest game constants:

- **CLASSES** - All 14 playable classes in P99
- **RACES** - All 12 playable races in P99
- **SERVERS** - Blue (Velious) and Green (Kunark) servers
- **MAX_LEVEL** / **MIN_LEVEL** - Level cap (1-60)
- **RAID_ZONES** - Common raid zones
- **RAID_TARGETS** - Common raid boss targets

## Usage

```ruby
require_relative "lib/everquest/constants"

# Validate a class name
if EverQuest::CLASSES.include?(character_class)
  # Valid P99 class
end

# Validate level range
if level.between?(EverQuest::MIN_LEVEL, EverQuest::MAX_LEVEL)
  # Valid level
end

# Get raid zones for dropdown
EverQuest::RAID_ZONES.each do |zone|
  # Populate select options
end
```

## Testing

Tests are located in `spec/lib/everquest/constants_spec.rb`.

```bash
bundle exec rspec spec/lib/everquest/constants_spec.rb
```

## Notes

- All constants are frozen (immutable)
- Based on Project 1999 Classic/Kunark/Velious eras
- Does NOT include expansions beyond Velious (no PoP, etc.)
