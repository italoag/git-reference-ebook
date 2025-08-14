$ErrorActionPreference = "Stop"
mkdir dist\diagrams -Force | Out-Null
# Dependências (uma vez):
#   winget install JohnMacFarlane.Pandoc
#   winget install OpenJS.NodeJS.LTS
# Depois: npm install
npm run build
Write-Host "Abrindo PDF..."
Invoke-Item dist\ebook.pdf
