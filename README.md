# ChefNest
A decentralized cooking app focused on collaborative live cooking sessions with friends and family.

## Features
- Create cooking sessions
- Join existing sessions
- Share recipes
- Track participation
- Earn cooking points
- Rate sessions

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite

## Usage Examples
```clarity
;; Create a new cooking session
(contract-call? .chef-nest create-session "Italian Night" "Pizza making session" u1640995200)

;; Join an existing session
(contract-call? .chef-nest join-session u1)

;; Share a recipe
(contract-call? .chef-nest share-recipe u1 "Margherita Pizza" "Traditional Italian pizza...")

;; Rate a session
(contract-call? .chef-nest rate-session u1 u5)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
