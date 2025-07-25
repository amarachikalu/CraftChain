;; CraftChain: Artisan Craft Creation and Skill Reward System
;; Version: 1.0.0

;; Constants
(define-constant WORKSHOP_CAPACITY u1800000)
(define-constant BASE_CRAFT_REWARD u22)
(define-constant MASTERY_BONUS u8)
(define-constant MAX_ARTISAN_LEVEL u12)
(define-constant ERR_INVALID_CRAFT_ACTIVITY u1)
(define-constant ERR_NO_CRAFT_TOKENS u2)
(define-constant ERR_WORKSHOP_CAPACITY_EXCEEDED u3)
(define-constant BLOCKS_PER_CRAFT_SEASON u1728)
(define-constant TOOL_PRESERVATION_MULTIPLIER u4)
(define-constant MIN_PRESERVATION_PERIOD u864)
(define-constant EARLY_CRAFT_PENALTY u15)

;; Data Variables
(define-data-var total-craft-tokens-distributed uint u0)
(define-data-var total-craft-activities uint u0)
(define-data-var workshop-supervisor principal tx-sender)

;; Data Maps
(define-map artisan-activities principal uint)
(define-map artisan-craft-tokens principal uint)
(define-map craft-activity-start-time principal uint)
(define-map artisan-mastery-level principal uint)
(define-map artisan-last-activity principal uint)
(define-map artisan-preserved-tools principal uint)
(define-map artisan-preservation-start-block principal uint)

;; Public Functions
(define-public (start-craft-activity (craft-complexity uint))
  (let
    (
      (artisan tx-sender)
    )
    (asserts! (> craft-complexity u0) (err ERR_INVALID_CRAFT_ACTIVITY))
    (map-set craft-activity-start-time artisan burn-block-height)
    (ok true)
  ))

(define-public (complete-craft-creation (craft-complexity uint))
  (let
    (
      (artisan tx-sender)
      (start-block (default-to u0 (map-get? craft-activity-start-time artisan)))
      (blocks-crafting (- burn-block-height start-block))
      (last-activity-block (default-to u0 (map-get? artisan-last-activity artisan)))
      (mastery-level (default-to u0 (map-get? artisan-mastery-level artisan)))
      (capped-mastery (if (<= mastery-level MAX_ARTISAN_LEVEL) mastery-level MAX_ARTISAN_LEVEL))
      (craft-reward (+ BASE_CRAFT_REWARD (* capped-mastery MASTERY_BONUS)))
    )
    (asserts! (and (> start-block u0) (>= blocks-crafting craft-complexity)) (err ERR_INVALID_CRAFT_ACTIVITY))
    
    (map-set artisan-activities artisan (+ (default-to u0 (map-get? artisan-activities artisan)) u1))
    (map-set artisan-craft-tokens artisan (+ (default-to u0 (map-get? artisan-craft-tokens artisan)) craft-reward))
    
    (if (< (- burn-block-height last-activity-block) BLOCKS_PER_CRAFT_SEASON)
      (map-set artisan-mastery-level artisan (+ mastery-level u1))
      (map-set artisan-mastery-level artisan u1)
    )
    
    (map-set artisan-last-activity artisan burn-block-height)
    (var-set total-craft-activities (+ (var-get total-craft-activities) u1))
    (var-set total-craft-tokens-distributed (+ (var-get total-craft-tokens-distributed) craft-reward))
    
    (asserts! (<= (var-get total-craft-tokens-distributed) WORKSHOP_CAPACITY) (err ERR_WORKSHOP_CAPACITY_EXCEEDED))
    (ok craft-reward)
  ))

(define-public (claim-craft-rewards)
  (let
    (
      (artisan tx-sender)
      (token-balance (default-to u0 (map-get? artisan-craft-tokens artisan)))
    )
    (asserts! (> token-balance u0) (err ERR_NO_CRAFT_TOKENS))
    (map-set artisan-craft-tokens artisan u0)
    (ok token-balance)
  ))

;; Tool Preservation Features
(define-public (preserve-tools (amount uint))
  (let
    (
      (artisan tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_CRAFT_ACTIVITY))
    (asserts! (>= (var-get total-craft-tokens-distributed) amount) (err ERR_WORKSHOP_CAPACITY_EXCEEDED))
    
    (map-set artisan-preserved-tools artisan amount)
    (map-set artisan-preservation-start-block artisan burn-block-height)
    (var-set total-craft-tokens-distributed (- (var-get total-craft-tokens-distributed) amount))
    (ok amount)
  ))

(define-public (release-preserved-tools)
  (let
    (
      (artisan tx-sender)
      (preserved-amount (default-to u0 (map-get? artisan-preserved-tools artisan)))
      (preservation-start-block (default-to u0 (map-get? artisan-preservation-start-block artisan)))
      (blocks-preserved (- burn-block-height preservation-start-block))
      (penalty (if (< blocks-preserved MIN_PRESERVATION_PERIOD) (/ (* preserved-amount EARLY_CRAFT_PENALTY) u100) u0))
      (final-amount (- preserved-amount penalty))
    )
    (asserts! (> preserved-amount u0) (err ERR_NO_CRAFT_TOKENS))
    
    (map-set artisan-preserved-tools artisan u0)
    (map-set artisan-preservation-start-block artisan u0)
    (var-set total-craft-tokens-distributed (+ (var-get total-craft-tokens-distributed) final-amount))
    (ok final-amount)
  ))

;; Read-Only Functions
(define-read-only (get-craft-activity-count (user principal))
  (default-to u0 (map-get? artisan-activities user)))

(define-read-only (get-craft-token-balance (user principal))
  (default-to u0 (map-get? artisan-craft-tokens user)))

(define-read-only (get-mastery-level (user principal))
  (default-to u0 (map-get? artisan-mastery-level user)))

(define-read-only (get-workshop-stats)
  {
    total-craft-activities: (var-get total-craft-activities),
    total-craft-tokens-distributed: (var-get total-craft-tokens-distributed)
  })

;; Private Functions
(define-private (is-workshop-supervisor)
  (is-eq tx-sender (var-get workshop-supervisor)))