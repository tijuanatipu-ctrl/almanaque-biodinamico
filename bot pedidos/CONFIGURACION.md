# Portal General Pinto - Guía de Configuración

## Lo que necesitás (simplificado con Blotato)

| Servicio | Para qué | Estado |
|----------|----------|--------|
| Telegram Bot | Recibir noticias | ✅ Listo |
| OpenAI API Key | GPT-4o (reescritura) + DALL-E (imágenes) | ✅ Listo |
| Instagram Business | Cuenta conectada | ✅ Listo |
| **Blotato** | Publicar en IG + FB + TikTok | ⬜ Falta |

---

## Paso 1 — Configurar Blotato

Blotato reemplaza toda la complejidad de Meta Developer App y TikTok API.

1. Registrarse en **blotato.com**
2. Ir a **Settings → Connected Accounts** y conectar:
   - Instagram (la cuenta Business que ya tenés)
   - Facebook Page
   - TikTok
3. Ir a **Settings → API Keys** → crear una nueva API Key → copiarla
4. Para cada cuenta conectada, copiar el **Account ID** (aparece en la lista de cuentas)

---

## Paso 2 — Credenciales en n8n

Crear estas credenciales en n8n (Settings → Credentials → Add):

### Telegram Bot - Portal GP
- Tipo: **Telegram API**
- Access Token: `tu-bot-token` (el que te dio @BotFather)

### OpenAI API Key
- Tipo: **HTTP Header Auth**
- Name: `Authorization`
- Value: `Bearer sk-...` (tu clave de OpenAI)

---

## Paso 3 — Completar valores en el workflow

Después de importar el JSON en n8n, buscar y reemplazar en los nodos:

### En los 3 nodos de Blotato (Instagram, Facebook, TikTok):
```
TU_BLOTATO_API_KEY              → tu API key de Blotato
TU_INSTAGRAM_ACCOUNT_ID_EN_BLOTATO  → Account ID de IG en Blotato
TU_FACEBOOK_ACCOUNT_ID_EN_BLOTATO   → Account ID de FB en Blotato
TU_TIKTOK_ACCOUNT_ID_EN_BLOTATO     → Account ID de TT en Blotato
```

### En el nodo "Preparar Datos de Foto":
```
{{ TU_BOT_TOKEN }}  → tu Telegram Bot Token
```
(Este nodo se usa cuando enviás fotos por Telegram, para construir la URL de descarga)

---

## Paso 4 — Activar el webhook de Telegram

1. Importar el workflow JSON en n8n
2. Abrir el nodo **"Telegram: Recibir Mensaje"**
3. Seleccionar la credencial **Telegram Bot - Portal GP**
4. Hacer clic en **"Listen for test event"** una vez para registrar el webhook
5. Activar el workflow con el toggle ON

---

## Cómo usar el portal

Desde Telegram le mandás al bot:

| Lo que mandás | Qué pasa |
|---------------|----------|
| `https://www.distritointerior.com.ar/nota/...` | Scrapea la noticia, la reescribe y publica |
| `https://diariodemocracia.com.ar/...` | Ídem |
| Foto + texto (estado de WhatsApp) | Usa tu foto, reescribe el texto y publica |
| Texto libre | Reescribe, genera imagen con DALL-E y publica |

El bot te responde con confirmación de cada plataforma.

---

## Costos estimados por noticia

| Servicio | Costo aprox. |
|----------|-------------|
| GPT-4o (reescritura) | ~$0.01 USD |
| DALL-E 3 (imagen) | ~$0.04 USD |
| Blotato | Plan mensual fijo |
| **Total por noticia** | **~$0.05 USD** |

Con 20 noticias por día → ~$1 USD/día en APIs de OpenAI.

---

## Próximos pasos opcionales

- **Aprobación manual**: agregar un nodo que te pida confirmación por Telegram antes de publicar
- **Horario**: usar el nodo "Schedule" para publicar en horario pico (12hs y 19hs)
- **WordPress**: agregar nodo para publicar también en el sitio web
- **Múltiples operadores**: restringir el bot a ciertos chat IDs para que solo vos (y tu equipo) puedan usarlo
