# Security Policy

## Secrets and sensitive configuration

Do not commit real ntfy topic names, ntfy credentials/tokens, `.env` files, Amazon cookies/session data, Telegram session files, passwords, or API credentials.

## Why topic names matter

On the public `ntfy.sh` service, an unprotected topic can be read from and written to by anyone who knows its name. Treat an unprotected topic name as a shared secret.

A leaked topic can let a third party subscribe to the feed or publish fake messages to it. These clients only auto-open Amazon Mexico checkout URLs and do not confirm purchases, but a leaked topic can still cause false alerts, unwanted browser openings, and exposure of feed contents.

## Recommended deployment models

For a public GitHub project, keep topic names out of source control.

For a small trusted group, either:
- use one long, random shared topic and rotate it if it leaks or group membership changes; or
- use one topic per user for easier revocation and isolation.

For stronger security, use ntfy authentication/access control rather than relying only on topic-name secrecy.

## Reporting a security issue

Do not open a public issue containing credentials, private topics, session cookies, or other secrets. Contact the repository owner privately.
