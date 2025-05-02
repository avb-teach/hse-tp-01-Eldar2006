#!/bin/bash

max_depth=""
input_dir=""
output_dir=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --max_depth)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                max_depth="$2"
                shift 2
            else
                echo "Ошибка: --max_depth требует числового аргумента."
                exit 1
            fi
            ;;
        *)
            break
            ;;
    esac
done

if [[ -z "$1" || -z "$2" ]]; then
    echo "Использование: $0 [--max_depth N] input_dir output_dir"
    exit 1
fi

input_dir="$1"
output_dir="$2"

if [[ ! -d "$input_dir" ]]; then
    echo "Ошибка: Входная директория '$input_dir' не существует."
    exit 1
fi

mkdir -p "$output_dir"

find_cmd="find \"$input_dir\""
if [[ -n "$max_depth" ]]; then
    find_cmd+=" -maxdepth $max_depth"
fi
find_cmd+=" -type f -print0"

eval "$find_cmd" | sort -z | while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    unique_name="$filename"
    counter=1

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
done