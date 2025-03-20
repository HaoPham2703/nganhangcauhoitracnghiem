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

# Hàm thêm câu hỏi vào file Cauhoi.txt
function them_cau_hoi() {
    # Lấy số thứ tự câu hỏi lớn nhất hiện tại
    if [[ -f "$FILE_CAUHOI" ]]; then
        max_question=$(awk -F. '/^[0-9]+\./ {print $1}' "$FILE_CAUHOI" | sort -n | tail -1)
        if [[ -z "$max_question" ]]; then
            max_question=0
        fi
    else
        max_question=0
    fi

    if [[ -f "$FILE_DAPAN" ]]; then
        max_num_dapan=$(awk -F- '{print $1}' "$FILE_DAPAN" | tr -d ' ' | sort -n | tail -1)
        if [[ -z "$max_num_dapan" ]]; then
            max_num_dapan=0
        fi
    else
        max_num_dapan=0
    fi

    # Lấy số thứ tự lớn nhất giữa hai file
    max_num=$((max_question > max_num_dapan ? max_question : max_num_dapan))

    # Tăng số thứ tự câu hỏi lên 1
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

    # Thêm câu hỏi vào file Cauhoi.txt
    echo "$new_num. $cauhoi" >> "$FILE_CAUHOI"
    echo "a. $dapan_a" >> "$FILE_CAUHOI"
    echo "b. $dapan_b" >> "$FILE_CAUHOI"
    echo "c. $dapan_c" >> "$FILE_CAUHOI"
    echo "d. $dapan_d" >> "$FILE_CAUHOI"
    echo "Câu hỏi đã được thêm vào $FILE_CAUHOI"

    # Thêm đáp án vào file Dapan.txt
    echo "$new_num - $dap_an" >> "$FILE_DAPAN"
    echo "Đáp án đã được thêm vào $FILE_DAPAN"
}

# Hàm xuất đề thi ngẫu nhiên và hiển thị từng câu một
function xuat_de_thi() {
    echo -e "Nhập số lượng câu hỏi cần làm:"
    read so_cau

    # Lấy ngẫu nhiên số lượng câu hỏi yêu cầu
    selected_questions=$(awk '/^[0-9]+\./ {print NR}' "$FILE_CAUHOI" | shuf | head -n "$so_cau")

    declare -A user_answers

    for line_num in $selected_questions; do
        # Hiển thị câu hỏi và 4 đáp án
        sed -n "$line_num,+4p" "$FILE_CAUHOI"
        echo -e "\nNhập câu trả lời của bạn (a, b, c, d): "
        read answer
        user_answers[$line_num]=$(echo "$answer" | tr 'A-Z' 'a-z')  # Chuyển input thành chữ thường
        echo "--------------------------------------"
    done

    echo -e "\nKết quả chấm điểm:"
    diem=0
    tong_cau=0

    declare -A dapan_dung
    while IFS="-" read -r so_thu_tu dap_an; do
        dapan_dung[$so_thu_tu]=$(echo "$dap_an" | tr -d ' ' | tr 'A-Z' 'a-z')  # Chuyển đáp án đúng thành chữ thường
    done < "$FILE_DAPAN"

    for line_num in $selected_questions; do
        # Lấy số thứ tự câu hỏi từ dòng đầu tiên
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

# Hàm hiển thị menu
function menu() {
    echo "Chọn chức năng:"
    echo "1. Thêm câu hỏi"
    echo "2. Xuất đề thi trắc nghiệm ngẫu nhiên"
    echo "3. Tìm số câu hỏi lớn nhất"
    echo "4. Thoát"
    read -p "Lựa chọn của bạn: " choice
    case $choice in
        1)
            them_cau_hoi
            ;;
        2)
            xuat_de_thi
            ;;
        3)
            tim_so_cau_lon_nhat
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Lựa chọn không hợp lệ!"
            ;;
    esac
}

# Vòng lặp chính của chương trình
while true; do
    menu
done

