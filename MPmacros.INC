; ������ ��� ������ ����� � ��������� �������.
macro PrintFloat string, [args] {
 reverse
  push dword[args + 4]
  push dword[args]
 common
  push string
  call [printf]
}

; ������, ���������������� �������� ����������.
macro Inc value {
 mov ecx, [value]
 inc ecx
 mov [value], ecx
}

; ������, ���������� �������� ������ ����� � ��������� ������� � ������.
macro CopyFloat to, from {
 mov eax, dword[from]
 mov ebx, dword[from + 4]
 mov dword[to], eax
 mov dword[to + 4], ebx
}
