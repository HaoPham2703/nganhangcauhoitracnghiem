#!/bin/bash

# Định nghĩa file câu hỏi
FILE_CAUHOI="Cauhoi.txt"

# Tìm số thứ tự lớn nhất
max_question=$(grep -o "^[0-9]\+" "$FILE_CAUHOI" | sort -nr | head -n 1)

# Hiển thị kết quả
echo "Số câu lớn nhất trong file là: $max_question"

