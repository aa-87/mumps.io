# Arabic learning coming-soon page

This is an optional MIOTPL-powered landing page module. The working creative direction is intentionally unbranded: the Arabic word **صَوْت** (sawt, “voice/sound”) is used as a visual motif, not a finalized business name.

## Files

- `templates/layouts/sout_layout.html` — document shell and metadata.
- `templates/pages/sout_home.html` — Mustache page content.
- `public/sout/sout.css` — responsive editorial styling.
- `routines/SOUT.m` — page and signup handlers.

The page uses MIOTPL variables, sections, inverted sections, and layout/page rendering.

## Register the routes

The module does not alter the framework's default routes or take over `/`. Register it from the application bootstrap after route initialization and before route compilation:

```mumps
D INIT^MIOROUTE
D START^MIOTPL(.CONF)
D REG^SOUT(.CONF)
D COMPILE^MIOROUTE
```

If your application already initializes MIOROUTE and MIOTPL, add only `D REG^SOUT(.CONF)` before its existing `COMPILE^MIOROUTE` call. The landing page is available at `GET /sout`.

Ensure the server's static-file handler serves `/public/*` from the repository's `public` directory. The stylesheet URL is `/public/sout/sout.css`.

## Early-access form

The form posts URL-encoded fields to `POST /sout/waitlist`. It uses `DECODEFORM^MIOFNC` and stores normalized, unique email addresses in:

- `^MIO("SOUT","WAITLIST","email",email)=id`
- `^MIO("SOUT","WAITLIST","entry",id,"email")`
- `^MIO("SOUT","WAITLIST","entry",id,"interest")`
- `^MIO("SOUT","WAITLIST","entry",id,"createdH")`

Repeated submissions update the interest selection on the existing record. A hidden honeypot field discards obvious bot submissions. Successful submissions redirect to `/sout?joined=1#early-access`.

Before collecting real customer information in production:

1. Serve the page only over HTTPS.
2. Enable and tune server-side per-IP rate limiting at the edge/server.
3. Restrict access to the waitlist global and define retention/export/deletion procedures.
4. Add an appropriate privacy notice and an email-confirmation workflow if the list will be used for marketing.
5. Test the POST route against your deployed request parser and reverse proxy limits.

The handler performs basic email syntax checks; it does not verify mailbox ownership or send email. The form records early-access interest, not a confirmed subscription.

## Content and pronunciation notes

English-friendly spellings are introductory approximations, not a claim that Arabic can be fully represented with English spelling. In particular, `ح` in `حبيبي` is a distinct Arabic consonant; learners should hear and practice it. Pronunciation can vary across dialects and contexts.
