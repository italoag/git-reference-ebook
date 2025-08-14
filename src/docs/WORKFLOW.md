# WORKFLOW — Quadro de Decisão (Git Flow × Trunk-Based)

Este documento ajuda a escolher e operar o modelo de branching do repositório.

## 1) Checklist Rápido

- CI com testes, lint e segurança roda < 10 min?  
  - Sim -> considere Trunk-Based  
  - Nao -> prefira Git Flow (ate fortalecer a CI)

- Necessidade de deploy continuo (qualquer dia/hora)?  
  - Sim -> Trunk-Based  
  - Nao (janelas de release, homolog formal) -> Git Flow

- Compliance/Auditoria exige gates manuais por release?  
  - Sim -> Git Flow (ou TBD + approvals rigidos)  
  - Nao -> Trunk-Based

- Cultura de PRs pequenas (<= 300 LOC) e review em <= 24h?  
  - Sim -> Trunk-Based  
  - Nao -> Git Flow (transicao gradual depois)

- Feature flags disponiveis e usadas corretamente?  
  - Sim -> Trunk-Based  
  - Nao -> Git Flow (priorize implementar flags)

## 2) Operação Padrão por Modelo

### 2.1 Trunk-Based

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

### 2.2 Git Flow

- Branches: `main`, `develop`, `feature/*`, `release/*`, `hotfix/*`  
- Ciclo Feature: `git flow feature start/publish/finish` (ou PR -> `develop`)  
- Release: `git flow release start/finish` (merge em `main` com tag e em `develop`)  
- Hotfix: `git flow hotfix start/finish` (merge em `main` com tag e em `develop`)  
- Praticas: releases e release branches curtas; PRs e CI em todas as integracoes.

## 3) Boas Práticas Comuns

- Rebase seguro: apenas em branches privadas; publicar com `--force-with-lease`.  
- Worktree: use para paralelizar hotfix e feature sem novo clone.  
- Stash: snapshots temporarios com `-u -m`; limpe stashes antigos.  
- Observabilidade: metricas DORA (lead time, frequency, failure rate, MTTR).  
- Segurança: dependabot/renovate, SAST/secret scan, require signed commits (quando aplicavel).  

## 4) Transição (Git Flow -> Trunk-Based)

1) Endurecer `main` (protections + checks).  
2) Reduzir tamanho de PRs e tempo de review.  
3) Introduzir feature flags.  
4) Descontinuar `develop`; usar release branch curta so quando necessario.  
5) Padronizar releases por tag e changelog automatico.

## 5) Comandos Essenciais (Lembrete)

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
