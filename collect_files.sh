#!/bin/bash

max_depth=""
input_dir=""
output_dir=""

args=$(getopt -o '' --long max_depth: -- "$@") || exit 1
eval set -- "$args"

while true; do
    case "$1" in
        --max_depth)
            max_depth="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Неизвестная ошибка при разборе аргументов"
            exit 1
            ;;
    esac
done

input_dir="$1"
output_dir="$2"

if [[ -z "$input_dir" || -z "$output_dir" ]]; then
    echo "Использование: $0 [--max_depth N] input_dir output_dir"
    exit 1
fi

if [[ ! -d "$input_dir" ]]; then
    echo "Ошибка: Входная директория '$input_dir' не существует."
    exit 1
fi

mkdir -p "$output_dir"

find_cmd=("find" "$input_dir" "-type" "f")
if [[ -n "$max_depth" ]]; then
    find_cmd+=("-maxdepth" "$max_depth")
fi

counter=1
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    unique_name="$filename"

    while [[ -e "$output_dir/$unique_name" ]]; do
        name="${filename%.*}"
        ext="${filename##*.}"
        if [[ "$filename" == *.* ]]; then
            unique_name="${name}_${counter}.${ext}"
        else
            unique_name="${filename}_${counter}"
        fi
        ((counter++))
    done

    cp "$file" "$output_dir/$unique_name"
done < <("${find_cmd[@]}" -print0)