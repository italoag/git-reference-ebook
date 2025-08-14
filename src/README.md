# Guia Completo de Git para Times no GitHub  
**(Git Flow, Trunk-Based Development, Worktree, Rebase, Stash + Cheat Sheet)**

> Compatível com macOS e Windows (Git Bash/PowerShell). Foco em equipes que desejam histórico limpo, CI/CD confiável e governança em repositórios GitHub.

---

## Sumário
1. [Introdução e Setup](#introdução-e-setup)  
2. [Git Flow — Modelo completo](#git-flow--modelo-completo)  
3. [Trunk-Based Development (TBD)](#trunk-based-development-tbd)  
4. [Comparação: Git Flow × Trunk-Based](#comparação-git-flow--trunk-based)  
5. [git worktree — Múltiplas cópias de trabalho](#git-worktree--múltiplas-cópias-de-trabalho)  
6. [git rebase — uso correto e seguro](#git-rebase--uso-correto-e-seguro)  
7. [git stash — snapshots temporários](#git-stash--snapshots-temporários)  
8. [Cheat Sheet / Reference Card](#cheat-sheet--reference-card)  
9. [Referências](#referências)

---

## Introdução e Setup

**Identidade e editor**
```bash
git config --global user.name  "Seu Nome"
git config --global user.email "seu.email@empresa.com"
git config --global core.editor "code --wait"   # VS Code; ajuste se preferir
```

**Quebra de linha (evitar CRLF/LF):**
- Windows: `git config --global core.autocrlf true`
- macOS/Linux: `git config --global core.autocrlf input`

**Autenticação GitHub**
- Prefira SSH (chaves) ou GCM Core (HTTPS OAuth/PAT).
- Ative Signed commits (opcional, recomendado).

---

## Git Flow — Modelo completo

![Git Flow](diagrams/gitflow.svg)

Quando usar: versoes programadas, ambientes distintos (homolog/producao), exigencias de auditoria e hardening antes do release.

Branches principais
- `main` (producao): apenas releases estaveis (tagueados).  
- `develop` (integracao): base das features e origem das releases.

Branches auxiliares
- `feature/*`: novas funcionalidades a partir de `develop`.  
- `release/*`: estabilizacao curta antes de ir para `main`; ao terminar, merge em `main` (tag) e em `develop`.  
- `hotfix/*`: correcoes criticas a partir de `main`; ao terminar, merge em `main` (tag) e em `develop`.

Comandos (extensao git-flow opcional)
```bash
# Inicializacao
git flow init -d

# Feature
git flow feature start login-oauth
# ... commits ...
git flow feature publish login-oauth         # opcional (colaboracao)
git flow feature finish  login-oauth         # merge -> develop + cleanup

# Release
git flow release start 1.4.0
# ... fixes finais / version bump ...
git flow release finish 1.4.0                # merge -> main (tag) e -> develop
git push origin main develop --tags

# Hotfix
git flow hotfix start 1.4.1
# ... fix critico ...
git flow hotfix finish 1.4.1                 # merge -> main (tag) e -> develop
git push origin main develop --tags
```

Dicas
- Use PRs no GitHub para revisao, mesmo com git-flow (em vez de finish local).  
- Mantenha release branches curtas.  
- Evite acumular features longas; faca rebase frequente com `develop`.

---

## Trunk-Based Development (TBD)

![Trunk-Based Development](diagrams/trunk.svg)

Quando usar: entrega continua, deploys frequentes, times com CI forte e PRs pequenas. A branch principal (`main`) e o trunk; branches de feature sao curtas (<= 24–48h) e integradas continuamente.

Principios
- PRs pequenas e revisao rapida.  
- Historico linear (Rebase & merge ou Squash & merge).  
- Feature flags para liberar codigo incompleto com seguranca.  
- Releases por tag; `release/*` so se estritamente necessario e por poucas horas/dias.

Exemplo de ciclo
```bash
git checkout main
git pull --rebase

git checkout -b feat/login-oauth
# ... commits pequenos; se esqueceu algo, --amend ...
git fetch origin
git rebase --autostash origin/main

git push -u origin feat/login-oauth
# Abra PR no GitHub (checks obrigatorios, review curto)
# Merge: "Rebase & merge" ou "Squash & merge"
```

Feature flags (exemplos simples)

TypeScript/Node:
```ts
// config.ts
export const flags = { LOGIN_OAUTH: process.env.LOGIN_OAUTH === "true" };

// login.ts
import { flags } from "./config";
export function login(req, res) {
  return flags.LOGIN_OAUTH ? oauthLogin(req, res) : legacyLogin(req, res);
}
```

Java/Spring:
```java
@Component
public class FeatureFlags {
  public boolean loginOauth() {
    return Boolean.parseBoolean(System.getenv().getOrDefault("LOGIN_OAUTH","false"));
  }
}
```

Politicas GitHub para TBD
- Branch protection em `main`: Require pull request review, Required status checks, Require linear history, bloquear force push, apagar branch ao merge.  
- CI minimo (GitHub Actions):
```yaml
# .github/workflows/ci.yml
name: ci
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm run lint
      - run: npm test -- --ci
```

---

## Comparação: Git Flow × Trunk-Based

| Criterio | Git Flow | Trunk-Based Development |
|---|---|---|
| Cadencia | Releases com release branch | Deploys frequentes por tag |
| Duracao de branches | Longas (develop/release/hotfix) | Curtas (<= 48h) |
| Integracao | Mais tardia; risco de merge hell | Continua; conflitos menores e constantes |
| Historico | Preserva topologia; mais merges | Linear (rebase/squash); leitura facil |
| Funcionalidade incompleta | Fica na feature | Vai para `main` sob feature flag |
| Hotfix | `hotfix/*` a partir de `main` | PR curta direto no trunk |
| Conformidade/Auditoria | Processo explicito de release | Exige disciplina em tags e approvals |
| Maturidade de CI | Funciona com CI parcial | Requer CI robusta |
| Velocidade de entrega | Media/baixa | Alta |
| Risco de regressao | Mitigado em release branch | Baixo com flags + testes; revert rapido |

Como escolher
- TBD: voce quer deploy a qualquer momento, tem CI forte, cultura de PRs pequenas e feature flags.  
- Git Flow: voce tem janelas de release, compliance pesado, ambientes separados e precisa de hardening antes de produzir.

Modelo hibrido (transicao)
1) Endureca `main` (protections, checks). 2) Encurte features. 3) Introduza flags.  
4) Aposente `develop` gradualmente. 5) Releases por tag com release branch curta quando necessario.

---

## git worktree — Múltiplas cópias de trabalho

Por que: trabalhar em duas ou mais branches em paralelo sem clonar o repo novamente. Economiza espaco e tempo.

```bash
# criar duas worktrees irmas (macOS)
git worktree add ../feat-login feat/login-oauth
git worktree add ../fix-csrf  fix/csrf-token

# Windows (PowerShell/Git Bash): use caminho com '\'
git worktree add ..\feat-login feat/login-oauth

# listar e remover
git worktree list
git worktree remove ../feat-login
git worktree prune  # se removeu a pasta manualmente
```

Casos tipicos: hotfix urgente paralelo a sua feature; benchmarks isolados; refactors arriscados sob flag.

---

## git rebase — uso correto e seguro

Regra de ouro: rebase em branches privadas/curtas; se ja publicou, use `--force-with-lease` ao fazer push.

Passo a passo (atualizar feature com a base):
```bash
git checkout minha-feature
git fetch --prune
git rebase --autostash origin/main
# resolver conflitos -> git add ...
git rebase --continue
git push --force-with-lease
```

Rebase interativo (limpar historico)
```bash
git rebase -i HEAD~10         # reword/squash/fixup/drop/reorder
git rebase --update-refs      # atualiza refs dependentes (Git >= 2.38)
```

Sair ou desfazer
```bash
git rebase --abort
git reflog        # seu paraquedas
git reset --hard <hash-do-reflog>
```

---

## git stash — snapshots temporários

Guardar e restaurar rapidamente:
```bash
git stash push -u -m "WIP: oauth"
git stash list
git stash show -p stash@{0}
git stash apply stash@{0}     # mantem na pilha
git stash pop                 # aplica e remove da pilha
git stash branch feat/poc stash@{0}  # cria branch do ponto do stash
git stash drop stash@{0}
git stash clear
```

Boas praticas: nomeie (-m), inclua untracked (-u) quando necessario, limpe stashes antigos para nao inflar `.git`.

---

## Cheat Sheet / Reference Card

### Basico
```bash
git status
git add -p                     # selecao interativa de hunks
git commit -m "feat: msg"
git commit --amend --no-edit   # corrige ultimo commit
git log --oneline --graph --decorate --all
git diff / git diff --staged
```

### Branching & Merge/Rebase
```bash
git switch -c feat/x           # (ou checkout -b)
git merge feat/x
git rebase origin/main
git rebase -i HEAD~N
git cherry-pick <hash>
git revert <hash>
```

### Remotos (GitHub)
```bash
git remote -v
git push -u origin feat/x
git pull --rebase
git fetch -p
git push --force-with-lease
git tag -a v1.2.3 -m "release"; git push origin v1.2.3
```

### Recuperacao
```bash
git reflog
git reset --hard <hash>
git restore --source=<hash> -- <path>   # recuperar arquivo especifico
```

### Worktree
```bash
git worktree add ../feat-x feat/x
git worktree list
git worktree remove ../feat-x
git worktree prune
```

### Stash
```bash
git stash push -u -m "msg"
git stash list; git stash show -p
git stash apply|pop [stash@{N}]
git stash branch fix/y stash@{N}
```

### Git Flow (extensao)
```bash
git flow init -d
git flow feature start|publish|finish <nome>
git flow release start|publish|finish <versao>
git flow hotfix  start|finish  <versao>
```

---

## Referências

- Git — Documentation: <https://git-scm.com/docs>  
- Trunk-Based Development (site oficial): <https://trunkbaseddevelopment.com/>  
- Martin Fowler — Branching Patterns: <https://martinfowler.com/articles/branching-patterns.html>  
- GitHub Docs — Branch protection rules: <https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository>  
- Git Flow (Vincent Driessen): <https://nvie.com/posts/a-successful-git-branching-model/>  
- OpenFeature (feature flags): <https://openfeature.dev/>  
- Unleash (OSS feature flags): <https://www.getunleash.io/>  
