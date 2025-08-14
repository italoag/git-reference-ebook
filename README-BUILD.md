# Build do eBook (Windows/macOS)

## Pré-requisitos
- Pandoc
  - Windows: winget install JohnMacFarlane.Pandoc
  - macOS: brew install pandoc
- Node.js LTS
  - Windows: winget install OpenJS.NodeJS.LTS
  - macOS: brew install node

## Passos
1) Na pasta `ebook/`, instale as dependências:
   ```bash
   npm install
   ```
2) (Opcional) Copie fontes TTF para `fonts/` (PressStart2P, VT323, Inter, JetBrainsMono).
3) Execute o build:
   - Windows (PowerShell):
     ```powershell
     .\scripts\build.ps1
     ```
   - macOS (Terminal):
     ```bash
     ./scripts/build.sh
     ```

O PDF final ficará em `dist/ebook.pdf`. Os diagramas Mermaid são pré-renderizados em `dist/diagrams/`.
