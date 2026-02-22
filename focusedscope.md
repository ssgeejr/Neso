# Focused Scope: The Curious Analyst

## What We're Building

Not a vulnerability scanner. Not a Tenable clone. Not a CVE database lookup.

**A curious junior security analyst that pokes things and tells you what it found.**

---

## The Difference

### Traditional Scanner (Tenable, Nessus, Qualys)
```
Port 21 open. FTP. CVE-2022-XXXX. CVSS 7.2. 
Recommendation: Disable anonymous access or close port.
Status: MEDIUM
```

Cold. Robotic. One of 47,000 findings in a PDF no one reads.

### Our AI Analyst
```
Hey, port 21 is open on 192.168.0.47. I poked it - anonymous 
login works. Got a directory listing. There's a folder called 
`payroll_backup_2024`. 

Should I be concerned about this?
```

Context. Curiosity. Evidence. A conversation.

---

## More Examples

### Example 1: Open SSH
**Scanner:** "Port 22 open. SSH. Ensure key-based auth."

**Our AI:** "Found SSH on 192.168.0.12. Tried root with no password - rejected. Tried admin/admin - rejected. But it's not rate-limiting me. I tried 50 passwords in 10 seconds and it didn't care. Brute force might work here."

---

### Example 2: Web Server
**Scanner:** "Port 80 open. Apache 2.4.29. CVE-2021-XXXX."

**Our AI:** "Web server on port 80. Poked around - found `/admin` returns 403 Forbidden, but `/admin/login.php` loads fine. Default creds didn't work, but there's no CAPTCHA and no lockout. Also, the Apache version in the header is old - 2.4.29. Want me to check what's exploitable on that version?"

---

### Example 3: SMB Share
**Scanner:** "Port 445 open. SMB. Signing not required."

**Our AI:** "SMB is open on 192.168.0.100. Connected with null session - got a share list. There's a share called `IT_Archive` that allows anonymous read. I pulled the file list - there's a `passwords.xlsx` in there from 2023. This seems bad. Should I grab it for evidence?"

---

### Example 4: Unexpected Host
**Scanner:** (Doesn't report - not in asset inventory)

**Our AI:** "Hey, there's a device at 192.168.0.199 that wasn't here last week. It's responding to ping, has ports 22, 80, and 3389 open. The HTTP title says 'MikroTik RouterOS'. Did someone add a router? This isn't in any of our documentation."

---

### Example 5: Lateral Movement Opportunity
**Scanner:** "MS17-010 vulnerability detected."

**Our AI:** "That Windows box at 192.168.0.47 is vulnerable to EternalBlue. If I had a foothold on the network, I could pivot through it to reach the database server behind it. The DB server isn't exposed directly, but this box talks to it on 1433. This is a lateral movement path. Should we patch this first?"

---

## The Value Proposition

| Traditional Scanner | Our AI Analyst |
|---------------------|----------------|
| Lists vulnerabilities | Explores and explains |
| CVE numbers | "Here's what I tried" |
| CVSS scores | "Here's why it matters" |
| 10,000 line PDF | Conversation |
| Requires interpretation | Provides context |
| Finds known issues | Notices weird things |
| One-time snapshot | Curious and persistent |

---

## What It's NOT

- ❌ Not an autonomous attack tool
- ❌ Not a replacement for pentesters
- ❌ Not a compliance checkbox
- ❌ Not Metasploit with a chatbot
- ❌ Not something we point at production without approval

---

## What It IS

- ✅ A curious explorer that reports back
- ✅ A junior analyst that never sleeps
- ✅ A second set of eyes on your network
- ✅ Natural language security findings
- ✅ Context-aware, not just CVE-aware
- ✅ Escalates with evidence, not just scores
- ✅ **Under your control, always**

---

## The Guardrails

1. **Explicit scope** - Only touches what you tell it to
2. **Air-gapped development** - Built on isolated infrastructure
3. **Approval gates** - Asks before doing anything destructive
4. **Full logging** - Every probe, every finding, every action
5. **Kill switch** - `/reset-session` or pull the plug
6. **Blue team mindset** - Finds problems, doesn't exploit them

---

## The Philosophy

> "You don't need the shield until you understand how the sword works."

We build offensive awareness to strengthen defensive posture. The AI thinks like an attacker so you can defend like one.

But the sword stays in the armory. Always.

---

## Classification

🔒 **INTERNAL USE ONLY** 🔒

This document describes security research architecture. 
Do not commit sensitive details. Do not share externally.
