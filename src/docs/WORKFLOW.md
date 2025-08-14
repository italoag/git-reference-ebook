<div class="page-break"></div>

# WORKFLOW: QUARDO DE DESCISÃO

Este documento ajuda a escolher e operar o modelo de branching do repositório.

## 1. CHECKLIST RÁPIDO

![](diagrams/workflow-decision.svg)

## 2. OPERAÇÃO PADRÃO POR MODELO

### 2.1 TRUNK-BASED

- Branch principal: `main`  
- Politicas GitHub:  
  - Require PR review; Required status checks; Require linear history; bloquear force push; apagar branch ao merge.  
- Ciclo:  
  1) `git switch -c feat/<ticket>`  
  2) Commits pequenos; `git pull --rebase` frequente  
  3) PR pequena (checks obrigatorios)  
  4) Merge: Rebase & merge ou Squash & merge  
  5) Release por tag  
- Feature Flags: obrigatorias para codigo incompleto, com kill switch e rollout gradual.  
- Hotfix: PR curta direto em `main`; revert ou desligar flag se necessario.

### 2.2 GIT FLOW

- Branches: `main`, `develop`, `feature/*`, `release/*`, `hotfix/*`  
- Ciclo Feature: `git flow feature start/publish/finish` (ou PR -> `develop`)  
- Release: `git flow release start/finish` (merge em `main` com tag e em `develop`)  
- Hotfix: `git flow hotfix start/finish` (merge em `main` com tag e em `develop`)  
- Praticas: releases e release branches curtas; PRs e CI em todas as integracoes.

## 3. BOAS PRÁTICAS

- Rebase seguro: apenas em branches privadas; publicar com `--force-with-lease`.  
- Worktree: use para paralelizar hotfix e feature sem novo clone.  
- Stash: snapshots temporarios com `-u -m`; limpe stashes antigos.  
- Observabilidade: metricas DORA (lead time, frequency, failure rate, MTTR).  
- Segurança: dependabot/renovate, SAST/secret scan, require signed commits (quando aplicavel).  

## 4. TRANSIÇÃO (GIT FLOW -> TRUNK-BASED)

1) Endurecer `main` (protections + checks).  
2) Reduzir tamanho de PRs e tempo de review.  
3) Introduzir feature flags.  
4) Descontinuar `develop`; usar release branch curta so quando necessario.  
5) Padronizar releases por tag e changelog automatico.

## 5. COMANDOS ESSENCIAIS

```bash
# Rebase seguro
git fetch --prune
git rebase --autostash origin/main
git push --force-with-lease

# Worktree
git worktree add ../feat-x feat/x
git worktree list
git worktree remove ../feat-x

# Stash
git stash push -u -m "WIP"
git stash list
git stash apply|pop

# Git Flow (se usado)
git flow feature start|finish <nome>
git flow release start|finish <versao>
git flow hotfix  start|finish  <versao>
```
