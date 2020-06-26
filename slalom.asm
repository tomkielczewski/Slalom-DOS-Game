;Program slalom.asm gra "Slalom Narciarski"
;w trybie rzeczywistym z u¿yciem systemu przerwan
;sterowanie klawiszami ",<"-lewo, ".>"-prawo i "x"-wyjscie
;po kolizji z bramka mozna zaczac nowa gre naciskajac klawisz "n"

.386
rozkazy SEGMENT use16
        ASSUME CS:rozkazy


snieg PROC
	push ax
	push bx
	push es


	mov	ax, 0B800h ; adres pamiêci ekranu
	mov es, ax

	; licznik to adres bie¿¹cy w pamiêci ekranu
	mov bx, 0
ptl:
	mov byte ptr es:[bx], ' '         ; Znak
	mov byte ptr es:[bx+1], 0f0h ; Kolor 

	add bx, 2 ; Nastêpny znak

	cmp bx, 4000
	jb ptl

	pop es
	pop bx
	pop ax

	ret
snieg ENDP


bum PROC
	push ax
	push bx
	push es


	mov	ax, 0B800h ; adres pamiêci ekranu
	mov es, ax

	; licznik to adres bie¿¹cy w pamiêci ekranu
	mov bx, 0
ptll:
	mov byte ptr es:[bx], ' '         ; Znak
	mov byte ptr es:[bx+1], 40h ; Kolor 

	add bx, 2 ; Nastêpny znak

	cmp bx, 4000
	jb ptll

	pop es
	pop bx
	pop ax

	ret
bum ENDP

barierka PROC
	push ax
	push bx
	push cx
	push dx
	push es

	mov bx, ax ;cs:licznik w  ax


	mov	ax, 0B800h ; adres pamiêci ekranu
	mov es, ax


	mov dx, bx ;kopia licznika w dx
	add dx,24
pntl:
	mov byte ptr es:[bx], '#'         ; Znak
	mov byte ptr es:[bx+1], 4fh ; Kolor czerwony z szarym napisem

	add bx, 2
	;sub dx, bx
	cmp bx, dx
	jb pntl


	pop es
	pop dx
	pop cx
	pop bx
	pop ax

	ret
barierka ENDP

barierka2 PROC
	push ax
	push bx
	push cx
	push dx
	push es

	xor cx,cx
	mov bx, ax ;cs:licznik w  ax


	mov	ax, 0B800h ; adres pamiêci ekranu
	mov es, ax


	mov dx, bx ;kopia licznika w dx
	add dx,24
pentl:
	mov byte ptr es:[bx], '#'         ; Znak
	mov byte ptr es:[bx+1], 4fh ; Kolor czerwony z szarym napisem

	add bx, 2
	;sub dx, bx
	cmp bx, dx
	jb pentl

	cmp cx,0
	jne skonczyl
;2.barierka:
	add bx,120
	mov dx,bx
	add dx,24
	jmp pentl

skonczyl:
	pop es
	pop dx
	pop cx
	pop bx
	pop ax

	ret
barierka2 ENDP

narciarz PROC
	push ax
	push bx
	push cx
	push dx
	push es


	wiersz dw 3200
	kolumna dw 76 ;srodek odjaæ 4

	mov cx, 0
	mov dx, 0

	mov ax, 0B800h ;adres pamiêci ekranu
	mov es, ax


	mov bx, cs:wiersz
	add bx, cs:kolumna	


	mov bx, 3284
	mov byte PTR es:[bx], '|' ; kod ASCII
	mov byte PTR es:[bx+1], 1eh

	mov bx, 3118
glowa:
	mov byte PTR es:[bx], ' ' ; kod ASCII
	mov byte PTR es:[bx+1], 0d0h
	add bx,2
	cmp bx,3124
	jb glowa
;tlow:

	
	mov bx, cs:wiersz
	add bx, cs:kolumna	


petla:
	;cmp bx, 3920
	;jae koniec
	; przes³anie do pamiêci ekranu kodu ASCII wyœwietlanego znaku
	; i kodu koloru: ¿ó³ty na niebieskim tle (do nastêpnego bajtu)
	mov byte PTR es:[bx], '|' ; kod ASCII
	mov byte PTR es:[bx+1], 1eh ; kolor ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; zwiêkszenie o 160 adresu bie¿¹cego w pamiêci ekranu czyli do nastêpnej linii
	add bx,160
	
	inc cx
	cmp cx,4
	ja nowa_linia
	cmp dx,4
	ja koniec
	jmp petla
nowa_linia:
	xor cx,cx

	inc dx

	mov bx, cs:wiersz
	add bx, cs:kolumna

	push dx
	shl dx,1
	add bx, dx
	pop dx

	cmp dx,4
	jae koniec
	jmp petla 


koniec:
	pop es
	pop dx
	pop cx
	pop bx
	pop ax

	ret
narciarz ENDP



obsluga_zegara PROC
; przechowanie u¿ywanych rejestrów
	push ax
	push bx
	push cx
	push dx
	push es

	call narciarz
	

	mov al, byte ptr cs:ticks ; Ile ticków pozosta³o?
	dec al                    ; Zmniejszamy o 1
	mov byte ptr cs:ticks, al ; Zapisujemy zmniejszone
	cmp al, 0                 ; Czy ju¿ 0 pozosta³o?
	jnz pomin_wywolanie       ; Jeœli jeszcze nie, kontynuuj

	mov byte ptr cs:ticks, 6 ; JU¯ TAK, reset ticks do 6 

	mov	ax, 0B800h ; adres pamiêci ekranu
	mov es, ax

	call snieg

	mov ax, cs:licznik	;przekzanie parametru pozycji
	call barierka

	add cs:licznik,160 ; pozycja ni¿ej


	in al, 60h
	
	cmp al, 33h	;klawisz:    ",<"
	jne prawo
;lewo:
	sub cs:licznik, 10
	jmp nic
prawo:
	cmp al, 34h	;klawisz: ".>"
	jne nic
	add cs:licznik, 10
nic:
	
	cmp cs:licznik,3040
	jb spr
;czy kolizja?
	cmp cs:licznik, 3094
	jb spr
	cmp cs:licznik, 3118
	ja spr
;kolizja:
	call bum
ded:	
	in al, 60h
	
	cmp al, 31h	;klawisz:    "n"
	je nowa
	cmp al, 2dh	;klawisz:    "x"
	je pomin_wywolanie
	jmp ded


spr:
	cmp cs:licznik,3520
	jb pomin_wywolanie
nowa:
	mov cs:licznik,68

pomin_wywolanie:
	pop es
	pop dx
	pop cx
	pop bx
	pop ax

	jmp dword PTR cs:wektor8

	; === DANE ===

	licznik dw 68
	wektor8 dd ?
	ticks   db 1 ; Every 18 ticks


obsluga_zegara ENDP



zacznij:
	mov al, 0 ; Strona 0 dla trybu tekstowego
	mov ah, 5
	int 10    ; WTF?

	mov ax, 0
	mov ds, ax ; Zerujemy Data Segment - DS wskazuje na pocz¹tek RAMu




;wektor8:

	; Do cs:wektor8 zapisujemy adres handlera przerwania BIOSu
	mov eax, ds:[32]
	mov cs:wektor8, eax

	call snieg

	; Wpisanie do wektora 8 naszego handlera
	mov ax, SEG obsluga_zegara
	mov bx, OFFSET obsluga_zegara

	; Zapis - blokada INTów na wypadek przerwania
	cli
	mov ds:[32], bx ; OFFSET
	mov ds:[34], ax ; SEGMENT
	sti ; Odblokowanie INTów

aktywne_oczekiwanie:

	; Oczekiwanie na 'X' na klawiaturze
	mov ah, 1
	int 16h

	jz aktywne_oczekiwanie

	; Odczytanie kodu ASCII klawisza do AL
	mov ah, 0
	int 16h     ; Odczyt klawisza
	cmp al, 'x' ; Wciœniêto klawisz?
	jne aktywne_oczekiwanie ; Inny klawisz/nic

definitywnykoniec:
; Wciœniêto X, koniec programu - przywracamy wektor 8
	mov eax, cs:wektor8

	cli ; Zapis do IVT, blokada
	mov ds:[32], eax
	sti ; Ok, odblokuj INTy

	; Koniec programu
	mov al, 0
	mov ah, 4Ch
	int 21h
rozkazy ENDS

nasz_stos SEGMENT stack
	db 128 dup (?)
nasz_stos ENDS

END zacznij


