const VERSION = 'aktionen-v6';
const SHELL = ['./', 'index.html', 'manifest.webmanifest', 'icon-192.png', 'apple-touch-icon.png',
  'manrope-latin-400-normal.woff2', 'manrope-latin-600-normal.woff2', 'manrope-latin-800-normal.woff2'];
self.addEventListener('install', (e) => { e.waitUntil(caches.open(VERSION).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting())); });
self.addEventListener('activate', (e) => { e.waitUntil(caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== VERSION).map((k) => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET' || url.origin !== location.origin) return;
  const fresh = url.pathname.endsWith('.json') || e.request.mode === 'navigate';
  if (fresh) {
    e.respondWith(fetch(e.request).then((r) => { const c = r.clone(); caches.open(VERSION).then((x) => x.put(e.request, c)); return r; }).catch(() => caches.match(e.request)));
  } else {
    e.respondWith(caches.match(e.request).then((m) => m || fetch(e.request).then((r) => { const c = r.clone(); caches.open(VERSION).then((x) => x.put(e.request, c)); return r; })));
  }
});
