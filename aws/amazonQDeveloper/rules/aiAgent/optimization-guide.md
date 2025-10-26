# AI Doc Optimization

Goal: 80-90% token reduction, 100% info preserved.

## Rules
Merge sections|Flat hierarchy max 2 levels|Single file <500 lines|No `\n` between items use `|`|Symbols `→|<>≥≤±`|No bullets|No bold/italic|Inline code <3 lines|Abbrev: gen str num cfg env desc cmd|Remove articles/conjunctions|Imperative only|No full sentences|Remove spaces in code `{a:1,b:2}`|Single line code|No comments|Shortest syntax|Facts only|Code>description|Merge duplicates|Error→solution only

## Process
1.ID core: what+how+issues+patterns
2.Compress: "Add model update ModelType"→"Add model:ModelType→MODEL_IDS"
3.Merge: Installation+Running+Testing→`Cmd:npm install|npm run dev|npm test`
4.Validate: AI extracts all?✓ <50% tokens?✓

## Examples
Bad(45tok): "To add new model follow steps: 1.Update ModelType 2.Add MODEL_IDS 3.Update payload"
Good(12tok): "Add model:ModelType→MODEL_IDS→payload" | 73% reduction

## Anti-Patterns
❌"In order to"|"You can"|"This allows"|Multi examples|Explanations→✅Direct|Imperative|Result|One example|Code

## Checklist
Remove articles|Symbols not words|Merge sections|Inline code|No spaces|Abbrev|No sentences|Facts only|<50% tokens
