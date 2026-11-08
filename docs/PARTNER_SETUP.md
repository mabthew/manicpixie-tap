# Hosting tap.manicpixiethrift.com (for the owner of the manicpixiethrift.com Netlify account)

The keychain fobs and QR codes point phones at **https://tap.manicpixiethrift.com/**. That little site
(an Apple association file, a landing page and a JSON file the app reads) has to live in the same
Netlify team that manages manicpixiethrift.com, because Netlify only lets that team use the domain.
Setup is about five minutes, once.

## Route 1 (preferred): deploy from GitHub

1. Make sure your GitHub user has access to the repo `mabthew/manicpixie-tap` (it is public; ask Matt
   to add you as a collaborator so Netlify lists it).
2. In Netlify: **Add new project → Import an existing project → GitHub** → pick `mabthew/manicpixie-tap`.
3. Settings on the import screen:
   * Base directory: `web`
   * Build command: leave empty
   * Publish directory: `web/public`
4. Deploy. You get a `something.netlify.app` URL; check that
   `https://<that>.netlify.app/.well-known/apple-app-site-association` shows JSON.
5. **Domain management → Add a domain → `tap.manicpixiethrift.com`**. Because the domain's DNS is in
   your Netlify DNS, Netlify adds the record for you and issues the HTTPS certificate within minutes.
6. Done. From now on every `git push` by Matt updates the site automatically; you never touch it again.

## Route 2 (if you do not use GitHub): proxy from your existing site

Keep Matt's own Netlify site as the source and have your site serve it under the subdomain:

1. **Domain management** of your existing manicpixiethrift.com site → **Add domain alias** →
   `tap.manicpixiethrift.com` (Netlify adds the DNS record and certificate).
2. Add this line to your site's `_redirects` file (or the equivalent rule in `netlify.toml`) and redeploy:

       https://tap.manicpixiethrift.com/*  https://manicpixie-tap.netlify.app/:splat  200

   The `200` makes it a proxy, not a redirect, which Apple requires.

## Check

Open https://tap.manicpixiethrift.com/ on a phone. You should see the Manic Pixie Thrift page, and
https://tap.manicpixiethrift.com/.well-known/apple-app-site-association should show a short JSON file.
