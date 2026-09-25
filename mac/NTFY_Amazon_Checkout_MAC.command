#!/bin/zsh

BASE="$HOME/Pokemon"
TOPIC_FILE="$BASE/ntfy_topic.txt"

mkdir -p "$BASE"

if [[ -n "$NTFY_TOPIC_MAC" ]]; then
    TOPIC="$(printf '%s' "$NTFY_TOPIC_MAC" | tr -d '[:space:]')"
elif [[ -f "$TOPIC_FILE" ]]; then
    TOPIC="$(cat "$TOPIC_FILE" | tr -d '[:space:]')"
else
    echo ""
    read "TOPIC?Pega tu NTFY_TOPIC: "
    TOPIC="$(printf '%s' "$TOPIC" | tr -d '[:space:]')"

    if [[ -z "$TOPIC" ]]; then
        echo "ERROR: topic vacío."
        exit 1
    fi

    printf '%s' "$TOPIC" > "$TOPIC_FILE"
    chmod 600 "$TOPIC_FILE"
    echo "Topic guardado localmente en $TOPIC_FILE"
fi

if [[ -z "$TOPIC" ]]; then
    echo "ERROR: NTFY_TOPIC vacío."
    exit 1
fi

STREAM="https://ntfy.sh/$TOPIC/json"

echo ""
echo "NTFY -> AMAZON CHECKOUT LISTENER MAC"
echo "Stream: $STREAM"
echo "Browser: Safari"
echo "Solo abre URLs de checkout de Amazon México."
echo "Esperando mensajes en tiempo real..."
echo ""

while true; do
    echo "[$(date '+%H:%M:%S')] CONECTANDO A NTFY..."

    curl --silent --show-error --no-buffer --fail "$STREAM" |
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        CLICK="$(
            printf '%s' "$line" |
            /usr/bin/plutil -extract click raw -o - - 2>/dev/null
        )"

        [[ -z "$CLICK" ]] && continue

        case "$CLICK" in
            https://amazon.com.mx/*|https://www.amazon.com.mx/*|https://*.amazon.com.mx/*)
                ;;
            *)
                continue
                ;;
        esac

        if [[ "$CLICK" != *"/checkout/"* ]]; then
            continue
        fi

        echo ""
        echo "=============================================="
        echo "[$(date '+%H:%M:%S')] CHECKOUT RECIBIDO"
        echo "$CLICK"
        echo "ABRIENDO SAFARI..."
        echo "=============================================="
        echo ""

        /usr/bin/open -a "Safari" "$CLICK"
    done

    echo "Stream desconectado. Reconectando en 1 segundo..."
    sleep 1
done
