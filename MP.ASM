; �������� �������, ���197, 8-�������.
; ��������� ��� ���������� �������� ������� ARCSIN(X) ��� ����������
; ��������� x ����� ���������� � ��������� ���. � ��������� �������������� ����������
; � ��������� ��� �� ���������: sum(i=2*k-1,(i-2)!!*x^i / ((i-1)!! * i))
; ��� i,k ����������� ��������� ����������� ����� ��� ����, |x| <= 1.

format PE Console
entry start

include 'win32a.inc'
include 'MPmacros.inc'

section '.data' data readable writable

        enterStr db 'The program shows vaue of function ARCSIN(X) in a specifically argument x. Enter x (-1 <= x <= 1)', 10, 0
        numberStr db '%lf', 0
        debugStr db '%lf', 10, 0
        iterationStr db 'Iteration %d: ', 0
        currentValuesStr db 'current term = %lf, sum = %lf', 10, 0
        resultStr db 'Result: ARCSIN(%lf) = %lf', 10, 0
        ; �������� ������������� �������� ����������� �������
        x dq ?
        ; ������� ��������� ��������.
        sqrX dq ?
        ; ����������, �������� �������� �������� ����� ����.
        term dq 0.0
        ; ����������, � ������� ����������� �������� ��������� ����� ����.
        nextTerm dq ?
        ; ������� �������� �������� ���������� � ���������.
        factorialCounterAbove dd -1
        ; ������� �������� �������� ���������� � �����������.
        factorialCounterUnder dd 0
        ; �������� ������� ���������(�� ����������) � �����������.
        oldValueUnder dd 1
        ; �������� ������� ���������(�� ����������) � �����������.
        currentValueUnder dd 3
        ; ������� ��������.
        iterationCounter dd 1
        ; ����������, �������� ����� ���� ��� ����� ������� ��������.
        sum dq 0.0
        ; ����������, �������� ����� ���� �� ���������� ��������.
        oldSum dq 0.0
        ; �������� ����������� ������������������ ��������.
        partOfSum dq 0.0
        ; ����������, �������� ��������, � �������� ������������ ����������.
        epsilon dq 0.0005
        ; �������� ��� ARCSIN(X).
        upperBorder dq 1.0
        ; ������� ��� ARCSIN(X).
        bottomBorder dq -1.0
        zero dq 0.0
        ; ��� ����������� �������������� ����� � ������ �������������� ���������.
        negative dq -1.0
        ; ���� ��� �������� ����, ����� ���� � ���������: 1 - "�����", 0 - "����"
        flagNegativeArg dd 0
        incorrectInput db 'Incorrect argument!'
        ; ������������ �������� Pi/2.
        PiDiv2 dq 1.57079633
section '.code' code readable executable
        start:
                ; �������� �������� �������.
                invoke printf, enterStr
                invoke scanf, numberStr, x

                ; �������� �� �� ������ �� �������� � ��� �������.
                fld [x]
                fld [upperBorder]
                fcompp
                fstsw ax
                sahf
                jb emergencyInput

                ; �������� �� ��, ������ �� �������� � ��� �������.
                fld [x]
                fld [bottomBorder]
                fcompp
                fstsw ax
                sahf
                ja emergencyInput

                ; �������� �� ��, ������ �� �������� �� ��������� ��.
                fld [x]
                fld [upperBorder]
                fcompp
                fstsw ax
                sahf
                je upperBorderCase

                ; �������� �� ��, ������ �� ������� �� ��������� ��.
                fld [x]
                fld [bottomBorder]
                fcompp
                fstsw ax
                sahf
                je bottomBorderCase

                ; �������� �� ��, ����� ���� � ���������.
                fld [x]
                fld [zero]
                fcompp
                fstsw ax
                sahf
                ja reverseArgument

                ; ��������� �������� ����� ������ ��������.
                CopyFloat sum, x
                ; ����������� �������� ������� ����� ����.
                CopyFloat term, x
                ; ������������ ������������ �������� ����������� ��������� ������������.
                FINIT
                ; ������������� ������� ��������, ���������� �������������,
                ; ��� ��� ���������� x � ������ ����� ���� �������������
                ; � x^2 ���.
                fld [x]
                fmul [x]
                fstp [sqrX]

        mainLoop:

                ; ������� ������������� ���������.
                invoke printf, iterationStr,[iterationCounter]
                PrintFloat currentValuesStr, term, sum
                Inc iterationCounter

                ; ��������� ��������� ����:
                ; nextTerm = term; nextTerm *= x^2;
                fld [term]
                fmul [sqrX]

                ; nextMemb *=  prevValueUnder
                fmul [oldValueUnder]
                Inc oldValueUnder
                Inc oldValueUnder
                ; nextMemb /= currentValueUnder
                fdiv [currentValueUnder]
                Inc currentValueUnder
                Inc currentValueUnder
                ; ��������� ������� ����������� � ��������� � � ����������� ������������� �� 2 �� ������ ��������
                ; facAbove += 2
                Inc factorialCounterAbove
                Inc factorialCounterAbove
                ; nextMemb *= facAbove
                fmul [factorialCounterAbove]
                ; facUnder += 2
                Inc factorialCounterUnder
                Inc factorialCounterUnder
                ; nextMemb /= facAbove
                fdiv [factorialCounterUnder]
                fstp [nextTerm]

                ; ����������� ���������� �������� ����� ���������� ����.
                CopyFloat oldSum, sum

                ; ������������ � ����� ����������� ����. sum += nextTerm.
                fld [sum]
                fadd [nextTerm]
                fstp [sum]

                ; ���� ������ ������� � ���������� ���� �� �������.
                ; *������ = ������� ����� ���� - ���������� ����� ����.
                fld [partOfSum]
                fadd [sum]
                fsub [oldSum]
                fdiv [sum]
                fstp [partOfSum]

                ; �������� �� ��, � ����� ��������� ���������� ������� ����� ����.
                ; ���� ��������� ������ ������� ����� ���� � ���������� � �������
                ; ����� ������ ��� ����� �������� �� ������� ��������, �� ��������
                ; �������� ����� ���������������.
                fld [sum]
                fld [oldSum]
                fcompp
                fstsw ax
                sahf
                je outputResult
                fld [epsilon]
                fld [partOfSum]
                fcompp
                fstsw ax
                sahf
                ; ����������� ���� st(1) > st(0)
                jbe outputResult
                ; term = nextTerm;
                CopyFloat term, nextTerm
                jmp mainLoop

        outputResult:
                ; �������� �� ��, � ����� ������ �������� ��������.
                ; ���� �����, �� �������������� ������� � ������ ��������������
                ; �������� �������.
                cmp [flagNegativeArg], 1
                je outputNegativeResult
                ; ������� ��������� ��������� �������� � �������� ���������.
                invoke printf, iterationStr,[iterationCounter]
                PrintFloat currentValuesStr, nextTerm, sum
                PrintFloat resultStr, x, sum
                jmp finish
        ; ����� �������� ������� �� �������������� ���������.
        outputNegativeResult:
                fld [sum]
                fmul [negative]
                fstp [sum]
                invoke printf, iterationStr,[iterationCounter]
                PrintFloat currentValuesStr, nextTerm, sum
                PrintFloat resultStr, x, sum
                jmp finish
        finish:
                push 0
                invoke getch
                call ExitProcess
        upperBorderCase:
                CopyFloat sum, PiDiv2
                PrintFloat resultStr, x, sum
                jmp finish

        bottomBorderCase:
                fld [sum]
                fsub [PiDiv2]
                fstp [sum]
                PrintFloat resultStr, x, sum
                jmp finish
        emergencyInput:
                invoke printf, incorrectInput
                invoke getch
                push 0
                call ExitProcess

        reverseArgument:
                ; ������������� ���� ���������� �������������� ���������.
                fld [x]
                fmul [negative]
                fstp [x]
                mov [flagNegativeArg],1
                CopyFloat sum, x
                ; ����������� �������� ������� ����� ����.
                CopyFloat term, x
                ; ������������ ������������ �������� ����������� ��������� ������������.
                FINIT
                ; ������������� ������� ��������, ���������� �������������,
                ; ��� ��� ���������� x � ������ ����� ���� �������������
                ; � x^2 ���
                fld [x]
                fmul [x]
                fstp [sqrX]
                jmp mainLoop
section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess',\
               GetProcessHeap, 'GetProcessHeap',\
               HeapAlloc, 'HeapAlloc'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'
