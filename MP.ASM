; Джапаров Эмирхан, БПИ197, 8-вариант.
; Программа для вычисления значения функции ARCSIN(X) для введенного
; аргумента x через разложение в степенной ряд. В программе использовалось разложение
; в степенной ряд по Маклорену: sum(i=2*k-1,(i-2)!!*x^i / ((i-1)!! * i))
; где i,k принадлежат множеству натуральных чисел без нуля, |x| <= 1.

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
        ; Вводимый пользователем аргумент вычисляемой функции
        x dq ?
        ; Квадрат введеного значения.
        sqrX dq ?
        ; Переменная, хранящая значение текущего члена ряда.
        term dq 0.0
        ; Переменная, в которой вычисляется значение следущего члена ряда.
        nextTerm dq ?
        ; Счетчик значения двойного факториала в числителе.
        factorialCounterAbove dd -1
        ; Счетчик значения двойного факториала в знаменателе.
        factorialCounterUnder dd 0
        ; Значение второго множителя(не факториала) в знаменателе.
        oldValueUnder dd 1
        ; Значение второго множителя(не факториала) в знаменателе.
        currentValueUnder dd 3
        ; Счетчик итерации.
        iterationCounter dd 1
        ; Переменная, хранящая сумму ряда под конец текущей итерации.
        sum dq 0.0
        ; Переменная, хранящая сумму ряда на предыдущей итерации.
        oldSum dq 0.0
        ; точность полученного экспериментального значения.
        partOfSum dq 0.0
        ; Переменная, хранящая точность, с которыми производятся вычисления.
        epsilon dq 0.0005
        ; Супремум ОДЗ ARCSIN(X).
        upperBorder dq 1.0
        ; Инфинум ОДЗ ARCSIN(X).
        bottomBorder dq -1.0
        zero dq 0.0
        ; Для дальнейшего инвертирования знака в случае отрицательного аргумента.
        negative dq -1.0
        ; Флаг для проверки того, какой знак у аргумента: 1 - "минус", 0 - "плюс"
        flagNegativeArg dd 0
        incorrectInput db 'Incorrect argument!'
        ; приближенное значение Pi/2.
        PiDiv2 dq 1.57079633
section '.code' code readable executable
        start:
                ; Вводится аргумент функции.
                invoke printf, enterStr
                invoke scanf, numberStr, x

                ; Проверка на то входит ли аргумент в ОДЗ функции.
                fld [x]
                fld [upperBorder]
                fcompp
                fstsw ax
                sahf
                jb emergencyInput

                ; Проверка на то, входит ли аргумент в ОДЗ функции.
                fld [x]
                fld [bottomBorder]
                fcompp
                fstsw ax
                sahf
                ja emergencyInput

                ; Проверка на то, ввелся ли супремум из множества ДЗ.
                fld [x]
                fld [upperBorder]
                fcompp
                fstsw ax
                sahf
                je upperBorderCase

                ; Проверка на то, ввелся ли инфинум из множества ДЗ.
                fld [x]
                fld [bottomBorder]
                fcompp
                fstsw ax
                sahf
                je bottomBorderCase

                ; Проверка на то, какой знак у аргумента.
                fld [x]
                fld [zero]
                fcompp
                fstsw ax
                sahf
                ja reverseArgument

                ; Сохраняем значение суммы первой итерации.
                CopyFloat sum, x
                ; Сохраняется значение первого члена ряда.
                CopyFloat term, x
                ; Выставляются определенные значения управляющим регистрам сопроцессора.
                FINIT
                ; Высчитывается квадрат значения, введенного пользователем,
                ; так как переменная x в каждом члене ряда увеличивается
                ; в x^2 раз.
                fld [x]
                fmul [x]
                fstp [sqrX]

        mainLoop:

                ; Выводим промежуточный результат.
                invoke printf, iterationStr,[iterationCounter]
                PrintFloat currentValuesStr, term, sum
                Inc iterationCounter

                ; Вычисляем следующий член:
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
                ; аргументы двойных факториалов в числителе и в знаменателе увеличиваются на 2 на каждой итерации
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

                ; Сохраняется предыдущее значение суммы степенного ряда.
                CopyFloat oldSum, sum

                ; Прибавляется к сумме вычисленный член. sum += nextTerm.
                fld [sum]
                fadd [nextTerm]
                fstp [sum]

                ; Доля дельты текущей и предыдущей сумм от текущей.
                ; *дельта = текущая сумма ряда - предыдущая сумма ряда.
                fld [partOfSum]
                fadd [sum]
                fsub [oldSum]
                fdiv [sum]
                fstp [partOfSum]

                ; Проверка на то, с какой точностью получилась текущая сумма ряда.
                ; Если отношение дельты текущей суммы ряда и предыдущей к текущей
                ; сумме меньше или равна заданной по условию точности, то алгоритм
                ; подсчета сумма останавливается.
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
                ; срабатывает если st(1) > st(0)
                jbe outputResult
                ; term = nextTerm;
                CopyFloat term, nextTerm
                jmp mainLoop

        outputResult:
                ; Проверка на то, с каким знаком вводился аргумент.
                ; Если минус, то осуществляется переход к выводу отрицательного
                ; значения функции.
                cmp [flagNegativeArg], 1
                je outputNegativeResult
                ; Выводим результат последней итерации и итоговый результат.
                invoke printf, iterationStr,[iterationCounter]
                PrintFloat currentValuesStr, nextTerm, sum
                PrintFloat resultStr, x, sum
                jmp finish
        ; Вывод значения функции от отрицательного аргумента.
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
                ; инвертируется знак введенного отрицательного аргумента.
                fld [x]
                fmul [negative]
                fstp [x]
                mov [flagNegativeArg],1
                CopyFloat sum, x
                ; Сохраняется значение первого члена ряда.
                CopyFloat term, x
                ; Выставляются определенные значения управляющим регистрам сопроцессора.
                FINIT
                ; Высчитывается квадрат значения, введенного пользователем,
                ; так как переменная x в каждом члене ряда увеличивается
                ; в x^2 раз
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
