# claude-code-session-bridge

**Make a Claude Code chat you started in VS Code show up in the Claude Code desktop app — so you can carry one conversation back and forth between both apps.**

> Windows · one PowerShell script · no install · never edits your chats · MIT licensed

---

## 📖 Read this first: the one idea behind everything

Imagine every Claude Code chat is a **notebook**, and there's a **library index card** that points to it.

```
THE NOTEBOOK = your actual chat (every message you and Claude wrote)
THE INDEX CARD = a tiny note that says "a notebook exists, here's its name and where it is"
```

- The **VS Code extension** finds notebooks **by looking on the shelf** (the folder on your disk).
- The **desktop app** is lazier — it **only reads index cards**. No card = it can't see the notebook, *even though the notebook is right there.*

When you start a chat in the **desktop app**, it writes the index card for you. ✅
When you start a chat in **VS Code**, **no card gets written.** ❌ → the desktop app is blind to it.

**This tool writes the missing index card.** That's the whole thing. One card per chat.

```
   YOUR VS-CODE CHAT
   notebook  ✔  (your messages — already on disk, we never touch it)
   index card ✘  MISSING        ──run this tool──►   index card ✔   ──►  desktop app sees it
```

---

## ❓ The WH questions (answered plainly)

### WHO is this for?
Anyone who uses **Claude Code in more than one place** — the **VS Code extension** and the **desktop app** — and is annoyed that chats started in VS Code never appear in the desktop app's sidebar.

### WHAT does it actually do?
It creates a small "index card" file (Claude Code calls it a *session wrapper*) for chats that don't have one. With the card in place, the desktop app lists the chat and can open it. **It adds tiny pointer files. Nothing else.**

### WHY is this even needed? (the root cause)
Both apps and the terminal CLI **share the exact same chat file** on disk. But the desktop app builds its sidebar **only** from index cards, and **only the desktop app writes those cards** — VS Code never does. So VS-Code-born chats are invisible to the desktop app until someone writes the card. This tool writes it.

### WHEN do you run it?
Whenever you started a chat in VS Code and now want it in the desktop app too. Run it as often as you like — **it skips chats that already have a card**, so re-running is always safe.

### WHERE does it put things? (exact folders)
```
THE NOTEBOOK (your chat — we only READ it, never change it):
   C:\Users\<you>\.claude\projects\<folder-as-dashes>\<session-id>.jsonl

THE INDEX CARD (what this tool WRITES):
   C:\Users\<you>\AppData\Roaming\Claude\claude-code-sessions\<guid>\<guid>\local_<session-id>.json
```

### HOW does it work, step by step?
For each VS-Code-born chat in a folder, the tool:
```
1. Opens the chat file and reads ONLY its first ~50 lines   (a read-only peek)
2. Figures out two things:
      • which folder the chat belongs to
      • a friendly title (the chat's first message), with the date in front
        e.g.  "[Jun 13] hey help me find the claude's sesins..."
3. Writes a tiny index card whose pointer ("cliSessionId") aims at that chat file
4. Drops the card next to the desktop app's other cards
```
That's it. It **reads** your chats (peek only) and **writes** new little card files.

---

## 🔒 Is it safe? (yes — here's exactly why)

```
✘ It NEVER edits, moves, or deletes your actual chat files (.jsonl)
✘ It NEVER overwrites a card that already exists (it skips those)
✘ It NEVER deletes anything — it only ADDS card files
✔ It is DRY-RUN by default — it writes NOTHING unless you add  -Apply
✔ It is trivially reversible — delete the card file it made, and the listing is gone
   (your chat stays perfectly safe, because the card was never the chat)
```

---

## 🚀 How to use it (copy-paste recipes)

You need **Windows** and **PowerShell**. Open a terminal: in VS Code, click **Terminal → New Terminal**.

> 💡 **Golden habit:** run a recipe **without** `-Apply` first to *preview* (it writes nothing), then add `-Apply` to actually do it.

Let `SCRIPT` = the full path to `register_vscode_session_in_desktop.ps1` on your machine.

### Recipe A — add new chats from ONE folder (the usual case)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "SCRIPT" -ProjectPath "C:\path\to\the\folder\you\opened\in\vscode" -Apply
```

### Recipe B — just preview, write nothing
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "SCRIPT" -ProjectPath "C:\path\to\folder"
```

### Recipe C — one specific chat only
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "SCRIPT" -SessionId <session-id> -Apply
```

### Recipe D — every chat in every project on the PC
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "SCRIPT" -AllProjects -Apply
```

### ⚠️ The step everyone forgets
**After running with `-Apply`, fully QUIT and RE-OPEN the desktop app.**
The sidebar reads index cards **only when it starts up** — new cards won't appear until you restart.

### Reading the output
```
WROTE  41c938f1   [Jun 19] read the project_log...    ← a new card was written
WOULD  9f089261   [Jun 13] hey help me find...        ← preview only (you left off -Apply)
Result: 1 new sticky-note(s), 4 already registered (skipped).
                  └ added this run       └ already had cards, left untouched
```

### All the options
| Flag | Meaning |
|------|---------|
| *(none)* | Dry run — lists what it *would* do, writes nothing. |
| `-Apply` | Actually write the card file(s). |
| `-ProjectPath "<path>"` | The folder you opened in VS Code (default: current folder). |
| `-SessionId <id>` | Do just one chat, by its id. |
| `-AllProjects` | Every project folder under `~/.claude/projects`, not just one. |

---

## 🔁 The payoff: carry ONE chat between both apps ("ping-pong")

Here's the part that surprises people: **there is nothing to "sync."** Your messages already live in **one shared notebook**. No copying, no uploading. The only trick is **each app re-reads the notebook when you OPEN the chat** — so "syncing" just means *open the chat in the other app.*

```
   DESKTOP  ──you type, Claude replies──►  the shared notebook grows
      │
      │   ① STOP (let the reply finish)
      ▼
   VS CODE  ──open the SAME folder → /resume → pick the chat──►
            it re-reads the notebook → your desktop messages are right there
      │
      │   ② type, Claude replies → notebook grows again, then STOP
      ▼
   DESKTOP  ──re-open the chat from the sidebar──►
            re-reads → your VS Code messages appear
```

```
🔴 THE ONE GOLDEN RULE
   Only ONE app "live" on a chat at a time.
   Finish your turn → STOP → switch → open/resume → continue.
   Never type in both at the same second (both would scribble in the same
   notebook at once and could smear a line).
   When you return to an app, OPEN THE CHAT FRESH so it re-reads from disk —
   don't trust a tab you left sitting open; it may still show the old page.
```

---

## 🗑️ How to undo (remove a chat from the desktop sidebar)

```
1. Go to:  C:\Users\<you>\AppData\Roaming\Claude\claude-code-sessions\<guid>\<guid>\
2. Find:   local_<that-session-id>.json
3. Delete it.
4. Restart the desktop app → the chat is gone from the sidebar.
```
⚠️ This deletes only the **index card**. Your actual chat (the notebook `.jsonl`) is **never touched** and stays safe.

---

## 🧭 Bonus: how a chat's folder becomes its "drawer" name on disk

Claude Code files each chat under a folder name made from the chat's working directory, where **every character that isn't a letter or number becomes a dash `-`**:

```
C:\Users\Me\Music\my project
        │   (every space / symbol → dash)
        ▼
c--Users-Me-Music-my-project        ← the "drawer" inside  ~/.claude/projects\
```

That's why the **exact** folder matters: a parent folder, a subfolder, or a renamed folder becomes a *different* drawer — and therefore a different list of chats.

---

## ⚠️ Honest limitations (no surprises)

- **Windows only** (it uses Windows paths + PowerShell). Pull requests for macOS/Linux desktop paths are very welcome.
- **The title is a best guess** from the chat's first message — rename it inside the app if you like.
- The card stamps **default settings** (model, effort, no MCP tools). When you open the chat, the **notebook is the source of truth**; the card's settings are just defaults for the listing.
- Tested against the Claude Code desktop app's card format as of **mid-2026**. If the desktop app changes that format later, the script may need a small update.
- **Community tool, not affiliated with Anthropic.**

---

## 📜 License

**MIT** — see [LICENSE](LICENSE). Use it, fork it, share it, ship it.
