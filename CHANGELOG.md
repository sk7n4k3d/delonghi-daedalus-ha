# Changelog

Packaging mirror of `custom_components/delonghi_daedalus/` from
[`delonghi-ha`](https://github.com/sk7n4k3d/delonghi-ha). Full history lives
upstream; the Daedalus entries are reproduced here for HACS.

## [0.4.7] — 2026-11-18

### Fixed / Added
- **Le SUBACK est attendu et journalisé avant l'envoi des get** (#18,
  remarque mimasek71 sur 0.4.6) : la ligne « subscribed N topics » était
  écrite avant la lecture du SUBACK, et les get partaient avant sa
  validation — l'absence d'erreur de refus ne prouvait donc pas que les
  abonnements avaient été accordés. Désormais : attente du SUBACK (10 s),
  journalisation debug de chaque code raison (`0x00` accordé, `0x87` non
  autorisé…), erreur explicite « no SUBACK received — the broker accepted
  the session but never acknowledged the subscriptions » s'il n'arrive
  jamais, et les get ne partent qu'après accord.

## [0.4.6] — 2026-11-18

### Added
- **Le refus d'abonnement cloud devient lisible** (#18, retest mimasek71
  0.4.5) : la session MQTT vérifie désormais les codes de réponse du SUBACK.
  Si le broker refuse tous les abonnements aux topics shadow (politique de
  l'auteurizeur accrochée au vrai nom de machine — nom de thing dérivé
  incorrect, par exemple), l'erreur le dit explicitement
  « broker refused all N shadow topic subscriptions (reason 0x87) — thing
  name or authorizer policy mismatch) » au lieu de patienter 20 s puis
  accuser les shadows. Un refus partiel est journalisé en warning.
- Les logs debug nomment le thing utilisé (masqué) et les topics réellement
  abonnés — un retest avec `custom_components.delonghi_daedalus: debug`
  devient auto-suffisant pour diagnostiquer à distance.

## [0.4.5] — 2026-11-18

### Fixed
- **La connexion cloud MQTT-over-WebSocket offre enfin les sous-protocoles
  MQTT** (`Sec-WebSocket-Protocol: mqttv5, mqtt`) : AWS IoT (port 443)
  répond HTTP 426 à toute montée en WebSocket qui ne les propose pas, ce
  qui rendait tous les capteurs cloud indisponibles même avec la télémétrie
  activée (#18, diagnostics mimasek71 en 0.4.4). Un test de régression
  imite la porte ATS : une montée sans sous-protocole est refusée 426.

## [0.4.4] — 2026-11-18

### Fixed
- **Télémétrie cloud : les shadows partiels sont conservés** (#18, retest
  mimasek71) : un shadow nommé qui ne répond ni en accepted ni en rejected
  (ex. `MachineCapabilities` absent sur certaines machines) ne fait plus
  échouer le fetch entier — les shadows bien reçus sont désormais exploités.
- **`cloud_error` n'est plus jamais vide** : les timeouts et les exceptions
  sans message produisent un texte descriptif (type d'erreur, rc CONNACK)
  au lieu de la chaîne vide observée dans les exports de diagnostic.
- **Le budget de connexion borne tout le handshake** (DNS + TLS + upgrade
  MQTT5), plus seulement la lecture du CONNACK.
- **Appels SSL bloquants supprimés de l'event loop** : le contexte de
  confiance était construit à chaque connexion (scan du magasin de certs
  signalé par HA) ; il est désormais bâti une fois hors de la boucle et caché.

### Added
- **Section `cloud` complète dans les diagnostics** : erreur sanitizée
  (JWT, mots de passe et numéros de série ne fuiteront jamais), catégorie
  de tri (auth, mqtt_connect, shadow_rejected, no_shadow, parse,
  device_lookup, timeout), codes structurés (rc CONNACK, statut HTTP),
  horodatage exact de la tentative échouée, topics abonnés (nom de thing
  masqué) et état de connexion cloud. Un retest à distance est désormais
  diagnostiquable sans accès à la machine.

## [0.4.3] — 2026-11-18

### Added
- **Options après installation** : la télémétrie cloud se bascule désormais
  via Configuration → intégration → Options (recharge automatique de
  l'entrée). Auparavant il fallait supprimer et réinstaller l'intégration
  pour l'activer (#18, stivxgamer).

### Fixed
- **Le fetch cloud ne bloque plus le refresh LAN** : la lecture des shadows
  tourne en tâche de fond (une à la fois, anti-recouvrement) ; un broker
  injoignable ne retarde plus l'état LAN de 75 s à chaque cycle.
- Clé de traduction morte `invalid_host` retirée ; `strings.json` ajouté
  (parité hassfest avec `translations/en.json`).

## [0.4.2] — 2026-11-18

### Fixed
- **Connexion cloud Eletta Ultra (#18, mimasek71)** : l'annuaire REST
  `/devices` utilisait un stage mort (HTTP 403) sans le header
  `source: mycoffeelounge` — basculé sur le stage qui répond, header
  ajouté, l'ancien stage gardé en fallback ; parsing des réponses groupées
  `ownedByMe`/`sharedToMe`.
- **MQTT shadow** : le broker ferme les connexions MQTT 3.1.1 à la
  authorizer custom — la connexion « app-style » (MQTT 5, path
  `/mqtt?x-amz-customauthorizer-name=dlg-prod-token-authorizer`, username
  de l'authorizer, JWT en password, client-id `dlg-appliance-kit-android-*`)
  est tentée en premier, les deux spellings 3.1.1 restent fallback. Codec
  MQTT 5 complet (sections Properties au bon ordre, spec §3.3.2), budget de
  connexion borné à 30 s, timeouts REST qui jouent enfin le fallback de
  stage.

## [0.4.1] — 2026-11-14

### Changed
- **Alias exacts d'après le dump brut de mimasek71 (#18)** : les noms réels
  (`Status`, `CurrMode`, `Filter`, `Clean`, `NoCoffee`, `Waste`,
  `FWUIVersion`, `Granulometries`, `SoundEnable`, `EnergySavingMode`,
  `DrinkClusters`, `Grinder`, `Hopper`, `GFXVersion`, `DrainWater`…)
  remplacent les alias devinés, conservés en secours pour les autres
  modèles.
- Nouveaux champs mappés : description d'étape, firmware Wi-Fi, version
  agent cloud, modèle carte mère, profils utilisateur (nombre + icônes),
  températures café, extinction auto, `accessories.None`/`Water` et
  `peripherals.TankPresence` (alias en chemin complet pour lever
  l'ambiguïté avec `alarms.TankPresence`).

### Security
- Les clés `BlePassCode` (code d'appairage BLE), `MAC` et `SN` ne sont
  **jamais** exposées en entités — le repli brut les aurait persistées dans
  la base HA et les diagnostics exportés.

## [0.4.0] — 2026-11-14

### Added
- **Snapshot terrain Eletta Ultra intégré (mimasek71, #18)** :
  - `cloud_keys.py` : table de 77 champs cloud connus (état, alarmes,
    périphériques, accessoires, capacités) → noms lisibles traduits EN/FR.
    Les champs inconnus gardent le repli brut `Cloud <clé>`.
  - Les champs booléens mappés deviennent des `binary_sensor` (alarmes en
    `device_class=problem` : on = problème) au lieu de capteurs texte
    `true`/`false`.
  - Le shadow `MachineCapabilities` est désormais exposé (capteurs
    Diagnostic) — il était récupéré mais jeté depuis la 0.3.0.
  - Carte Lovelace compacte d'exemple : `docs/daedalus-cloud-card.yaml`
    (repo amont).
- **Télémétrie cloud opt-in** (`CONF_CLOUD_TELEMETRY`) : lecture des shadows
  AWS `MachineStatus` / `MachineCapabilities` via REST + MQTT, en plus du
  chemin LAN ; toute erreur cloud se dégrade en `cloud_error`, le LAN
  n'est jamais affecté.
