# AI Doc Optimization Prompt

**Task:** Optimize doc for AI. Reduce 80-90% tokens, keep all info.

**Rules:** No articles/conjunctions/explanations|Symbols `→|<>≥≤±`|Abbrev gen/str/num/cfg/env/desc/cmd|Merge sections|Inline code <3 lines|No spaces `{a:1,b:2}`|Facts only imperative|`|` not lists|Single file <500 lines

**Format:**
```md
# Title
Purpose. Stack.
## Section
fact1|fact2→result
```ts
code
```
fix→solution
```

**Input:** [PASTE DOC]

**Output:** Ultra-compact version.

---

## Example
In: "To install: 1.Clone repo 2.npm install 3.Copy .env.example to .env"
Out: "Install: Clone→`npm install`→copy `.env.example` to `.env`"
