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

;; Public Functions

;; Mints a new artwork certificate with the specified URI, which contains metadata about the artwork.
(define-public (mint-artwork (uri (string-ascii 256)))
    (begin
        (asserts! (is-valid-uri uri) err-invalid-uri)    ;; Validate URI length
        (create-single-artwork uri)))                    ;; Create the artwork and return its ID

;; Mints multiple artwork certificates in a single transaction, with a maximum of 100 artworks in one batch.
(define-public (batch-mint-artworks (uris (list 100 (string-ascii 256))))
    (let ((batch-size (len uris)))
        (begin
            (asserts! (<= batch-size u100) (err u108)) ;; Check if the batch size is within the allowed limit (100)
            (ok (fold mint-single-in-batch uris (list))) ;; Mint artworks for each URI in the batch
        )))

;; Helper function for batch minting: mints a single artwork within a batch operation.
(define-private (mint-single-in-batch (uri (string-ascii 256)) (previous-results (list 100 uint)))
    (match (create-single-artwork uri)
        success (unwrap-panic (as-max-len? (append previous-results success) u100))
        error previous-results))

;; Burns (deletes) an artwork certificate by its ID, making it non-transferable and non-viewable.
(define-public (burn-artwork (artwork-id uint))
    (let ((artwork-owner (unwrap! (nft-get-owner? digital-art artwork-id) err-artwork-not-found)))
        (asserts! (is-eq tx-sender artwork-owner) err-not-owner)  ;; Check if the sender is the owner of the artwork
        (asserts! (not (is-artwork-burned artwork-id)) err-already-burned)  ;; Ensure the artwork has not been burned already
        (try! (nft-burn? digital-art artwork-id artwork-owner))    ;; Burn the artwork NFT
        (map-set burned-artworks artwork-id true)                  ;; Mark the artwork as burned (revoked)
        (ok true)))                                                 ;; Return success

;; Transfers an artwork certificate from the sender to a recipient.
(define-public (transfer-artwork (artwork-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq recipient tx-sender) err-not-owner)     ;; Ensure the recipient is the tx-sender
        (asserts! (not (is-artwork-burned artwork-id)) err-already-burned)  ;; Check if the artwork has not been burned
        (let ((actual-sender (unwrap! (nft-get-owner? digital-art artwork-id) err-not-owner)))
            (asserts! (is-eq actual-sender sender) err-not-owner) ;; Verify actual ownership of the artwork
            (try! (nft-transfer? digital-art artwork-id sender recipient))  ;; Transfer the artwork NFT
            (ok true))))                                                 ;; Return success

;; Updates the URI of an artwork certificate.
(define-public (update-artwork-uri (artwork-id uint) (new-uri (string-ascii 256)))
    (begin
        (let ((artwork-owner (unwrap! (nft-get-owner? digital-art artwork-id) err-artwork-not-found)))
            (asserts! (is-eq artwork-owner tx-sender) err-not-owner)   ;; Check if sender owns the artwork
            (asserts! (is-valid-uri new-uri) err-invalid-uri)           ;; Validate the new URI
            (map-set artwork-uri artwork-id new-uri)                    ;; Update the artwork URI
            (ok true))))

;; Read-Only Functions

;; Retrieves the URI associated with a specific artwork ID, which contains the artwork's metadata.
(define-read-only (get-artwork-uri (artwork-id uint))
    (ok (map-get? artwork-uri artwork-id)))

;; Returns the owner of an artwork by its ID, if it exists.
(define-read-only (get-owner (artwork-id uint))
    (ok (nft-get-owner? digital-art artwork-id)))

;; Returns the ID of the last artwork created, helping to track the most recent artwork issued.
(define-read-only (get-last-artwork-id)
    (ok (var-get last-artwork-id)))

;; Checks if a specific artwork has been burned.
(define-read-only (is-burned (artwork-id uint))
    (ok (is-artwork-burned artwork-id)))
