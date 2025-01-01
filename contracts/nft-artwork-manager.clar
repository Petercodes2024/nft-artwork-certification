;; This smart contract manages the certification, minting, and transfer of unique digital artwork as Non-Fungible Tokens (NFTs).
;; It allows users to mint single or batch artwork certificates with metadata, transfer ownership, update artwork metadata (URI),
;; and burn (delete) artworks from circulation. Each artwork is tracked by a unique ID, and the contract ensures that only the rightful owner
;; can perform certain actions such as transferring or burning an artwork. The contract also enforces error handling for common issues such as
;; invalid URIs, non-existent artworks, and unauthorized actions.

;; Constants for error codes and maximum URI length. These constants help to standardize error handling in the contract.
(define-constant err-owner-only (err u100))               ;; Error if the caller is not the owner
(define-constant err-not-owner (err u101))                ;; Error if the caller is not the owner
(define-constant err-artwork-exists (err u102))           ;; Error if the artwork already exists
(define-constant err-artwork-not-found (err u103))        ;; Error if the artwork is not found
(define-constant err-invalid-uri (err u104))              ;; Error if the URI provided is invalid
(define-constant err-already-burned (err u105))           ;; Error if the artwork has already been burned
(define-constant max-uri-length u256)                     ;; Maximum allowed length for URI

;; Data Variables
(define-non-fungible-token digital-art uint)               ;; NFT token representing unique artworks
(define-data-var last-artwork-id uint u0)                   ;; Tracks the latest artwork ID issued

;; Maps to store artwork URIs and burned artwork status.
(define-map artwork-uri uint (string-ascii 256))           ;; Map artwork ID to its URI (metadata of the artwork)
(define-map burned-artworks uint bool)                      ;; Track if an artwork has been burned (revoked)

;; Private Helper Functions

;; Checks if a URI is valid by confirming its length is within the allowed range.
(define-private (is-valid-uri (uri (string-ascii 256)))
    (let ((uri-length (len uri)))
        (and (>= uri-length u1) (<= uri-length max-uri-length))))

;; Verifies whether the sender is the owner of the specified artwork.
(define-private (is-artwork-owner (artwork-id uint) (sender principal))
    (is-eq sender (unwrap! (nft-get-owner? digital-art artwork-id) false)))

;; Checks if an artwork is burned by looking it up in the burned-artworks map.
(define-private (is-artwork-burned (artwork-id uint))
    (default-to false (map-get? burned-artworks artwork-id)))

;; Creates a single artwork certificate, assigning it a unique ID and URI.
(define-private (create-single-artwork (artwork-uri-data (string-ascii 256)))
    (let ((artwork-id (+ (var-get last-artwork-id) u1)))
        (asserts! (is-valid-uri artwork-uri-data) err-invalid-uri)  ;; Check URI validity
        (try! (nft-mint? digital-art artwork-id tx-sender))           ;; Mint the artwork NFT
        (map-set artwork-uri artwork-id artwork-uri-data)            ;; Store the artwork URI (metadata)
        (var-set last-artwork-id artwork-id)                         ;; Update the last artwork ID issued
        (ok artwork-id)))                                            ;; Return the artwork ID created
