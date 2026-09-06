const CACHE_NAME = 'kleivy-v1';
const urlsToCache = [
  '/Kleivy/',
  '/Kleivy/index.html',
  '/Kleivy/login.html',
  '/Kleivy/register.html',
  '/Kleivy/style.css',
  '/Kleivy/script.js'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache)));
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(response => response || fetch(e.request))
  );
});
