# Pokémon Checkout Listener

Cliente ligero para Windows y macOS que escucha un topic de **ntfy** en tiempo real y abre automáticamente en el navegador las URLs de checkout de **Amazon México** publicadas en el campo `click` de la notificación.

> Este proyecto **no compra automáticamente**. Solo abre la URL de checkout. La confirmación final del pedido sigue siendo manual.

## Flujo

```text
Fuente de alertas / listener
        ↓
      ntfy
        ↓
Windows o macOS
        ↓
valida amazon.com.mx + /checkout/
        ↓
abre Edge / Chrome / Safari
```

## Qué hace

- Mantiene una conexión al stream JSON de ntfy.
- Ignora mensajes sin campo `click`.
- Ignora dominios que no sean `amazon.com.mx`.
- Ignora enlaces cuya ruta no contenga `/checkout/`.
- Abre el checkout en el navegador configurado.
- Se reconecta si el stream se interrumpe.

## Windows

Descarga `windows/NTFY_Amazon_Checkout_PC.ps1` y ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File ".\NTFY_Amazon_Checkout_PC.ps1" -Browser edge
```

También puedes usar:

```powershell
-Browser chrome
-Browser default
```

Si `NTFY_TOPIC_PC` no existe, el script pedirá el topic.

Para guardarlo como variable de usuario:

```powershell
[System.Environment]::SetEnvironmentVariable(
  "NTFY_TOPIC_PC",
  "TU_TOPIC",
  "User"
)
```

Cierra y vuelve a abrir PowerShell. Para verificar:

```powershell
[System.Environment]::GetEnvironmentVariable("NTFY_TOPIC_PC","User")
```

## macOS

Descarga `mac/NTFY_Amazon_Checkout_MAC.command` y ejecuta:

```bash
chmod +x NTFY_Amazon_Checkout_MAC.command
./NTFY_Amazon_Checkout_MAC.command
```

Si no existe `NTFY_TOPIC_MAC`, la primera vez pedirá el topic y lo guardará en:

```text
~/Pokemon/ntfy_topic.txt
```

con permisos `600`.

## Formato de mensaje esperado

El publicador debe enviar un campo `click`, por ejemplo:

```json
{
  "topic": "TU_TOPIC",
  "title": "Pokémon disponible",
  "message": "Producto disponible",
  "priority": 5,
  "click": "https://www.amazon.com.mx/checkout/..."
}
```

El cliente solo abre la URL si pertenece a Amazon México y contiene `/checkout/`.

## Seguridad del topic

En `ntfy.sh`, un topic sin protección es público: quien conozca su nombre puede **suscribirse y publicar**. Por eso el nombre del topic funciona, en la práctica, como un secreto compartido.

**No incluyas topics reales en GitHub, capturas públicas, issues, commits o releases.**

### ¿Qué puede pasar si alguien conoce el topic?

Un tercero podría:

- suscribirse y ver las alertas;
- conocer los productos y URLs de checkout publicados;
- publicar mensajes falsos o spam;
- provocar que estos clientes abran URLs de checkout de Amazon México que el tercero publique.

El filtro de dominio/ruta reduce el impacto: conocer el topic **no permite ejecutar comandos arbitrarios en la computadora**, y estos scripts **no confirman compras**. Aun así, un topic filtrado puede causar falsas alertas, aperturas molestas y exposición de la información del feed.

## ¿Un topic por persona o uno compartido?

### Topic individual por usuario — recomendado para distribución

Ventajas:

- si se filtra el topic de una persona, solo cambias ese topic;
- puedes retirar a una persona sin afectar al resto;
- cada usuario controla su configuración;
- un error de un miembro no expone automáticamente el feed de todos.

La desventaja es que el sistema publicador debe enviar la alerta a varios topics.

### Topic compartido por un grupo de confianza

Es más simple: un solo mensaje llega a todos.

La desventaja es que todos comparten el mismo secreto. Si una persona publica el topic por accidente o deja de ser de confianza, hay que rotarlo para todo el grupo.

Para un grupo pequeño puede ser razonable si el nombre es largo, aleatorio y nunca se publica.

### Protección más fuerte

Si necesitas control de acceso real, usa autenticación/ACL o reservas/control de acceso de ntfy cuando estén disponibles para tu despliegue. No dependas solo del secreto del nombre del topic.

## Cómo elegir un topic

Evita nombres fáciles de adivinar:

```text
pokemon
alertas
pokemon-restock
mi-nombre-pokemon
```

Prefiere algo largo y aleatorio:

```text
pokemon-<cadena-aleatoria-larga>
```

No uses el ejemplo literalmente.

## Qué NO subir a GitHub

- topics reales;
- tokens o contraseñas;
- cookies de Amazon;
- sesiones de Telegram;
- archivos `.env`;
- logs privados con URLs que no quieras publicar.

## Cómo compartir con amigos

1. Publica el repositorio sin secretos.
2. Crea un **GitHub Release**.
3. Adjunta los dos scripts.
4. Cada usuario descarga el archivo de su sistema.
5. Cada usuario configura su propio topic, o el topic compartido del grupo si esa es una decisión consciente.
6. Mantén Amazon iniciado en el navegador para reducir el tiempo de carga.

Evita instrucciones del tipo `curl ... | bash` o `irm ... | iex`. Es más transparente descargar y revisar el archivo antes de ejecutarlo.

## Limitaciones

- Depende de ntfy e Internet.
- Amazon puede rechazar el checkout, cambiar el flujo, agotar inventario o aplicar límites.
- Abrir la URL no garantiza disponibilidad.
- No confirma pedidos automáticamente.
- PowerShell, Gatekeeper y navegadores pueden comportarse distinto según la configuración local.
