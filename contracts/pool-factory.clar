;; Pool Factory Contract
;; Creates and manages insurance pools

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-params (err u101))

;; Data vars
(define-data-var next-pool-id uint u0)

;; Data maps
(define-map pools uint {
  pool-contract: principal,
  name: (string-ascii 64),
  min-contribution: uint,
  coverage-amount: uint,
  created-by: principal
})

;; Create new insurance pool
(define-public (create-pool 
  (name (string-ascii 64))
  (min-contribution uint)
  (coverage-amount uint))
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
      created-by: tx-sender
    })
    (var-set next-pool-id (+ pool-id u1))
    (ok pool-id)))

;; Get pool details
(define-read-only (get-pool (pool-id uint))
  (ok (map-get? pools pool-id)))
