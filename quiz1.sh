#!/bin/bash

# Định nghĩa các file dữ liệu
FILE_CAUHOI="Cauhoi.txt"
FILE_DAPAN="Dapan.txt"

# Hàm tìm số thứ tự câu hỏi lớn nhất
function tim_so_cau_lon_nhat() {
    if [[ -f "$FILE_CAUHOI" ]]; then
        max_question=$(awk -F. '/^[0-9]+\./ {print $1}' "$FILE_CAUHOI" | sort -nr | head -n 1)
        echo "Số thứ tự câu hỏi lớn nhất là: $max_question"
    else
        echo "Không tìm thấy file $FILE_CAUHOI"
    fi
}

# Hàm thêm câu hỏi
function them_cau_hoi() {
    if [[ -f "$FILE_CAUHOI" ]]; then
        max_question=$(awk -F. '/^[0-9]+\./ {print $1}' "$FILE_CAUHOI" | sort -n | tail -1)
        [[ -z "$max_question" ]] && max_question=0
    else
        max_question=0
    fi

    if [[ -f "$FILE_DAPAN" ]]; then
        max_num_dapan=$(awk -F- '{print $1}' "$FILE_DAPAN" | tr -d ' ' | sort -n | tail -1)
        [[ -z "$max_num_dapan" ]] && max_num_dapan=0
    else
        max_num_dapan=0
    fi

    max_num=$((max_question > max_num_dapan ? max_question : max_num_dapan))
    new_num=$((max_num + 1))

    echo "Nhập câu hỏi:"
    read cauhoi
    echo "Nhập đáp án a:"
    read dapan_a
    echo "Nhập đáp án b:"
    read dapan_b
    echo "Nhập đáp án c:"
    read dapan_c
    echo "Nhập đáp án d:"
    read dapan_d
    echo "Nhập đáp án đúng (a, b, c, d):"
    read dap_an

    while [[ ! "$dap_an" =~ ^[a-dA-D]$ ]]; do
        echo "Chỉ được nhập a, b, c, hoặc d. Nhập lại:"
        read dap_an
    done

    echo "$new_num. $cauhoi" >> "$FILE_CAUHOI"
    echo "a. $dapan_a" >> "$FILE_CAUHOI"
    echo "b. $dapan_b" >> "$FILE_CAUHOI"
    echo "c. $dapan_c" >> "$FILE_CAUHOI"
    echo "d. $dapan_d" >> "$FILE_CAUHOI"
    echo "Câu hỏi đã được thêm vào $FILE_CAUHOI"

    echo "${new_num}-${dap_an}" >> "$FILE_DAPAN"
    echo "Đáp án đã được thêm vào $FILE_DAPAN"
}

# Hàm xuất đề thi trắc nghiệm ngẫu nhiên
function xuat_de_thi() {
    echo -e "Nhập số lượng câu hỏi cần làm:"
    read so_cau

    # Lấy ngẫu nhiên số lượng câu hỏi yêu cầu
    selected_array=($(awk '/^[0-9]+\./ {print NR}' "$FILE_CAUHOI" | shuf | head -n "$so_cau"))

    declare -A user_answers

    total=${#selected_array[@]}
    index=0

    while [[ $index -lt $total ]]; do
        line_num=${selected_array[$index]}
        echo -e "\n>> Đang làm câu $(($index + 1))/$total:"
        sed -n "$line_num,+4p" "$FILE_CAUHOI"
        while true; do
            echo -e "\nNhập câu trả lời của bạn (a, b, c, d):"
            read answer
            if [[ "$answer" == "back" ]]; then
                if [[ $index -gt 0 ]]; then
                    ((index--))
                    unset user_answers[${selected_array[$((index+1))]}]
                    echo ">> Đã quay lại câu trước."
                    break
                else
                    echo ">> Đang ở câu đầu tiên, không thể quay lại."
                fi
            elif [[ "$answer" =~ ^[a-dA-D]$ ]]; then
                echo "Bạn vừa chọn: $answer. Xác nhận? (y/n)"
                read confirm
                if [[ "$confirm" =~ ^[yY]$ ]]; then
                    user_answers[$line_num]=$(echo "$answer" | tr 'A-Z' 'a-z')
                    ((index++))
                    break
                fi
            else
                echo "Chỉ được nhập a, b, c, d hoặc 'back'!"
            fi
        done
    done

    # Hiển thị các câu trả lời đã chọn
    echo -e "\n=== Tóm tắt câu trả lời của bạn ==="
    for ((i = 0; i < $total; i++)); do
        line_num=${selected_array[$i]}
        so_thu_tu=$(sed -n "${line_num}p" "$FILE_CAUHOI" | awk -F. '{print $1}')
        echo "Câu $so_thu_tu: ${user_answers[$line_num]}"
    done

    echo -e "\nBạn có muốn nộp bài không? (y/n)"
    read nopbai
    if [[ "$nopbai" =~ ^[nN]$ ]]; then
        echo "Nhập các số thứ tự câu hỏi bạn muốn làm lại: "
        read -a sua_cau

        for cau_sua in "${sua_cau[@]}"; do
            # Tìm lại dòng tương ứng
            for ((i = 0; i < $total; i++)); do
                line_num=${selected_array[$i]}
                so_thu_tu=$(sed -n "${line_num}p" "$FILE_CAUHOI" | awk -F. '{print $1}')
                if [[ "$so_thu_tu" == "$cau_sua" ]]; then
                    echo -e "\n>> Sửa lại câu $so_thu_tu:"
                    sed -n "$line_num,+4p" "$FILE_CAUHOI"
                    while true; do
                        echo -e "\nNhập lại câu trả lời của bạn (a, b, c, d):"
                        read new_answer
                        if [[ "$new_answer" =~ ^[a-dA-D]$ ]]; then
                            echo "Bạn chọn: $new_answer. Xác nhận? (y/n)"
                            read confirm
                            if [[ "$confirm" =~ ^[yY]$ ]]; then
                                user_answers[$line_num]=$(echo "$new_answer" | tr 'A-Z' 'a-z')
                                break
                            fi
                        else
                            echo "Chỉ được nhập a, b, c, d!"
                        fi
                    done
                fi
            done
        done
    fi

    # Chấm điểm
    echo -e "\n=== Kết quả chấm điểm ==="
    diem=0
    tong_cau=0

    declare -A dapan_dung
    while IFS="-" read -r so_thu_tu dap_an; do
        dapan_dung[$so_thu_tu]=$(echo "$dap_an" | tr -d ' ' | tr 'A-Z' 'a-z')
    done < "$FILE_DAPAN"

    for line_num in "${selected_array[@]}"; do
        so_thu_tu=$(sed -n "${line_num}p" "$FILE_CAUHOI" | awk -F. '{print $1}')
        if [[ "${user_answers[$line_num]}" == "${dapan_dung[$so_thu_tu]}" ]]; then
            ((diem++))
        else
            echo "Câu $so_thu_tu sai. Đáp án đúng: ${dapan_dung[$so_thu_tu]}"
        fi
        ((tong_cau++))
    done

    echo "Bạn đạt: $diem/$tong_cau điểm"
}
# Hàm xuất đề thi có câu hỏi mới nhất
function xuat_de_thi_co_cau_moi() {
    echo -e "Nhập số lượng câu hỏi cần làm (bao gồm câu mới nhất):"
    read so_cau

    max_question=$(awk -F. '/^[0-9]+\./ {print $1}' "$FILE_CAUHOI" | sort -nr | head -n 1)
    max_question_line=$(grep -n "^$max_question\." "$FILE_CAUHOI" | cut -d: -f1)
    selected_questions=$(awk '/^[0-9]+\./ {print NR}' "$FILE_CAUHOI" | grep -v "^$max_question_line$" | shuf | head -n $((so_cau - 1)))
    selected_questions="$max_question_line $selected_questions"

    declare -A user_answers
    selected_array=($selected_questions)
    total=${#selected_array[@]}
    index=0

    while [[ $index -lt $total ]]; do
        line_num=${selected_array[$index]}
        sed -n "$line_num,+4p" "$FILE_CAUHOI"

        while true; do
            echo -e "\nNhập câu trả lời của bạn (a, b, c, d) hoặc gõ 'back' để quay lại câu trước:"
            read answer

            if [[ "$answer" == "back" ]]; then
                if [[ $index -gt 0 ]]; then
                    ((index--))
                    unset user_answers[${selected_array[$((index+1))]}]
                    echo ">> Đã quay lại câu trước."
                    break
                else
                    echo ">> Bạn đang ở câu đầu tiên."
                    continue
                fi
            elif [[ "$answer" =~ ^[a-dA-D]$ ]]; then
                echo "Bạn vừa chọn: $answer. Xác nhận? (y/n)"
                read confirm
                if [[ "$confirm" =~ ^[yY]$ ]]; then
                    user_answers[$line_num]=$(echo "$answer" | tr 'A-Z' 'a-z')
                    ((index++))
                    break
                fi
            else
                echo "Chỉ được nhập a, b, c, d hoặc 'back'!"
            fi
        done
        echo "--------------------------------------"
    done

    echo -e "\nKết quả chấm điểm:"
    diem=0
    tong_cau=0

    declare -A dapan_dung
    while IFS="-" read -r so_thu_tu dap_an; do
        dapan_dung[$so_thu_tu]=$(echo "$dap_an" | tr -d ' ' | tr 'A-Z' 'a-z')
    done < "$FILE_DAPAN"

    for line_num in ${selected_array[@]}; do
        so_thu_tu=$(sed -n "${line_num}p" "$FILE_CAUHOI" | awk -F. '{print $1}')
        if [[ "${user_answers[$line_num]}" == "${dapan_dung[$so_thu_tu]}" ]]; then
            ((diem++))
        else
            echo "Câu $so_thu_tu sai. Đáp án đúng: ${dapan_dung[$so_thu_tu]}"
        fi
        ((tong_cau++))
    done

    echo "Bạn đạt: $diem/$tong_cau điểm"
}

# Menu
function menu() {
    echo "Chọn chức năng:"
    echo "1. Thêm câu hỏi"
    echo "2. Xuất đề thi trắc nghiệm ngẫu nhiên"
    echo "3. Tìm số câu hỏi lớn nhất"
    echo "4. Thoát"
    echo "5. Xuất đề thi có câu hỏi mới nhất"
    read -p "Lựa chọn của bạn: " choice
    case $choice in
        1) them_cau_hoi ;;
        2) xuat_de_thi ;;
        3) tim_so_cau_lon_nhat ;;
        4) exit 0 ;;
        5) xuat_de_thi_co_cau_moi ;;
        *) echo "Lựa chọn không hợp lệ!" ;;
    esac
}

# Chạy chương trình
while true; do
    menu
done

