;; Insurance Pool Contract
;; Handles individual pool logic

;; Constants
(define-constant err-not-initialized (err u100))
(define-constant err-already-initialized (err u101))
(define-constant err-low-contribution (err u102))
(define-constant err-no-claim (err u103))
(define-constant err-already-voted (err u104))
(define-constant err-insufficient-votes (err u105))
(define-constant err-claim-expired (err u106))
(define-constant err-insufficient-funds (err u107))
(define-constant err-exceeds-coverage (err u108))

;; Events
(define-data-var last-event-id uint u0)
(define-map events uint {event-type: (string-ascii 20), data: (string-ascii 256)})

;; [Previous data vars and maps remain unchanged]

;; Helper function to emit events
(define-private (emit-event (event-type (string-ascii 20)) (data (string-ascii 256)))
  (let ((event-id (var-get last-event-id)))
    (map-set events event-id {event-type: event-type, data: data})
    (var-set last-event-id (+ event-id u1))))

;; Initialize pool [previous implementation remains unchanged]

;; Contribute to pool
(define-public (contribute (amount uint))
  (begin
    (asserts! (var-get initialized) err-not-initialized)
    (let ((current-contribution (default-to u0 (map-get? contributors tx-sender))))
      (if (< amount (var-get min-contribution))
        err-low-contribution
        (begin
          (map-set contributors tx-sender (+ current-contribution amount))
          (var-set total-funds (+ (var-get total-funds) amount))
          (emit-event "contribution" (concat (to-ascii amount) " contributed"))
          (ok true))))))

;; File claim
(define-public (file-claim (amount uint) (description (string-ascii 256)))
  (begin
    (asserts! (var-get initialized) err-not-initialized)
    (asserts! (<= amount (var-get coverage-amount)) err-exceeds-coverage)
    (let ((claim-id (var-get next-claim-id))
          (block-height (unwrap! block-height u0)))
      (map-set claims claim-id {
        amount: amount,
        description: description,
        claimant: tx-sender,
        approved-amount: u0,
        status: "pending",
        votes-yes: u0,
        votes-no: u0,
        created-at: block-height,
        expires-at: (+ block-height u144)
      })
      (var-set next-claim-id (+ claim-id u1))
      (emit-event "claim-filed" (concat "Claim " (to-ascii claim-id)))
      (ok claim-id))))

;; [Remaining functions updated similarly with initialization checks and events]
