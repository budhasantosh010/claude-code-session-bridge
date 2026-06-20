# claude-code-session-bridge

**Make a Claude Code chat you started in VS Code show up in the Claude Code desktop app — so you can carry one conversation back and forth between both apps.**

> Windows · one PowerShell script · no install · never edits your chats · MIT licensed

---

## ⚡ In a hurry? The 3-step version

> *Full explanations are below — but if you just want it done, this is the whole thing.*

```
STEP 1   Download the script (green "Code" button → Download ZIP → Extract).
STEP 2   In VS Code: Terminal → New Terminal. Paste ONE line, swap in your folder, press Enter:

   powershell -NoProfile -ExecutionPolicy Bypass -File "‹PATH TO THE .ps1›" -ProjectPath "‹YOUR VS CODE PROJECT FOLDER›" -Apply

STEP 3   Fully quit the desktop app (tray icon → Quit) and reopen it.

Done — your VS Code chats from that folder now appear in the desktop app's sidebar.
```
👉 Confused by `‹PATH TO THE .ps1›` vs `‹YOUR PROJECT FOLDER›`? Read **[the 3-folders section](#folders)** — it's the #1 thing people trip on.

---

## 🗺️ Table of contents

**Understand it (5-min read):**
- [📖 The one idea behind everything](#idea) — notebook + index card
- [❓ The WH questions](#wh) — who / what / why / when / where / how
- [🔒 Is it safe?](#safe) — yes, and exactly why

**Do it (copy-paste):**
- [📥 Install — get the script onto your PC](#install)
- [🧩 IMPORTANT: don't mix up these 3 folders](#folders) — **read this first**
- [🚀 How to use it — copy-paste recipes](#recipes)
  - [✅ Recipe A — add all new chats from one project](#recipe-a) *(the everyday one)*
  - [👀 Recipe B — preview only, change nothing](#recipe-b)
  - [🎯 Recipe C — add one specific chat](#recipe-c)
  - [🌍 Recipe D — every project on the PC](#recipe-d)
- [⚠️ The step everyone forgets](#restart) — restart the desktop app
- [🆘 Red error? The two common fixes](#errors)

**Use it:**
- [🔁 Carry one chat between both apps (ping-pong)](#pingpong)
- [🗑️ How to undo](#undo)
- [🧭 Bonus: the folder → "drawer" naming](#drawer)
- [⚠️ Honest limitations](#limits) · [📜 License](#license)

---

<a id="idea"></a>
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

<a id="wh"></a>
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

<a id="safe"></a>
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

<a id="install"></a>
## 📥 Install — get the script onto your computer

You need just **ONE file**: `register_vscode_session_in_desktop.ps1`. There is **nothing to compile or install** — you save this one file and run it. Pick either way to get it.

### Way 1 — Download the ZIP (easiest, no tools needed)
```
1. Open   https://github.com/budhasantosh010/claude-code-session-bridge
2. Click the green  "< > Code"  button  →  "Download ZIP"
3. Find   claude-code-session-bridge-main.zip   in your Downloads folder
4. Right-click it  →  "Extract All…"  →  choose a PERMANENT home, e.g.  C:\Users\<you>\Tools
5. You now have the script here:
   C:\Users\<you>\Tools\claude-code-session-bridge-main\register_vscode_session_in_desktop.ps1
```

### Way 2 — git clone (if you already have Git)
```powershell
cd C:\Users\<you>\Tools
git clone https://github.com/budhasantosh010/claude-code-session-bridge.git
```
Result:
```
C:\Users\<you>\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1
```

> 📌 Keep it somewhere permanent you'll remember (a `Tools\` folder is perfect). **Don't leave it in Downloads** — too easy to delete by accident.

### Copy the script's full path (you'll paste this into every command)
```
1. In File Explorer, find   register_vscode_session_in_desktop.ps1
2. Hold SHIFT, right-click it  →  "Copy as path"
3. The full path is now on your clipboard, e.g.:
   "C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1"
```

---

<a id="folders"></a>
## 🧩 IMPORTANT — don't mix up these 3 folders (read this or you'll get confused)

Almost everyone trips on this at first — including the person who *built* this tool. There are **three completely different folders** in play, and they are NOT the same thing:

```
①  THE SCRIPT (the tool)        ←  a .ps1 file. Just a helper program. Lives ANYWHERE.
       C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1

②  YOUR PROJECT FOLDER          ←  where YOUR code/work lives. The folder you open in VS Code.
       C:\Users\Alex\Documents\my-website

③  CLAUDE'S SESSIONS FOLDER     ←  Claude's OWN private storage. You NEVER point at this.
       C:\Users\Alex\.claude\projects\...
```

### "Which folder do I put in the command?"
👉 **Folder ② — your project folder** (the one you open in VS Code).
🚫 **NOT folder ③** (`.claude\projects\...`).

Why? The `-ProjectPath` part is asking **"which project's chats do you want?"** — and you name a project by **where its code lives** (its human name, like `...\my-website`). The script then quietly translates that into folder ③ for you. **You never type folder ③ yourself.**

```
YOU type:        -ProjectPath "C:\Users\Alex\Documents\my-website"        ← folder ② (your code)
SCRIPT figures:  → look inside C:\Users\Alex\.claude\projects\c--Users-...-my-website\   ← folder ③
                   (it does this itself — not your job)
```

### "Why is the .ps1 saved in some random folder? Shouldn't it live inside `.claude`?"
**No.** Here's the key idea:

> The `.ps1` file is **NOT part of Claude.** It's a small helper program. It has nothing to do with Claude's internal machinery, so it does **not** belong in `.claude`.

```
.claude\  =  Claude's house. Claude's own stuff (sessions, settings, memory).
              ── you don't store your own tools inside someone else's house ──

the .ps1  =  YOUR screwdriver. A tool. It can sit in ANY drawer you like —
              Desktop, a Tools\ folder, anywhere. It works exactly the same.
```

The script's **location doesn't matter at all.** What matters is that your command **points at it** with the `-File "..."` part:

```
-File "C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1"
       └─────────── "hey PowerShell, run THIS tool — it's right here" ───────────┘
```

Move the `.ps1` to `C:\Tools\`? Then just change that to `-File "C:\Tools\register_vscode_session_in_desktop.ps1"` and it still runs fine.

### One-line summary
```
RUN this tool ①  ──  to bookmark the chats of this project ②  ──  into the desktop app.
   (-File "...ps1")        (-ProjectPath "...your code folder")

Folder ③ (.claude) = Claude's private storage. The tool reads it FOR you. You never name it.
```

---

<a id="recipes"></a>
## 🚀 How to use it (copy-paste recipes)

### The 2 things every command needs
```
① SCRIPT PATH   = where you saved register_vscode_session_in_desktop.ps1   (copied just above)
② PROJECT PATH  = the folder you open in VS Code for that chat
```
**To copy the PROJECT PATH:** in VS Code, right-click the top folder in the Explorer sidebar → **"Copy Path"**.
(Or in File Explorer, Shift+right-click the folder → **"Copy as path"**.)

### How to actually run a command
```
1. Open PowerShell:  in VS Code click  Terminal → New Terminal
                     (or press the Windows key, type "PowerShell", press Enter)
2. Paste a recipe below — with YOUR two paths filled in
3. Press Enter
```
> 💡 **Golden habit:** run it **without** `-Apply` first — that's a *preview* and writes nothing. Happy with what it lists? Add `-Apply` and run again to actually write the cards.

---

**👇 Every recipe below uses this ONE concrete example. Just swap in your own two paths.**
```
Example SCRIPT PATH :  C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1
Example PROJECT PATH:  C:\Users\Alex\Documents\my-website
```

<a id="recipe-a"></a>
### ✅ Recipe A — add all new chats from ONE project (the everyday one)
> *Plain English: "Look at my-website's chats and add a card for any that doesn't have one yet."*
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1" -ProjectPath "C:\Users\Alex\Documents\my-website" -Apply
```

<a id="recipe-b"></a>
### 👀 Recipe B — preview only, change nothing (just drop `-Apply`)
> *Plain English: "Show me what you WOULD add, but don't touch anything yet."*
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1" -ProjectPath "C:\Users\Alex\Documents\my-website"
```

<a id="recipe-c"></a>
### 🎯 Recipe C — add ONE specific chat (by its id)
> *Plain English: "I only want this single chat in the desktop app, not all of them."*

**Step 1 — find the chat's id:**
```
1. Open File Explorer and go to:   C:\Users\<you>\.claude\projects\
2. Open the "drawer" for your project. Its name is your PROJECT PATH with every
   space and symbol turned into a dash. So:
      C:\Users\Alex\Documents\my-website   →   c--Users-Alex-Documents-my-website
3. Inside, each chat is a file named  <session-id>.jsonl . The filename IS the id:
      41c938f1-e81e-4d13-ad39-bde9636a51c0.jsonl
       └──────────────── this is the id ───────────────┘
```
**Step 2 — run it (paste the id after `-SessionId`):**
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1" -SessionId 41c938f1-e81e-4d13-ad39-bde9636a51c0 -Apply
```

<a id="recipe-d"></a>
### 🌍 Recipe D — add chats from EVERY project on the PC
> *Plain English: "Sweep all my projects at once." Note: no `-ProjectPath` here — `-AllProjects` takes its place.*
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Alex\Tools\claude-code-session-bridge\register_vscode_session_in_desktop.ps1" -AllProjects -Apply
```

### ✍️ Build your OWN command (fill in the 2 blanks)
```
powershell -NoProfile -ExecutionPolicy Bypass -File "‹SCRIPT PATH›" -ProjectPath "‹PROJECT PATH›" -Apply
                                                      └─ paste path ①      └─ paste path ②
```

<a id="restart"></a>
### ⚠️ The step everyone forgets
**After running with `-Apply`, fully QUIT and RE-OPEN the desktop app.**
The sidebar reads index cards **only when it starts up** — new cards won't appear until you restart.
(Quit properly: right-click the Claude icon in the Windows tray, bottom-right near the clock → **Quit**. Just closing the window may not be enough.)

<a id="errors"></a>
### 🆘 "It threw a red error" — the two common ones
```
"... cannot be loaded because running scripts is disabled ..."
   → You forgot the  -ExecutionPolicy Bypass  part. Copy the WHOLE recipe line; it's already in there.

"No cabinet drawer for: C:\...\your-folder"
   → That PROJECT PATH has no Claude Code chats yet, OR the path is slightly wrong.
     Fix: make sure you copied the EXACT folder you open in VS Code (Explorer → right-click top
     folder → "Copy Path"). Run Recipe B (preview) first to check before using -Apply.
```

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

<a id="pingpong"></a>
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

<a id="undo"></a>
## 🗑️ How to undo (remove a chat from the desktop sidebar)

```
1. Go to:  C:\Users\<you>\AppData\Roaming\Claude\claude-code-sessions\<guid>\<guid>\
2. Find:   local_<that-session-id>.json
3. Delete it.
4. Restart the desktop app → the chat is gone from the sidebar.
```
⚠️ This deletes only the **index card**. Your actual chat (the notebook `.jsonl`) is **never touched** and stays safe.

---

<a id="drawer"></a>
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

<a id="limits"></a>
## ⚠️ Honest limitations (no surprises)

- **Windows only** (it uses Windows paths + PowerShell). Pull requests for macOS/Linux desktop paths are very welcome.
- **The title is a best guess** from the chat's first message — rename it inside the app if you like.
- The card stamps **default settings** (model, effort, no MCP tools). When you open the chat, the **notebook is the source of truth**; the card's settings are just defaults for the listing.
- Tested against the Claude Code desktop app's card format as of **mid-2026**. If the desktop app changes that format later, the script may need a small update.
- **Community tool, not affiliated with Anthropic.**

---

<a id="license"></a>
## 📜 License

**MIT** — see [LICENSE](LICENSE). Use it, fork it, share it, ship it.
