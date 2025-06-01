DATAS SEGMENT
    N DB ?
    TMPN DB ?
    TOP_LABEL DB "Hanio Moving Process(1-20 Layers)",0DH,0AH,24H
    TIP DB "Input Number(Press the Esc to Exit): ",24H
    TO DB '--->$'
    ZA DW 0,30 DUP(?) ;A����
    ZB DW 0,30 DUP(?) ;B����
    ZC DW 0,30 DUP(?) ;C����
    ;�ƶ������ӵ�������յ�����
    X1A DW 0
    X1C DW 0
    X2A DW 0
    X2C DW 0
    YA DW 0
    YC DW 0
    MOVE_LEFT DB 0
    LEFT DW 0 ;��ʼ
    RIGHT DW 0 ;�յ�
    CA DW 'A' ;A��Ӧ����
    CB DW 'B' ;B��Ӧ����
    CC DW 'C' ;C��Ӧ����
    MOVER DW 0 ;ƫ��λ��
    FLAG DB 0
    LEN DW 0 ;�ƶ����ӳ���
    COUNT DW 0 ;�ƶ�����
    BUFF_COUNT DB 0,0,0,0,0,0,0
    EMPTY DB "      ",24H
    TIP0 DB "Beyond range, please re-enter",0DH,0AH,24H
    TIP1 DB "Error input, please re-enter",0DH,0AH,24H
    TIP2 DB 0DH,0AH,"Press anykey to continue",24H
    TIP3 DB "Moving Numbers: $"
    TIP4 DB "Move: $"
DATAS ENDS
;-------------------------------------
STACKS SEGMENT
    DB 30H DUP(0)
TOP LABEL WORD
STACKS ENDS
;-------------------------------------
CODE SEGMENT
    ASSUME CS:CODE,DS:DATAS,SS:STACKS
START: 
    MOV AX,DATAS
    MOV DS,AX
    MOV AX,STACKS
    MOV SS,AX
    LEA SP,TOP
    MOV AH,00H
    MOV AL,04H
    INT 10H
    LEA DX,TOP_LABEL
    CALL DISPLAY_STR
AGAIN:
    LEA DX,TIP
    CALL DISPLAY_STR
    MOV DX,0
KEYIN:
    MOV AH,01H ;�������N
    INT 21H
    CMP AL,1BH
    JE EXIT
    CMP AL,0DH
    JE GO
    CMP AL,'0'
    JB ERR
    CMP AL,'9'
    JA ERR
    SUB AL,30H
    XCHG DL,AL
    MOV BL,10
    MUL BL
    ADD DL,AL
    JMP KEYIN
ERR:
	MOV AH,00H
    MOV AL,04H
    INT 10H
    LEA DX,TOP_LABEL
    CALL DISPLAY_STR
    LEA DX,TIP1
    CALL DISPLAY_STR
    JMP AGAIN
ERR0:
	MOV AH,00H
    MOV AL,04H
    INT 10H
    LEA DX,TOP_LABEL
    CALL DISPLAY_STR
    LEA DX,TIP0
    CALL DISPLAY_STR
    JMP AGAIN
;-------------------------------------
GO:
    CMP DL,20
    JA ERR0
    CMP DL,0
    JBE ERR0
    MOV BYTE PTR [N],DL ;���ռ����Nֵ
    CALL INIT ;��ʼ������
    CALL PRINT ;��ʼ��ͼƬ
    ;ͨ���޸�SLEEP�������ƶ��ٶ�
    CALL HANIO ;��ʼ�ƶ�
    JMP FINISH
;-------------------------------------
DISPLAY PROC NEAR
    MOV AH,2
    INT 21H
    RET
DISPLAY ENDP
;-------------------------------------
DISPLAY_STR PROC NEAR
    MOV AH,9
    INT 21H
    RET
DISPLAY_STR ENDP
;-------------------------------------
CLEAR_CH PROC NEAR
    PUSH AX
    PUSH BX
    PUSH DX
    ;���ù�굽Ҫ������ֵ�����
    MOV AH, 02H 
    MOV BH, 0
    MOV DH, 1
    MOV DL, 6
    INT 10H 
 
    ;����ո��ַ��Ը���ԭ�ַ�
    CALL INPUT_ENTER
    LEA DX,EMPTY
    CALL DISPLAY_STR
    
    ;�������ù��
    MOV AH, 02H 
    MOV BH, 0
    MOV DH, 1
    MOV DL, 6
    INT 10H
    POP DX
    POP BX
    POP AX
    RET
CLEAR_CH ENDP
;-------------------------------------
INPUT_ENTER PROC NEAR
    MOV DL,0DH
    CALL DISPLAY
    MOV DL,0AH
    CALL DISPLAY
    RET
INPUT_ENTER ENDP
;-------------------------------------
CLEAR_CH2 PROC NEAR
    PUSH AX
    PUSH BX
    PUSH DX
    ;���ù�굽��ʼ����
    MOV AH, 02H 
    MOV BH, 0
    MOV DH, 1
    MOV DL, 0
    INT 10H
    
    ;����ո��ַ��Ը���ԭ�ַ� 
    LEA DX,EMPTY
    CALL DISPLAY_STR
    LEA DX,EMPTY
    CALL DISPLAY_STR
    
    ;���ù�굽��ʼ����
    MOV AH, 02H 
    MOV BH, 0
    MOV DH, 1
    MOV DL, 0
    INT 10H 
   
    POP DX
    POP BX
    POP AX
    RET
CLEAR_CH2 ENDP
;-------------------------------------
INIT PROC NEAR
    ;��ʼ������A
    LEA SI,ZA
    MOV AL,N
    XOR AH,AH
    MOV [SI],AX
    MOV CL,N
    XOR CH,CH
init_ZA:
    ADD SI,2
    MOV [SI],CX
    LOOP init_ZA
    RET
INIT ENDP
;-------------------------------------
PRINT PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
;��ӡ����
    MOV AH,00H
    MOV AL,04H
    INT 10H
;-------------------------------------
;��ӡ��Ϣ
    LEA DX,TOP_LABEL
    CALL DISPLAY_STR
    LEA DX,TIP4
    CALL DISPLAY_STR
;-------------------------------------
;��ӡ����
    MOV SI,0
    MOV CX,50 ;X����
    MOV DX,50 ;Y����
    MOV BX,3
PRINT_Z:
    MOV AH,0CH
    MOV AL,06H
    INT 10H
    INC DX
    CMP DX,180
    JBE PRINT_Z
    ADD CX,105
    MOV DX,50
    DEC BX
    CMP BX,0
    JNE PRINT_Z
;-------------------------------------
;��ӡ������Ϣ
    MOV DH,23
    MOV DL,6
    MOV BH,0
    MOV AH,02H
    INT 10H
    MOV DL,'A'
    CALL DISPLAY
    MOV DL,19
    MOV AH,02H
    INT 10H
    MOV DL,'B'
    CALL DISPLAY
    MOV DL,32
    MOV AH,02H
    INT 10H
    MOV DL,'C'
    CALL DISPLAY
;-------------------------------------
;��ӡ����
    MOV DX,180
    LEA SI,ZA
    MOV BX,[SI]
    ADD SI,2
PRINT_A:
    CMP BX,0
    JE EXIT_A
    PUSH BX
    LODSW
    MOV BX,2
    MUL BL
    ;����������ʼ���յ�λ��
    MOV CX,50
    SUB CX,AX
    SUB CX,5
    MOV LEFT,CX
    MOV CX,50
    ADD CX,AX
    ADD CX,5
    MOV RIGHT,CX
    POP BX
    MOV CX,LEFT
    MOV AH,0CH
    MOV AL,05H
DRAW_A: ;��������
    INT 10H
    INC CX
    CMP CX,RIGHT
    JBE DRAW_A
    SUB DX,5 ;Y����������
    SUB BX,1
    CMP BX,0
    JNE PRINT_A
EXIT_A:
    MOV DX,180
    LEA SI,ZB
    MOV BX,[SI]
    ADD SI,2
PRINT_B:
    CMP BX,0
    JE EXIT_B
    PUSH BX
    LODSW
    MOV BX,2
    MUL BL
    ;����������ʼ���յ�λ��
    MOV CX,155
    SUB CX,AX 
    SUB CX,5
    MOV LEFT,CX
    MOV CX,155
    ADD CX,AX
    ADD CX,5
    MOV RIGHT,CX
    POP BX
    MOV CX,LEFT
    MOV AH,0CH
    MOV AL,05H
DRAW_B: ;��������
    INT 10H
    INC CX
    CMP CX,RIGHT
    JBE DRAW_B
    SUB DX,5 ;Y����������
    SUB BX,1
    CMP BX,0
    JNE PRINT_B
EXIT_B:
    MOV DX,180
    LEA SI,ZC
    MOV BX,[SI]
    ADD SI,2
PRINT_C:
    CMP BX,0
    JE EXIT_C
    PUSH BX
    LODSW
    MOV BX,2
    MUL BL
    ;����������ʼ���յ�λ��
    MOV CX,260
    SUB CX,AX 
    SUB CX,5
    MOV LEFT,CX
    MOV CX,260
    ADD CX,AX
    ADD CX,5
    MOV RIGHT,CX
    POP BX
    MOV CX,LEFT
    MOV AH,0CH
    MOV AL,05H
DRAW_C: ;��������
    INT 10H
    INC CX
    CMP CX,RIGHT
    JBE DRAW_C
    SUB DX,5 ;Y����������
    SUB BX,1
    CMP BX,0
    JNE PRINT_C
EXIT_C:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT ENDP
;-------------------------------------
SET_XYA PROC NEAR ;��ȡ�ƶ�������ʼ����
    CMP CA,'A'
    JNE LL1
    LEA SI,ZA
    MOV DX,[SI]
    PUSH DX
    ADD DX,DX
    ADD SI,DX
    MOV AX,[SI]
    MOV LEN,AX
    MOV BX,2
    MUL BL
    MOV CX,50
    SUB CX,AX 
    SUB CX,5
    MOV X1A,CX
    MOV CX,50
    ADD CX,AX
    ADD CX,5
    MOV X2A,CX
    JMP EXIT_XYA
LL1:
    CMP CA,'B'
    JNE LL2
    LEA SI,ZB
    MOV DX,[SI]
    PUSH DX
    ADD DX,DX
    ADD SI,DX
    MOV AX,[SI]
    MOV LEN,AX
    MOV BX,2
    MUL BL
    MOV CX,155
    SUB CX,AX 
    SUB CX,5
    MOV X1A,CX
    MOV CX,155
    ADD CX,AX
    ADD CX,5
    MOV X2A,CX
    JMP EXIT_XYA
LL2:
    LEA SI,ZC
	MOV DX,[SI]
	PUSH DX
    ADD DX,DX
    ADD SI,DX
    MOV AX,[SI]
    MOV LEN,AX
    MOV BX,2
    MUL BL
    MOV CX,260
    SUB CX,AX 
    SUB CX,5
    MOV X1A,CX
    MOV CX,260
    ADD CX,AX
    ADD CX,5
    MOV X2A,CX
EXIT_XYA:
    POP DX
    CMP DX,0
    JE FINI
    MOV CX,DX
    DEC CX
    MOV DX,180
GET_DXA:
    SUB DX,5
    LOOP GET_DXA
FINI:
    MOV YA,DX
    MOV AX,RIGHT
    RET
SET_XYA ENDP
;-------------------------------------
SET_XYC PROC NEAR ;��ȡ�ƶ������յ�����
    MOV AX,LEN
    MOV BX,2
    MUL BL
    CMP CC,'A'
    JNE LL1
    LEA SI,ZA
    MOV DX,[SI]
    MOV CX,50
    SUB CX,AX 
    SUB CX,5
    MOV X1C,CX
    MOV CX,50
    ADD CX,AX
    ADD CX,5
    MOV X2C,CX
    JMP EXIT_XYC
LL1:
    CMP CC,'B'
    JNE LL2
    LEA SI,ZB
    MOV DX,[SI]
    MOV CX,155
    SUB CX,AX 
    SUB CX,5
    MOV X1C,CX
    MOV CX,155
    ADD CX,AX
    ADD CX,5
    MOV X2C,CX
    JMP EXIT_XYC
LL2:
	LEA SI,ZC
    MOV DX,[SI]
    MOV CX,260
    SUB CX,AX 
    SUB CX,5
    MOV X1C,CX
    MOV CX,260
    ADD CX,AX
    ADD CX,5
    MOV X2C,CX
EXIT_XYC:
    MOV CX,DX
    MOV DX,180
GET_DXC:
    SUB DX,5
    LOOP GET_DXC
    MOV YC,DX
    RET
SET_XYC ENDP
;-------------------------------------
HANIO PROC NEAR
    XOR AH,AH
    MOV AL,N
    CMP AX,1
    JNZ DFS
    CALL SET_XYA
    CALL SET_XYC
    CALL CLEAR_CH
    MOV DX,CA
    CALL DISPLAY
    LEA DX,TO
    CALL DISPLAY_STR
    MOV DX,CC
    CALL DISPLAY
    CALL MOVE ;�ƶ�����
    INC COUNT
    CMP COUNT,0AH
    JB SKIP_COUNT
    MOV WORD PTR COUNT,0
    CALL SAVE_COUNT
SKIP_COUNT:
    JMP END_DFS
DFS:
    ;��ŵ���ݹ��㷨������B������C������
    ;�ƶ���ԭ��Ȼ������A������B������
    CALL CHG1
    CALL HANIO
    CALL REC1
    CALL SETN
    CALL HANIO
    CALL RECN
    CALL CHG2
    CALL HANIO
    CALL REC2
END_DFS:
    RET
HANIO ENDP
;-------------------------------------
;��ʮ���ƴ洢COUNT
SAVE_COUNT PROC NEAR
    MOV SI,5
    MOV CX,6
TEST_10:
    CMP BUFF_COUNT[SI],9
    JB ADD_1
    MOV BUFF_COUNT[SI],0
    DEC SI
    LOOP TEST_10
ADD_1:
    ADD BUFF_COUNT[SI],1
EXIT_TEST:
    RET
SAVE_COUNT ENDP
;-------------------------------------
CHG1 PROC NEAR
    PUSH AX
    PUSH BX
    MOV AX,CB
    MOV BX,CC
    MOV CC,AX
    MOV CB,BX
    DEC N
    POP BX
    POP AX
    RET
CHG1 ENDP
;-------------------------------------
REC1 PROC NEAR
    PUSH AX
    PUSH BX
    MOV AX,CB
    MOV BX,CC
    MOV CC,AX
    MOV CB,BX
    INC N
    POP BX
    POP AX
    RET
REC1 ENDP
;-------------------------------------
CHG2 PROC NEAR
    PUSH AX
    PUSH BX
    MOV AX,CA
    MOV BX,CB
    MOV CB,AX
    MOV CA,BX
    DEC N
    POP BX
    POP AX
    RET
CHG2 ENDP
;-------------------------------------
REC2 PROC NEAR
    PUSH AX
    PUSH BX
    MOV AX,CA
    MOV BX,CB
    MOV CB,AX
    MOV CA,BX
    INC N
    POP BX
    POP AX
    RET
REC2 ENDP
;-------------------------------------
SETN PROC NEAR
    PUSH AX
    XOR AH,AH
    MOV AL,N
    MOV TMPN,AL
    MOV N,1
    POP AX
    RET
SETN ENDP
;-------------------------------------
RECN PROC NEAR
    PUSH AX
    XOR AH,AH
    MOV AL,TMPN
    MOV N,AL
    POP AX
    RET
RECN ENDP
;-------------------------------------
MOVE PROC NEAR ;�ƶ�����A->C
    MOV AX,X1A
    MOV MOVE_LEFT,0
    CMP AX,X1C
    JB SKIP_LEFT
    MOV MOVE_LEFT,1
SKIP_LEFT:
    CALL MOVER_SHOW
;-------------------------------------
    MOV AX,CA
    MOV BX,CC
    ;Ѱ��CA��CC��Ӧ������
    CMP AX,'A'
    JNE CA_IS1
    LEA SI,ZA
    JMP EXIT_CA
CA_IS1:
    CMP AX,'B'
    JNE CA_IS2
    LEA SI,ZB
    JMP EXIT_CA
CA_IS2:
    LEA SI,ZC
EXIT_CA:
    CMP BX,'A'
    JNE CC_IS1
    LEA DI,ZA
    JMP EXIT_CC
CC_IS1:
    CMP BX,'B'
    JNE CC_IS2
    LEA DI,ZB
    JMP EXIT_CC
CC_IS2:
    LEA DI,ZC
EXIT_CC:
    MOV AX,[SI]
    MOV BX,[DI]
    ADD AX,AX
    ADD BX,BX
    ADD BX,2
    MOV MOVER,AX
    ADD SI,MOVER
    MOV DX,[SI]
    SUB SI,MOVER
    ADD DI,BX
    MOV [DI],DX
    SUB DI,BX
    MOV DX,[DI]
    INC DX
    MOV [DI],DX
    MOV DX,[SI]
    DEC DX
    MOV [SI],DX
    RET
MOVE ENDP
;-------------------------------------
MOVER_SHOW PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV FLAG,0
;��ӡ����
AGAIN_P:
    CALL XY_MOVE_SHOW
    CALL SLEEP
    MOV CX,X1A
    MOV DX,YA
    CMP CX,X1C
    JNE AGAIN_P
    CMP DX,YC
    JNE AGAIN_P
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
MOVER_SHOW ENDP
;-------------------------------------
XY_MOVE_SHOW PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
;���ԭ��������
    MOV CX,X1A
    MOV DX,YA
    MOV AH,0CH
    MOV AL,00H
CLAER_P:
    INT 10H
    INC CX
    CMP CX,X2A
    JBE CLAER_P
    CMP DX,50
    JB NEW_P
    MOV CX,X1A
    CMP CX,50
    JA REP1
    MOV CX,50
    JMP DRAW_REP
REP1:
    CMP CX,155
    JA REP2
    MOV CX,155
    JMP DRAW_REP
REP2:
    MOV CX,260
    JMP DRAW_REP
DRAW_REP:
    MOV AL,06H
    INT 10H
NEW_P:
;�����µ�����
    CMP YA,30
    JBE MOVE_X
    CMP FLAG,1
    JE MOVE_X
    DEC YA
    JMP EXIT_MOVE
MOVE_X:
    MOV FLAG,1
    MOV AX,X1A
    CMP AX,X1C
    JE MOVE_Y
    CMP MOVE_LEFT,1
    JE L1
    ADD X1A,2
    ADD X2A,2
L1:
    SUB X1A,1
    SUB X2A,1
    JMP EXIT_MOVE
MOVE_Y:
    MOV DX,YA
    CMP DX,YC
    JE EXIT_MOVE
    INC YA
EXIT_MOVE:
    MOV DX,YA
    MOV CX,X1A
    MOV AH,0CH
    MOV AL,05H
DRAW:
    INT 10H
    INC CX
    CMP CX,X2A
    JBE DRAW
    POP DX
    POP CX
    POP BX
    POP AX
    RET
XY_MOVE_SHOW ENDP
;-------------------------------------
OUTPUT_COUNT PROC NEAR
    MOV SI,6
    MOV AX,COUNT
    ADD BUFF_COUNT[SI],AL
    MOV SI,0
    MOV CX,7
TEST_0:
    CMP BUFF_COUNT[SI],0
    JNE OUTPUT
    DEC CX
    INC SI
    CMP CX,0
    JE OUTPUT_0
    JMP TEST_0
OUTPUT:
    MOV DL,BUFF_COUNT[SI]
    ADD DL,30H
    CALL DISPLAY
    INC SI
    LOOP OUTPUT
    JMP EXIT_OUTPUT
OUTPUT_0:
    MOV DL,'0'
    CALL DISPLAY
EXIT_OUTPUT:
    RET
OUTPUT_COUNT ENDP 
;-------------------------------------
SLEEP PROC NEAR ;��ʱ�ӳ���
    MOV BL,100
DELAY:
    MOV CX,100
WAITS:
    LOOP WAITS
    DEC BL
    JNZ DELAY
    RET
SLEEP ENDP
;-------------------------------------
FINISH:
    MOV CA,'A'
    MOV CB,'B'
    MOV CC,'C'
    MOV CX,30
    MOV SI,0
    MOV AX,0
INIT_ZC:
    MOV ZC[SI],AX
    ADD SI,2
    LOOP INIT_ZC
    
    CALL CLEAR_CH2
    LEA DX,TIP3
    CALL DISPLAY_STR
    CALL OUTPUT_COUNT
    MOV WORD PTR COUNT,0
    MOV CX,7
    MOV SI,0
SET_0:
    MOV BYTE PTR BUFF_COUNT[SI],0
    INC SI
    LOOP SET_0
    LEA DX,TIP2
    CALL DISPLAY_STR
    MOV AH,1
    INT 21H
    
    MOV AH,00H
    MOV AL,04H
    INT 10H
    LEA DX,TOP_LABEL
    CALL DISPLAY_STR
    JMP AGAIN
EXIT:
    MOV AH,4CH
    INT 21H 
CODE ENDS
    END START

