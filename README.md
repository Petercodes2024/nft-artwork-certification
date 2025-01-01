# Decentralized Digital Art Certification Smart Contract

This smart contract allows artists and creators to mint, manage, and transfer unique digital artwork certificates (NFTs) on the Clarinet blockchain. Each certificate represents a verified piece of digital artwork, linked to metadata and stored immutably on the blockchain. The contract supports minting individual and batch artwork certificates, transferring ownership, updating artwork metadata, and burning (revoking) artwork certifications.

## Features

- **Minting of Artworks**: Mint unique artwork NFTs with associated metadata (URI).
- **Batch Minting**: Mint up to 100 artworks in a single transaction.
- **Transfer Ownership**: Securely transfer artwork ownership between users.
- **Update Metadata**: Update the metadata (URI) associated with an artwork.
- **Burn (Revoke) Artworks**: Burn an artwork to remove it from circulation.
- **Validate Artworks**: Ensure artworks are owned by the correct user, not burned, and have valid metadata.

## Error Codes

The contract defines the following error codes to standardize error handling:

- **u100**: Caller is not the owner of the contract.
- **u101**: Artwork ownership verification failed.
- **u102**: Artwork already exists.
- **u103**: Artwork not found.
- **u104**: Invalid URI format.
- **u105**: Artwork has already been burned.
- **u108**: Batch size exceeds the maximum limit (100).

## Data Variables

- **digital-art (NFT)**: Represents the unique non-fungible token for each artwork.
- **last-artwork-id**: Tracks the most recent artwork ID minted.
- **artwork-uri (Map)**: Maps artwork IDs to their associated metadata (URI).
- **burned-artworks (Map)**: Tracks whether an artwork has been burned or revoked.

## Public Functions

### `mint-artwork(uri)`
Mints a new artwork certificate with the specified URI.

- **uri**: The URI that points to the metadata of the artwork.
- **Returns**: The ID of the newly minted artwork.

### `batch-mint-artworks(uris)`
Mints multiple artwork certificates in a single transaction (up to 100 artworks).

- **uris**: A list of URIs to be minted as artworks.
- **Returns**: The IDs of the newly minted artworks.

### `burn-artwork(artwork-id)`
Burns an artwork, rendering it non-transferable and non-viewable.

- **artwork-id**: The ID of the artwork to be burned.
- **Returns**: `true` if successful.

### `transfer-artwork(artwork-id, sender, recipient)`
Transfers ownership of an artwork from the sender to the recipient.

- **artwork-id**: The ID of the artwork.
- **sender**: The current owner of the artwork.
- **recipient**: The new owner of the artwork.
- **Returns**: `true` if the transfer is successful.

### `update-artwork-uri(artwork-id, new-uri)`
Updates the URI (metadata) of an artwork.

- **artwork-id**: The ID of the artwork.
- **new-uri**: The new URI to associate with the artwork.
- **Returns**: `true` if the update is successful.

## Read-Only Functions

### `get-artwork-uri(artwork-id)`
Retrieves the URI associated with a specific artwork.

- **artwork-id**: The ID of the artwork.
- **Returns**: The URI of the artwork.

### `get-owner(artwork-id)`
Returns the owner of a specific artwork.

- **artwork-id**: The ID of the artwork.
- **Returns**: The owner of the artwork.

### `get-last-artwork-id()`
Returns the ID of the last minted artwork.

- **Returns**: The ID of the most recently minted artwork.

### `is-burned(artwork-id)`
Checks if a specific artwork has been burned.

- **artwork-id**: The ID of the artwork.
- **Returns**: `true` if the artwork is burned, otherwise `false`.

## Usage

This contract can be deployed on the Clarinet blockchain and used to manage digital artwork certificates. Users can mint individual artworks or batch mint them, update metadata, and transfer ownership securely.

### Example Minting

```clarinet
(mint-artwork "https://example.com/artwork1.json")
```

### Example Batch Minting

```clarinet
(batch-mint-artworks ["https://example.com/artwork1.json", "https://example.com/artwork2.json"])
```

### Example Transferring

```clarinet
(transfer-artwork 1 sender-principal recipient-principal)
```

### Example Burning

```clarinet
(burn-artwork 1)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
