;; Pool Factory Contract
;; Creates and manages insurance pools

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-params (err u101))
(define-constant err-min-contribution-too-low (err u102))
(define-constant err-coverage-too-high (err u103))

;; [Previous data vars and maps remain unchanged]

;; Create new insurance pool
(define-public (create-pool 
  (name (string-ascii 64))
  (min-contribution uint)
  (coverage-amount uint))
  (begin
    (asserts! (>= min-contribution u100000) err-min-contribution-too-low)
    (asserts! (<= coverage-amount u1000000000) err-coverage-too-high)
    (let
      ((pool-id (var-get next-pool-id)))
      (try! (contract-call? .insurance-pool initialize 
        name
        min-contribution
        coverage-amount
        tx-sender))
      (map-set pools pool-id {
        pool-contract: .insurance-pool,
        name: name,
        min-contribution: min-contribution, 
        coverage-amount: coverage-amount,
        created-by: tx-sender,
        is-active: true
      })
      (var-set next-pool-id (+ pool-id u1))
      (ok pool-id))))

;; [Remaining functions unchanged]
