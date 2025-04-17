---
title: Go — Retracting Broken Module Versions
date: 2025-04-16 23:16:07 
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> Adding a retract directive to `go.mod` requires you to create a new version of your module. If the new version contains only the retraction, you should retract it as well.
>
> <footer>Learning Go (2nd edition) — Chapter 10, "Retracting a Version of Your Module"</footer>

Let's take an example to understand how to retract a broken module version in Go.

1. Add retract to go.mod:
```text go.mod
module github.com/your/module

go 1.21

retract v1.2.0 // Broken version
```

2. Tag a New Version (e.g., v1.2.1):
```bash
git commit -am "retract v1.2.0" # Only changes go.mod
git tag v1.2.1
git push origin v1.2.1
```

3. Retract the Placeholder Version (v1.2.1):
Since v1.2.1 exists only to retract v1.2.0, retract it too:
```text go.mod
retract (
    v1.2.0 // Original broken version
    v1.2.1 // Placeholder version with no fixes
)
```

4. Publish a Final Fixed Version (e.g., v1.2.2):
```bash
git commit -am "fix: patch critical bug"
git tag v1.2.2
git push origin v1.2.2
```
