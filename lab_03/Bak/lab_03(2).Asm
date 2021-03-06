.386
.model flat,STDCALL
option casemap :none  ;case sensitive

include lab_03.inc

.code
Begin:
	call main
	
invoke ExitProcess,NULL

Mem_Alloc PROC Buf_Size:DWORD
add Buf_Size,4    ; �������� ����� �� 4 ����� ������
invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,Buf_Size   ; �������� ������� � ��������� �����
push eax     ; �������� ����� ������ ��������� ������ � ����
invoke GlobalLock,eax ;������� � ��������
pop [eax]    ;��������� � ����� ��������  � �������� � ����� 4 ����� ��������� ������, 
;�� �������� � ���� ������ ������� ������
;�������� Buf_Size ���� ������������� �� �����
add eax,4    ;������� �������� ������� ������ �� 4 �����, ������� ����� 4 ����� 
        ;����� ��������� ������ ������
    ret    ; �������� � ���������
Mem_Alloc endp

; ������ ��������� �������� �����.
Mem_Free PROC DATA:DWORD
mov eax,DATA    ;������� �������� ��������� ��������� � ������ eax, ���������� � 
        ;��������� (������) ������ ������ ( ������� + 4 �����)
sub eax,4    ;���'�����, �� ������ 4 ����� ������  - �� ����� ������
mov eax,[eax]     ;������ �������� ������ �������� �� �����, �� ������ � ������ eax
push eax        ;�������� ���� � ����
push eax
call GlobalUnlock    ;������������ ���'��� (��� ������� Buf_Size+4)
call GlobalFree    ;������� �������� ��� � �����, ��������� ��������� ��� ���������, �� ��������� ���������� 
;call (������� ������ ������)
    ret    ;����� � ���������
Mem_Free endp

Upper_Case proc
	mov esi, buf_
	dec esi
	
start:
	inc esi
	mov al, [esi]
	cmp al, 0
	jz exit
	cmp al, 'a'
	jnae start
	cmp al, 'z'
	jnbe start
	jnae upper
upper:
	sub al, 32
	mov [esi], al
	jmp start
exit:
	ret
Upper_Case endp


main proc
	LOCAL handler:DWORD
	LOCAL handle:DWORD
	
	invoke Mem_Alloc, 1024
	mov buf_, eax
	push eax
	invoke Mem_Alloc, sizeof(OPENFILENAME)
	mov handle, eax
	assume eax: ptr OPENFILENAME
	mov [eax].lStructSize, sizeof(OPENFILENAME)
	mov [eax].lpstrFile, offset file_name
	mov [eax].nMaxFile, 256
	mov [eax].lpstrInitialDir, offset dir
	mov [eax].lpstrTitle, NULL
	
	
	invoke GetOpenFileName, eax
	pop eax
	invoke CreateFile, addr file_name, GENERIC_READ, FILE_SHARE_WRITE or FILE_SHARE_READ, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	mov handler, eax
	invoke ReadFile, handler, buf_, 1024, addr size_, NULL
	invoke MessageBox, 0, buf_, addr title_, MB_OK
    invoke Upper_Case
	invoke MessageBox, 0, buf_, addr title_, MB_OK
	invoke CloseHandle, handler
	invoke GetTempFileName, addr dir, addr rand_prefix, 0, addr random_name
	invoke CreateFile, addr random_name, GENERIC_WRITE, FILE_SHARE_WRITE or FILE_SHARE_READ, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	mov handler, eax
	invoke WriteFile, handler, buf_, 1024, 0, 0
	invoke CloseHandle, handler
	invoke Mem_Free, buf_
	
	ret

main endp

end Begin
