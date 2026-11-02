// Kopiert die Web-App aus dem Repo-Stamm nach www/ (ohne Service Worker und Daten).
import { mkdirSync, copyFileSync, readdirSync, rmSync } from 'node:fs';
const root = new URL('../', import.meta.url), www = new URL('./www/', import.meta.url);
rmSync(www, { recursive: true, force: true }); mkdirSync(www);
for (const f of readdirSync(root)) if (/\.(html|png|svg|woff2|webmanifest|json|js)$/.test(f) && f !== 'package.json' && f !== 'sw.js') copyFileSync(new URL(f, root), new URL(f, www));
console.log('www/ aktualisiert');
