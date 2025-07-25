# CraftChain

A decentralized artisan craft creation and skill reward system for incentivizing traditional craftsmanship on Stacks blockchain.

## Features

- Craft activity tracking with complexity-based rewards
- Artisan mastery level progression with skill bonus multipliers
- Craft token accumulation and redemption system
- Tool preservation mechanism with time-based penalties
- Comprehensive workshop statistics and analytics

## Smart Contract Functions

### Public Functions
- `start-craft-activity` - Begin artisan craft creation session
- `complete-craft-creation` - Complete craft and earn rewards
- `claim-craft-rewards` - Claim accumulated craft tokens
- `preserve-tools` - Preserve tools for enhanced rewards
- `release-preserved-tools` - Release preserved tools with potential penalties

### Read-Only Functions
- `get-craft-activity-count` - Get user's total craft activities
- `get-craft-token-balance` - Get user's craft token balance
- `get-mastery-level` - Get user's artisan mastery level
- `get-workshop-stats` - Get overall workshop statistics

## Reward System
- Base reward: 22 tokens per craft
- Mastery bonus: 8 tokens per level (max level 12)
- Tool preservation multiplier: 4x for preserved tools
- Workshop capacity: 1.8M total tokens

## Usage

Deploy the contract to create an artisan craft system where creators can track their crafting activities, earn rewards, and preserve tools for enhanced benefits.

## License

MIT