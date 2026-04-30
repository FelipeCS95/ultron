#!/bin/bash


# Verifica flag --no-list
OMIT_LISTA=0
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--no-list" ]]; then
        OMIT_LISTA=1
    else
        ARGS+=("$arg")
    fi
done

# Pasta raiz das músicas (passe como argumento ou use atual)
MUSIC_DIR="${ARGS[0]:-.}"

# Extensões suportadas (adicione se precisar)
EXTENSIONS="mp3 flac m4a ogg wav wma aac mpc"

echo "Analisando pasta: $MUSIC_DIR"
echo "------------------------------------------------------------"


# Associative arrays para agrupar músicas por artista
declare -A artist_songs

# Encontra todos os arquivos .mp3 e processa
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    base="${filename%.*}"
    if [[ "$base" =~ ^(.+)\ -\ (.+)$ ]]; then
        artist="${BASH_REMATCH[1]}"
        song="${BASH_REMATCH[2]}"
        artist_songs["$artist"]+="$song;"
    else
        echo "Formato inválido: $base" >&2
    fi
done < <(find "$MUSIC_DIR" -type f -iname "*.mp3" -print0)

# Imprime resultado

# Salva resultado em arquivo temporário
tmp_file="artists_count.tmp"

for artist in "${!artist_songs[@]}"; do
    songs_str="${artist_songs[$artist]%;}"
    IFS=';' read -ra songs <<< "$songs_str"
    count="${#songs[@]}"
    if [[ $OMIT_LISTA -eq 1 ]]; then
        echo "$artist - $count"
    else
        music_list=$(printf "%s, " "${songs[@]}")
        music_list="${music_list%, }"
        echo "$artist - $count - $music_list"
    fi
done > "$tmp_file"

# Ordena por contagem (campo entre os dois primeiros traços, ignorando traços no nome do artista)
# Ordena pelo número de músicas usando awk e sort
awk -F' - ' '{print $2"\t"$0}' "$tmp_file" | sort -k1,1nr | cut -f2- > artists_count.txt
rm "$tmp_file"

echo "Artistas encontrados e contagem de músicas:"
cat artists_count.txt

echo ""
echo "Total de músicas processadas: $(wc -l < artists_count.txt | awk '{print $1}')"
echo "Total de artistas únicos: $(wc -l < artists_count.txt | awk '{print $1}')"

echo "------------------------------------------------------------"
echo "Resultado salvo em: artists_count.txt (no diretório atual)"
echo "Use 'cat artists_count.txt | head -n 20' para ver os 20 maiores, por exemplo."
