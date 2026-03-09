# ISTRUZIONI POST-RIAVVIO
## Compilazione Dinastycoin GUI in Docker

### ⚠️ IMPORTANTE
Questo documento contiene le istruzioni da seguire **DOPO** il riavvio del sistema.

---

## 📋 Situazione Attuale

**Problema identificato (6 Mar 2026 22:10):**
- ✅ Daemon `dinastycoind` funziona correttamente
- ❌ GUI `dinastycoin-wallet-gui` crasha con segfault (processi zombie)
- **Causa Root**: Dockerfile manca pacchetti XCB utility essenziali
  - `libxcb-icccm.so.4, libxcb-image.so.0, libxcb-shm.so.0` => not found
  - `libxcb-keysyms.so.1, libxcb-render-util.so.0` => not found

**Soluzione applicata:**
- ✅ Fix aggiunto a `Dockerfile.linux`: pacchetti XCB necessari
- ⏳ Richiede rebuild Docker image + ricompilazione progetto
- Compilazione in ambiente Docker isolato (Ubuntu 18.04 + Qt 5.15.17)
- Garantisce compatibilità binaria cross-distro

### 🎯 Principio di portabilità (vincolante)

- **Target binario:** ambiente Linux baseline compatibile con **Ubuntu 18.04** (toolchain/librerie Docker).
- **Manjaro host:** usato solo per compilazione/esecuzione Docker, **non** è il riferimento ABI dei binari finali.
- I binari devono rimanere il più possibile in linea con il flusso Monero (build deterministica/reproducibile),
  evitando workaround locali specifici della macchina host.

---

## 🚀 PASSO 1: Verifica Docker

Dopo il riavvio, apri un terminale e verifica Docker:

```bash
docker --version
docker info
```

**Se Docker non è installato:**

```bash
sudo pacman -S docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

Poi **riavvia nuovamente** per applicare i permessi gruppo.

---

## 🏗️ PASSO 2: Build Docker con Fix XCB

⚠️ **AGGIORNAMENTO 6 Mar 2026 22:10**: Usa lo script con fix dipendenze XCB!

Naviga nella directory progetto:

```bash
cd /home/user/Programmi/wcripto/source_01/dinastycoin-zef/dinastycoin-gui-zef
```

Esegui lo script di compilazione con fix:

```bash
./ricompila-docker-fix.sh
```

**Cosa fa questo script:**
1. Rebuilda l'immagine Docker con pacchetti XCB essenziali aggiunti:
   - `libxcb-icccm-dev`, `libxcb-image-dev`, `libxcb-keysyms-dev`
   - `libxcb-render-util-dev`, `libxcb-xinerama-dev`
2. Ricompila il progetto con le dipendenze corrette
3. Copia i binari in `build/release-docker/`

**Tempi stimati:**
- Rebuild Docker image: **~1 ora** (include ricompilazione Qt + XCB libs)
- Compilazione progetto: **35-45 minuti**
- **Totale: ~1.5-2 ore**

**CPU:** Userà tutti i 4 core AMD A10-7400P

**Alternative (se hai già compilato prima):**
- Se hai già un'immagine Docker vecchia, `ricompila-docker-fix.sh` la rebuilderà con `--no-cache`
- Per build successive (dopo il fix), usa: `./compila-docker.sh` (più veloce)

---

## 📦 PASSO 3: Test Binari

Dopo la compilazione, i binari saranno in:

```
build/release-docker/dinastia coind
build/release-docker/dinastycoin-wallet-gui
build/release-docker/dinastycoin-wallet-cli
... (altri tool)
```

**Test daemon:**

```bash
./build/release-docker/dinastycoind --version
./build/release-docker/dinastycoind --data-dir /tmp/test_docker --detach
```

**Test GUI:**

```bash
./build/release-docker/dinastycoin-wallet-gui
```

---

## 🧩 PASSO 4: Runtime bundle ad alta compatibilità (consigliato)

Per distribuire su un parco Linux ampio, estrai anche le librerie/runtime dal container (stessa baseline Ubuntu 18.04):

```bash
./estrai-runtime-compat.sh
```

Questo popola in `build/release-docker/`:

- `lib/` → librerie progetto (es. `libsodium`)
- `lib-compat/` → librerie X11/XCB/XKB/GLib/udev compatibili con il build target
- `qt-runtime/qml` e `qt-runtime/plugins` → moduli QML + plugin Qt
- `share/ssl/certs/ca-certificates.crt` → CA bundle per HTTPS/updater/nodi remoti TLS

### Struttura minima consigliata del pacchetto finale

- `dinastycoin-wallet-gui`
- `dinastycoind` (+ altri binari opzionali)
- `run-gui.sh`, `run-daemon.sh`
- `lib/`
- `lib-compat/`
- `qt-runtime/`
- `share/ssl/certs/ca-certificates.crt`

### Note pratiche di compatibilità

- Non considerare Manjaro host come riferimento ABI.
- Basare sempre il bundle su librerie estratte dal Docker Ubuntu 18.04.
- Evitare modifiche funzionali al codice solo per adattarsi al sistema host.
- Per compatibilità massima stile Monero, preferire release pulite e ripetibili da Docker.

---

##  File Disponibili

Script creati prima del riavvio:

- `pulisci-tutto.sh` - Pulizia completa progetto (già eseguito)
- `compila-docker.sh` - Compilazione Docker automatica ⭐
- `test-daemon-pulito.sh` - Test daemon con data-dir isolata
- `RIAVVIO-ISTRUZIONI.md` - Questo file

---

## ❓ Troubleshooting

### Docker non parte dopo riavvio

```bash
sudo systemctl status docker
sudo systemctl start docker
```

### Permission denied su Docker socket

```bash
sudo usermod -aG docker $USER
# Poi logout/login o riavvia
```

### Build Docker troppo lenta

Aumenta risorse Docker (se usi Docker Desktop):
- CPU: 4 core
- RAM: 4-6 GB
- Swap: 2 GB

### Build fallisce nel container

Controlla logs:
```bash
less docker-build.log
less docker-compile.log
```

---

## 📞 Riferimenti

- Dockerfile usato: `Dockerfile.linux`
- Base image: Ubuntu 18.04
- Qt version: 5.15.17-lts-lgpl
- Boost: 1.80.0
- OpenSSL: 1.1.1u

---

**Creato il:** 5 marzo 2026, 19:50  
**Sistema:** Manjaro Linux 26.0.3 (Anh-Linh)  
**CPU:** AMD A10-7400P (4 core)
