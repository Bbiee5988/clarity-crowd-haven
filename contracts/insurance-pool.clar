;; Insurance Pool Contract
;; Handles individual pool logic

;; Constants
(define-constant err-not-initialized (err u100))
(define-constant err-already-initialized (err u101))
(define-constant err-low-contribution (err u102))
(define-constant err-no-claim (err u103))
(define-constant err-already-voted (err u104))

;; Data vars
(define-data-var initialized bool false)
(define-data-var pool-name (string-ascii 64) "")
(define-data-var min-contribution uint u0)
(define-data-var coverage-amount uint u0)
(define-data-var pool-admin principal tx-sender)
(define-data-var total-funds uint u0)
(define-data-var next-claim-id uint u0)

;; Data maps
(define-map contributors principal uint)
(define-map claims uint {
  amount: uint,
  description: (string-ascii 256),
  claimant: principal,
  approved-amount: uint,
  status: (string-ascii 20),
  votes-yes: uint,
  votes-no: uint
})
(define-map claim-votes (tuple (claim-id uint) (voter principal)) bool)

;; Initialize pool
(define-public (initialize 
  (name (string-ascii 64))
  (min-contrib uint)
  (coverage uint)
  (admin principal))
  (if (var-get initialized)
    err-already-initialized
    (begin
      (var-set initialized true)
      (var-set pool-name name)
      (var-set min-contribution min-contrib)
      (var-set coverage-amount coverage)
      (var-set pool-admin admin)
      (ok true))))

;; Contribute to pool
(define-public (contribute (amount uint))
  (let ((current-contribution (default-to u0 (map-get? contributors tx-sender))))
    (if (< amount (var-get min-contribution))
      err-low-contribution
      (begin
        (map-set contributors tx-sender (+ current-contribution amount))
        (var-set total-funds (+ (var-get total-funds) amount))
        (ok true)))))

;; File claim
(define-public (file-claim (amount uint) (description (string-ascii 256)))
  (let ((claim-id (var-get next-claim-id)))
    (map-set claims claim-id {
      amount: amount,
      description: description,
      claimant: tx-sender,
      approved-amount: u0,
      status: "pending",
      votes-yes: u0,
      votes-no: u0
    })
    (var-set next-claim-id (+ claim-id u1))
    (ok claim-id)))

;; Vote on claim
(define-public (vote-on-claim (claim-id uint) (approve bool))
  (let ((claim (unwrap! (map-get? claims claim-id) err-no-claim))
        (vote-key {claim-id: claim-id, voter: tx-sender}))
    (if (map-get? claim-votes vote-key)
      err-already-voted
      (begin
        (map-set claim-votes vote-key true)
        (if approve
          (map-set claims claim-id (merge claim {votes-yes: (+ (get votes-yes claim) u1)}))
          (map-set claims claim-id (merge claim {votes-no: (+ (get votes-no claim) u1)})))
        (ok true)))))
