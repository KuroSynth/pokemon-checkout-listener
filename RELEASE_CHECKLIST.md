# Release checklist

## Attach to a GitHub Release
- `windows/NTFY_Amazon_Checkout_PC.ps1`
- `mac/NTFY_Amazon_Checkout_MAC.command`

## Before publishing
1. Search the repo for your real ntfy topic.
2. Search for `token`, `password`, `cookie`, `API_HASH`, and `.env`.
3. Verify no Telegram `.session` files are tracked.
4. Test Windows with a harmless Amazon Mexico `/checkout/` URL.
5. Test macOS the same way.
6. Tag the release, e.g. `v1.0.0`.
7. State clearly that the scripts only open checkout and never confirm a purchase.
8. Optionally publish SHA-256 hashes for release assets.
