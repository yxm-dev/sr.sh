#! /bin/bash

function sr(){
    if [[ ! -d "$3" ]]; then
        echo "error: target directory not found."
        return 1
    fi
    if [[ -n "$1" ]]; then
        if [[ -n "$2" ]]; then
            declare -a text_occurrences
            declare -a file_names
            declare -a line_numbers
            declare -a line_contents

            while IFS=: read -r filename line_number line_content
            do
                text_occurrences+=("$1")
                file_names+=("$filename")
                line_numbers+=("$line_number")
                content=$(echo $line_content | sed 's/[^:]*://' )
                line_contents+=("$content")
            done < <(rg --vimgrep --color=always --colors 'match:bg:white' "$1" "$3")

            if [[ -z "${text_occurrences[@]}" ]]; then
                echo "No ocurrences of \"$1\" were found in \"$3\"."
                return 0
            else
                for i in "${!text_occurrences[@]}"; do
                    echo "Ocurrency \"$((i+1))\" in file \"${file_names[$i]}\": "
                    echo -e "${line_numbers[$i]}: ${line_contents[$i]}"
                    echo "Replace \"$1\" with \"$2\"? (y/n)"
                    while :
                    do
                        read -r -p "> " replace
                        if [[ "$replace" == "yes" ]] || [[ "$replace" == "y" ]]; then
                            sed -i "${line_numbers[$i]}s/$1/$2/" ${file_names[$i]}
                            echo "Done!"
                            break
                        elif [[ "$replace" == "no" ]] || [[ "$replace" == "n" ]]; then
                            break
                        elif [[ "$replace" == "exit" ]] || [[ "$replace" == "quit" ]]; then
                            echo "Aborting..."
                            break
                        else
                            echo "Please, write (y/yes) or (n/no)."
                            continue
                        fi
                    done
                    if [[ "$replace" == "exit" ]] || [[ "$replace" == "quit" ]]; then
                        break
                    fi
                    echo "---"
                    continue
                done
            fi
        else
            echo "error: a replacing string must be inserted."
            return 1
        fi
    else
        echo echo "error: a searching string must be inserted."
        return 1
    fi
}
