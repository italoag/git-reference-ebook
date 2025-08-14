const fs = require("fs");
const missing = ["fonts/PressStart2P.ttf", "fonts/JetBrainsMono-Regular.ttf"].filter(p => !fs.existsSync(p));
if (missing.length) {
  console.warn("Atenção: fontes não encontradas (o build funcionará com fallback):\n- " + missing.join("\n- "));
}
