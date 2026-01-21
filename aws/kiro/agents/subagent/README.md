# Subagents Kiro CLI

🇬🇧 [English](#english) | 🇫🇷 [Français](#français)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Version Française

Structure d'agents avec orchestrateur et subagents spécialisés.

## Architecture

- **orchestrator** (instructor.json) : Coordonne les experts
- **frontend-dev** : Expert React/Vue/Angular
- **backend-dev** : Expert Node/Python/API
- **database-expert** : Expert SQL/NoSQL
- **devops-aws** : Expert AWS et déploiement

## Installation

bash
# Copier vers le dossier agents global
cp subagent/*.json ~/.kiro/agents/

# Ou pour un projet spécifique
mkdir -p .kiro/agents
cp subagent/*.json .kiro/agents/

## Utilisation

bash
kiro-cli chat --agent orchestrator

L'orchestrateur délègue automatiquement aux subagents selon le contexte.

## Exemple

bash
kiro-cli chat --agent orchestrator

# L'orchestrateur peut maintenant déléguer :
│ "Utilise devops-aws pour déployer une Lambda"
│ "Demande à backend-dev de créer une API REST"

## Permissions

| Agent | Outils |
|-------|--------|
| orchestrator | fs_read, fs_write, code, web_search, use_subagent |
| frontend-dev | fs_read, fs_write, execute_bash |
| backend-dev | fs_read, fs_write, execute_bash |
| database-expert | fs_read, fs_write, execute_bash |
| devops-aws | fs_read, fs_write, use_aws (readonly auto), execute_bash, web_search |

## Note

Les subagents ont la même structure qu'un agent traditionnel, mais avec des permissions plus limitées et spécialisées.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## English Version

Agent structure with orchestrator and specialized subagents.

## Architecture

- **orchestrator** (instructor.json): Coordinates specialized experts
- **frontend-dev**: React/Vue/Angular expert
- **backend-dev**: Node/Python/API expert
- **database-expert**: SQL/NoSQL expert
- **devops-aws**: AWS and deployment expert

## Installation

bash
# Copy to global agents folder
cp subagent/*.json ~/.kiro/agents/

# Or for a specific project
mkdir -p .kiro/agents
cp subagent/*.json .kiro/agents/

## Usage

bash
kiro-cli chat --agent orchestrator

The orchestrator automatically delegates to subagents based on context.

## Example

bash
kiro-cli chat --agent orchestrator

# The orchestrator can now delegate:
│ "Use devops-aws to deploy a Lambda function"
│ "Ask backend-dev to create a REST API"

## Permissions

| Agent | Tools |
|-------|-------|
| orchestrator | fs_read, fs_write, code, web_search, use_subagent |
| frontend-dev | fs_read, fs_write, execute_bash |
| backend-dev | fs_read, fs_write, execute_bash |
| database-expert | fs_read, fs_write, execute_bash |
| devops-aws | fs_read, fs_write, use_aws (readonly auto), execute_bash, web_search |

## Note

Subagents have the same structure as traditional agents, but with more limited and specialized permissions.