#!/bin/bash

# Script para embeddar fontes no CSS
cd "$(dirname "$0")/.."

echo "Convertendo fontes para base64..."

# Criar versão do CSS com fontes embeddadas
cat > dist/styles/ebook-embedded.css << 'EOF'
/* styles/ebook.css */

/* 1) Fontes */
@font-face {
  font-family: "PixelTitle";
  src: url("data:font/truetype;base64,$(base64 -i fonts/PressStart2P.ttf)") format("truetype");
  font-display: swap;
}
@font-face {
  font-family: "PixelSub";
  src: url("data:font/truetype;base64,$(base64 -i fonts/VT323-Regular.ttf)") format("truetype");
  font-display: swap;
}
@font-face {
  font-family: "InterVar";
  src: url("data:font/truetype;base64,$(base64 -i fonts/Inter-Variable.ttf)") format("truetype");
  font-weight: 100 900;
  font-display: swap;
}
@font-face {
  font-family: "JetBrainsMono Nerd Font";
  src: url("data:font/truetype;base64,$(base64 -i fonts/JetBrainsMono-Regular.ttf)") format("truetype");
  font-display: swap;
}

/* 2) Tipografia global */
html, body {
  font-family: "InterVar", system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
  font-size: 11.5pt;
  line-height: 1.5;
  color: #1b1f24;
}

h1, h2, h3 {
  letter-spacing: 0.6px;
  margin: 1.6rem 0 0.8rem;
}
h1 { font-family: "PixelTitle", monospace; font-size: 20pt; }
h2 { font-family: "PixelSub", monospace;  font-size: 18pt; }
h3 { font-family: "PixelSub", monospace;  font-size: 15pt; }

/* 3) Código */
pre, code, kbd, samp {
  font-family: "JetBrainsMono Nerd Font", ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 10pt;
}
pre {
  background: #0f172a; /* slate-900 */
  color: #e5e7eb;      /* gray-200 */
  border-radius: 8px;
  padding: 12px 14px;
  overflow: auto;
  border-left: 6px solid #38bdf8; /* ciano */
  box-shadow: 0 1px 6px rgba(0,0,0,.15);
}
code { background: #111827; color: #f9fafb; padding: 0 3px; border-radius: 4px; }

/* 4) Tabelas */
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #E5E7EB; padding: 8px 10px; }
thead th { background: #111827; color: #E5E7EB; }

/* 5) Imagens/diagramas */
img { max-width: 100%; display: block; margin: 14px auto; }

/* 6) Layout de página para impressão */
@page {
  size: A4;
  margin: 20mm 18mm 22mm 18mm;
}
EOF

echo "Fontes embeddadas no CSS criado!"
