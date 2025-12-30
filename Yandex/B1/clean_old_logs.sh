#!/bin/bash
# Очистка логов в $log_dir старше $days дней
# Очитска только в указанной директории, без поддиректорий
# Версия 1.0. 
# TODO: переписать чз функции. Комментарии и сообщения на одном языке

# check number of arguments
if  [[ $# -ne 2 ]]; then
    echo 'Wrong number of agruments' >&2
    echo "Example: $0 /var/log 30"
    exit 1
fi

# VARIABLES
log_dir="$1"
days="$2"
file_pattern="*.log"
number_files=0

# check directory exists and is readable
if [[ ! -d "$log_dir" ]] || [[ ! -r "$log_dir" ]]; then
    echo "Directory -> '$log_dir' <- does not exist or is not readable" >&2
    exit 1
fi
# check the number of days is int and > 0 
if ! [[ "$days" =~ ^[0-9]+$  ]] || [[ "$days" -le 0 ]]; then
    echo "Number of days -> '$days' <- is NOT correct" >&2
    exit 1
fi 

echo "Очистка логов в '$log_dir' старше $days дней"

# find files and make arrays
log_files=()
while IFS= read -r file; do 
    log_files+=("$file")
done < <(find "$log_dir" -name "$file_pattern" -type f -mtime +"$days" -maxdepth 1)

number_files=${#log_files[@]}

# проверяем количество найденных файлов
if [[ "$number_files" -eq 0 ]]; then
    echo "Файлов для удаления не найдено"
    exit 0
fi

# выводим список с нумерацией найденных файлов
echo "Найдено "$number_files" файлов для удаления:"
i=0
for file in "${log_files[@]}"; do
#    i=$[$i+1]
    (( i++ ))   
    echo "$i - $file"
done

# подтверждение удаления или выход
read -p "Удалить найденные файлы? [y/N]: " confirm
if [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]]; then
    echo "Удаление отменено"
    exit 0
fi
# удаляем с проверкой 
for file in "${log_files[@]}"; do
    if [[ -f "$file" ]]; then 
        rm "$file"
    fi
done

echo "Удаление завершено"
