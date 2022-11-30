;TP - 18 - CONVERSOR DE NUMEROS
global 	main
extern 	printf
extern	gets
extern  puts
extern  sscanf


section                         .data

    msgInicio                   db  ".-------------------------.",10,
                                db  "|  CONVERSOR DE NUMEROS   |",10,
                                db  ".-------------------------.",10,0
    msgOpcion                   db  "Seleccione: ",10,10,0

    msgOpciones                 db  "[1] Ingresar la configuracion hexadecimal numeros BCDI de 4 bytes y mostrar el numero represetado en base 10.            ",10,
                                db  "[2] Ingresar la configuracion binaria de un BPF C/Signo de 32 bits y mostrar el numero representado en base 10.          ",10,
                                db  "[3] Ingresar numeros en base 10 y mostrar su representacion en los formatos anteriores en configuracion en base 2, 4 y 8.",10,10,
                                db  "> Opcion: ",0

    ;Mensajes de ingreso
    msgIngresoHexa              db  "Ingrese la configuracion hexadecimal ",0
    msgIngresoBin               db  "Ingrese la configuracion binaria ",0,10
    msgIngresoDec               db  "Ingrese el numero decimal: ",0,10

    msgLetrasMay                db  "(Ingresar las letras en mayuscula)",10,0
    mensajeError 	            db  "Ingreso no valido!",10,0
    msgDigito                   db  "Ingrese digito %2i: ",0,10
    msgSignoDecimal             db  "Ingrese el signo del decimal ( + / - ): ",0
   
    ;Mensajes que devuelven lo ingresado
    msgnumHexa                  db  "> Hexadecimal ingresado: ",0,10
    msgnumBin                   db  "> Binario Punto Fijo con  signo  ingresado: ",0,10
    msgComplemento2             db  "> Complemento a 2 del BPFc/signo ingresado: ",0,10
    msgnumDeci                  db  "> Decimal ingresado: %lli ",0,10

    ;Mensajes correspondientes a la conversion
    msgNumDecimal               db  "-> Numero en base 10: %lli ",0
    msgNumBinario               db  "-> Numero en base 2: ",0
    msgNumBaseCuatro            db  "-> Numero en base 4: ",0
    msgNumOctal                 db  "-> Numero en base 8: ",0

    msgDebug                    db  " %lli ",0



    ;Formatos utilizados
    formatoNumero               db  '%lli',0 ;número entero con signo base 10
    formatoString               db  '%s',0
  

    ;Extras
    msgEspacio                  db  " ",0
    msgNegativo                 db  "-",0


    ;Vectores utilizados
    vector                      times 32 dq 1
    vectorHexaTraducido         times 32 dq 1   ;Guarda el hexadecimal traducido en decimal

    
    vectorBinario               times 32 dq 1
    vectorOctal                 times 32 dq 1
    vectorCuarta                times 32 dq 1


    ;Flags y almacenamientos
    esNegativo                  dq  0

    primerDigito                dq  0

    contadorDigitos             dd  0

    auxDecimal                  dq  0
    
    contadorDivisiones          dq  0


section                     .bss
    datoValido              resw    1
    
    
    opcionIngresada         resb    1
    opcion                  resb    1
    signo                   resb    1
    signoIngresado          resb    1

    inputNumeros            resb    50
    input                   resb    500 

    decimal                 resq    1 
    acumulador              resq    1
    potenciaVector          resq    1
    resultadoDecimal        resq    1
    numeroBase              resq    1


section .text
main:
    mov     rsi,0
    jmp     menu 

;------------------------------------------------;
; Muestra el mensaje de inicio y llama el menu   ;
;------------------------------------------------;
menu:

    mov     rcx,msgInicio
    sub     rsp,32
    call    printf
    add     rsp,32
    call    mostrarMenu
ret

;----------------------------------------------------------------------------------;
;Muestra las opciones a elegir y valida que lo ingresado corresponda a una opcion  ;
;----------------------------------------------------------------------------------;
mostrarMenu:
    mov     rcx,msgOpcion
	sub 	rsp,32
	call 	printf
	add 	rsp,32
    
    mov     rcx,msgOpciones
	sub 	rsp,32
	call 	printf
	add 	rsp,32

    mov     rcx,opcion  ;Guardo lo que se ingreso por teclado en el buffer
    sub     rsp,32
    call    gets
    add     rsp,32

    mov     rcx,opcion          ;parametro 1 -> donde tengo guardado lo ingresado
    mov     rdx,formatoNumero   ;parametro 2 -> Le doy formato
    mov     r8,opcionIngresada  ;parametro 3 -> Lo guardo en donde corresponde
    sub     rsp,32
    call    sscanf
    add     rsp,32

    mov		rcx,3
	mov		rsi,0
	mov		rdi,0

    call 	validarOpcion
	cmp		byte[datoValido],'N'
	je		errorIngreso

    jmp     accionARealizar

ret

;----------------------------------------------------------------------;
; Informa que lo ingresado no es correcto. Vuelve a mostrar el menu    ;
;----------------------------------------------------------------------;
errorIngreso:
	mov 	rcx,mensajeError
	sub 	rsp,32
	call 	printf
	add 	rsp,32
    jmp     mostrarMenu
ret
 
;----------------------------------------------------------------------;
; Valida que lo ingresado corresponda a cualquier opcion brindada      ;
;----------------------------------------------------------------------;
validarOpcion:
	mov		byte[datoValido],'N'

	cmp		qword[opcionIngresada],1
	jl		finValidarOpcion

	cmp		qword[opcionIngresada],3
	jg		finValidarOpcion

	mov		byte[datoValido],'S'

finValidarOpcion:
ret

;--------------------------------------------------------------------------;
; Segun el numero de opcion ingresada llama a la funcion correspondiente   ;
;--------------------------------------------------------------------------;
accionARealizar:
    cmp	    qword[opcionIngresada],1
    je      opcion1

    cmp		qword[opcionIngresada],2
    je      opcion2 

    cmp		qword[opcionIngresada],3
    je      opcion3    
ret

;------------------------------------------------------------;
;Opcion 1: Configuracion Hexadecimal BDIC 4 bytes a decimal  ;
;------------------------------------------------------------;
;-------------------------------------------------------------;
; Valida que lo ingresado corresponda a valores hexadecimales ;
;-------------------------------------------------------------;
validarHexadecimal:
    cmp     word[inputNumeros],'A'
    je      incrementarIndice

    cmp     word[inputNumeros],'B'
    je      incrementarIndice

    cmp     word[inputNumeros],'C'
    je      incrementarIndice


    cmp     word[inputNumeros],'D'
    je      incrementarIndice

    cmp     word[inputNumeros],'E'
    je      incrementarIndice


    cmp     word[inputNumeros],'F'
    je      incrementarIndice


    sub     word[inputNumeros],48

    cmp     word[inputNumeros],0
    jge     menorA9
menorA9:
    cmp     word[inputNumeros],9
    jle     vuelvoAPedir

vuelvoAPedir:
    add     word[inputNumeros],48
    jmp     incrementarIndice
    jmp     errorIngreso

ret

;---------------------------------------------------;
; Pide ingresar la configuracion hexadecima deseada ;
;---------------------------------------------------;
opcion1:

	mov 	rcx,msgIngresoHexa
	sub 	rsp,32
	call 	printf
	add 	rsp,32

    cmp     rax,1
    jl      opcion1

    sub 	rsp,32
    call    Hexadecimal
    add 	rsp,32

    jmp     opcion1

;-------------------------------------------------------------------------------------------------------;
; Setea en default todos campos que voy a usar. Indica que las letras deben ser ingresadas en mayuscula  ;
;-------------------------------------------------------------------------------------------------------;
Hexadecimal:
    mov     rsi,0
    mov     rdi,0
    mov     rbx,0
    mov     dword[contadorDigitos],0
    ;Preparo todos los campos que voy a usar

    mov     rcx,msgLetrasMay
    sub     rsp,32
	call 	puts
    add     rsp,32


;-----------------------------------------------------------------------------------------;
; Pide el ingreso de los digitos necesarios y asegura que correspondan a la base correcta ;  ;
;-----------------------------------------------------------------------------------------;
ingresoHexadecimal:
    inc     dword[contadorDigitos]
    cmp     rsi,32  ; Ingreso digito a digito. Lo trato como 8 ingresos de 8 bytes de peso
    jge     hexadecimalIngresado

	mov		rcx,msgDigito
    mov     rdx,[contadorDigitos]
    sub     rsp, 32        
	call	printf					
	add     rsp, 32
		
    mov     rcx,inputNumeros
    sub     rsp,32
	call 	gets
    add     rsp,32
    call    validarHexadecimal
    

;--------------------------------------;
; Agrega las letras al vector          ;
;--------------------------------------;
incrementarIndice: 
    mov     rdi,4 ;Utilizo 4 ya que es lo que pesan las letras
    call    rellenarVector


;---------------------------------------------------------------;
; Traduce las letras Hexadecimales a su equivalente en decimal  ;
;---------------------------------------------------------------;
traducirLetras:
    jmp     traducirHexadecimal

;--------------------------------------------------------------------------------;
; Agrega las letras hexadecimales traducidas en decimal al vectorHexaTraducido   ;
;--------------------------------------------------------------------------------;
agrego:   
    mov     rdx,[inputNumeros]
    mov     [vectorHexaTraducido+rbx],rdx
    add     rbx,8 ;En este caso ingresan numeros, pesan 8 bytes cada uno

    jmp     ingresoHexadecimal 
ret

;--------------------------------------------------------------------------------;
; Muestra el vector donde esta guardado la configuracion hexadecimal ingresada   ;
;--------------------------------------------------------------------------------;
hexadecimalIngresado:
    mov     rsi,0 ;Carga el vector
    
    mov		rcx,msgnumHexa	
	sub     rsp,32
	call 	printf
    add     rsp,32

;------------------------------------;
; Printea los elementos del vector   ;
;------------------------------------;
printearVectorHexadecimal:
    cmp     rsi,32
    jge     vectorHexaPrinteado

    mov     rcx,formatoString   ;Formato string ya que tengo letras ademas de numeros
    lea     rdx,[vector+rsi]    ;Utilizo el vector normal ya que simplemente tengo que mostrar lo ingresado
                                ;Sin embargo, opero con el vectorHexaTraducido porque ahi tengo almacenados las letras traducidas a decimal
    add     rsp,32
    call    printf
    sub     rsp,32

    add     rsi,4
    jmp     printearVectorHexadecimal

vectorHexaPrinteado:
    mov     rsi,0 ;En este caso, la logica sigue, entonces seteo  rsi a 0


;---------------------------------------------------------------------------------------------;
; Setea las variables a usar en 0 e imprime un salto de linea para mejor claridad de salida   ;
;---------------------------------------------------------------------------------------------;
preparoPasaje:
    mov     rcx,msgEspacio
    sub     rsp,32
    call    puts
    add     rsp,32

    mov     rsi,56  ;7 * 8 bytes!. Siendo 7 los exponentes distintos de 0
                    ;Como ingresan 8 digitos, los exponentes son 0,1,2,3,4,5,6,7
                    ;Utilizo este RSI para avanzar por el vector

    mov     qword[potenciaVector],0
    mov     qword[resultadoDecimal],0


;------------------------------------------------------------------------------;
; Realiza las multiplicaciones sucesivas para pasar de Hexadecimal a decimal   ;
;------------------------------------------------------------------------------;
calcularHexaADecimal:

;----------------------------------------------------------------------;
; Prepara los registros con los se van a trabajar para la conversion   ;
;----------------------------------------------------------------------;
pasarHexadecimalADecimal:
    cmp     rsi,0   
    jl      decimalObtenido

    mov     rdx,[vectorHexaTraducido+rsi]
    mov     rcx, qword[potenciaVector]
    mov     qword[acumulador],rcx

    cmp     rdx,0           ;Si el elemento en el que se para es 0, entonces
    je      avanzoHexadecimal

    cmp     rdx,1           ;Si el elemento es mayor a 1, sigo con la conversion
    jge     continuoHexaADecimal

;-------------------------------------;
;   Revisa el valor de la potencia    ;                                                         
;-------------------------------------;
continuoHexaADecimal:
    cmp     qword[potenciaVector],0
    je      potencia0Hexa

    cmp     qword[potenciaVector],1
    je      potencia1Hexa

    mov     r8,16   ;Seteo la multiplicacion para los casos que no cumplan las condiciones anteriores
    mov     r9,16
    jmp     potenciaHexa

;--------------------------------------------------------------------------------------------;
;Si la potencia es 0, entonces resultadoDecimal toma el valor del ultimo elemento del vector ;                                                                
;--------------------------------------------------------------------------------------------;
potencia0Hexa: 
    add     qword[resultadoDecimal],rdx
    jmp     avanzoHexadecimal

;---------------------------------------------------------------------------------;
;Si la potencia es 1, entonces simplemente multiplico el elemento del vector x 16 ;
;---------------------------------------------------------------------------------;
potencia1Hexa:
    mov     r8,16
    mov     r9,[vectorHexaTraducido+rsi]

    imul    r8,r9
    add     qword[resultadoDecimal],r8

    jmp     avanzoHexadecimal  

;----------------------------------------------------------------------;
; Realiza las multiplicaciones sucesivas con los exponentes =/= 0,1    ;
;----------------------------------------------------------------------;
potenciaHexa:
    imul    r8,r9

    dec     qword[potenciaVector]
    cmp     qword[potenciaVector],1
    jne     potenciaHexa
    
    mov     r9,[vectorHexaTraducido+rsi]
    imul    r8,r9

    add     qword[resultadoDecimal],r8


;-----------------------------------------------------------------------------------------------;
; Va avanzando por el vector, dandole valor a la variable de potencia segun la posicion actual  ;
;-----------------------------------------------------------------------------------------------;
avanzoHexadecimal:   
    mov     rcx, qword[acumulador]
    mov     qword[potenciaVector],rcx

    add     qword[potenciaVector],1   

    sub     rsi,8

    jmp     calcularHexaADecimal
ret  

;------------------------------;
;  Imprimo el valor en decimal ;
;------------------------------;
decimalObtenido:
    mov     rsi,0

    mov     rcx,msgNumDecimal
    mov     rdx,[resultadoDecimal]

    sub     rsp,32
    call    printf
    add     rsp,32
ret

;------------------------------------------------------;
; Traduce las letras Hexadecimales a su valor decimal  ;
;------------------------------------------------------;
traducirHexadecimal:
    cmp     qword[inputNumeros],'A'
    je      esDiez
    cmp     qword[inputNumeros],'B'
    je      esOnce
    cmp     qword[inputNumeros],'C'
    je      esDoce
    cmp     qword[inputNumeros],'D'
    je      esTrece
    cmp     qword[inputNumeros],'E'
    je      esCatorce
    cmp     qword[inputNumeros],'F'
    je      esQuince

    jmp     traduzco
ret

;----------------------------------------------------------------------;
;  Agrega al vectorHexadecimalTraducido los valores en decimal         ;
;----------------------------------------------------------------------;
traduzco:
    sub     qword[inputNumeros],48 ;Son 12 los valores en hexadecimal. 12*4bytes que es lo que pesan
    jmp     agrego
esDiez:
    mov     qword[inputNumeros],10    
    jmp     agrego
esOnce:
    mov     qword[inputNumeros],11
    jmp     agrego
esDoce:
    mov     qword[inputNumeros],12
    jmp     agrego
esTrece:
    mov     qword[inputNumeros],13
    jmp     agrego
esCatorce:
    mov     qword[inputNumeros],14
    jmp     agrego
esQuince:
    mov     qword[inputNumeros],15
    jmp     agrego


;--------------------;
;  Agrega al vector  ;
;--------------------;
rellenarVector:
    mov     rdi,[inputNumeros]
    mov     [vector+rsi],rdi
    add     rsi,4
ret

;------------------------------OPCION 2-----------------------------------------------------;
;---------------------------------------------;
;Opcion 2: BPF C/Signo 32 bits a decimal.     ;
;---------------------------------------------;
;------------------------------------------------;
; Valida que lo ingresado sean valores binarios  ;                        
;------------------------------------------------;
validarBinario:
    cmp     word[input],1
    jne     EsCero
ret
EsCero:
    cmp     word[input],0
    jne     errorIngreso
ret 

;-----------------------------------------------;
; Setea en default todos campos que voy a usar. ;
;-----------------------------------------------;
opcion2:
	mov 	rcx,msgIngresoBin
	sub 	rsp,32
	call 	printf
	add 	rsp,32

    cmp     rax,1
    jl      opcion2

    sub 	rsp,32
    call    esBinario
    add 	rsp,32

    jmp     opcion2

esBinario:
    mov  	rcx,msgEspacio
	call 	puts

    mov     rdi,8
    mov     rsi,0
    mov     dword[contadorDigitos],0

;-----------------------------------------------------------------------------------------;
; Pide el ingreso de los digitos necesarios y asegura que correspondan a la base correcta  ;
;-----------------------------------------------------------------------------------------;
ingresoBinario:
    inc     dword[contadorDigitos]

    cmp     rsi,256; 32 numeros de 8 bytes c/u 
    jge     binarioValido

	mov		rcx,msgDigito
    mov     rdx,[contadorDigitos]
    sub     rsp, 32        
	call	printf					
	add     rsp, 32

    mov     rcx,inputNumeros
    sub     rsp,32
    call    gets
    add     rsp,32

    mov     rcx,inputNumeros 
    mov     rdx,formatoNumero
    mov     r8,input
    sub     rsp,32
    call    sscanf
    add     rsp,32

    call    validarBinario

;--------------------;
;  Agrega al vector  ;
;--------------------;
agregarAVector:
    mov     rdi,[input]
    mov     [vector+rsi],rdi

    add     rsi,8

    jmp     ingresoBinario
binarioValido:
    mov     rsi,0
    mov		rcx,msgnumBin

    sub     rsp,32
    call    printf
    add     rsp,32

;------------------------------------;
; Printea los elementos del vector   ;
;------------------------------------;   
printearNumeros: 
    cmp     rsi,256  ;32 numeros de 8 bytes c/u
    jge     vectorBinPrinteado
    
    mov     rcx,formatoNumero
    mov     rdx,[vector+rsi]

    sub     rsp, 32        
	call	printf					
	add     rsp, 32

    add     rsi,8
    jmp     printearNumeros

vectorBinPrinteado:
    mov     rsi,0

;---------------------------------------------------------------------------; 
;Me fijo el primer numero ingresado en el vector. Bifurco segun corresponda ;
;---------------------------------------------------------------------------; 
signoBinario:
    mov     r9,[vector+rsi]
    mov     qword[primerDigito],r9 ;Guardo el primer elemento en la variable

    cmp     qword[primerDigito],0     
	je      binarioEsPositivo
    jne     binarioEsNegativo
ret

;----------------------------------------------------------------;
;Si es positivo, simplemete acomodo el vector para la conversion ;
;----------------------------------------------------------------;
binarioEsPositivo:
    call   preparoSwap 
ret

;;-------------------------------------------------------------------------------------------------;
;Si es negativo, entonces se activa una flag que indica que el decimal debe imprimirse a negativo  ;
;Luego, se hace el complemento a 2 del binario                                                     ;
;--------------------------------------------------------------------------------------------------;
binarioEsNegativo:
    mov     qword[esNegativo],1
    jmp     notBinario
ret

;-------------------------------;
;Realizo el complemento a 2     ;
;-------------------------------;
notBinario:
    cmp     rsi,256 ;32 numeros de 8 bytes c/u
    jge     complementoA2

    mov     rbx,qword[vector+rsi]
    NEG     rbx
    add     rbx,1
    mov     [vector+rsi],rbx 

                          
    add     rsi,8

    jmp     notBinario
ret

;------------------------------------------------------------------------;
;Imprimo el complemento a 2 para mejor claridad del proceso por pantalla ;
;------------------------------------------------------------------------;
complementoA2:
    mov     rsi,0

    mov		rcx,msgEspacio
    sub     rsp,32
    call    puts
    add     rsp,32

    mov		rcx,msgComplemento2
    sub     rsp,32
    call    printf
    add     rsp,32
    

printearComplemento: 
    cmp     rsi,256  ;32 numeros de 8 bytes c/u
    jge     complementoObtenido
    
    mov     rcx,formatoNumero
    mov     rdx,[vector+rsi]

    sub     rsp, 32        
	call	printf					
	add     rsp, 32

    add     rsi,8
    jmp     printearComplemento

complementoObtenido:
    mov     rsi,0

;-----------------------------------------------------------------------------------------------------------------;
;El codigo me da vuelta el vector con el que trabajo, utilizo estas funciones para lograr la correcta conversion  ;
;Me prepara los campos                                                                                            ;
;-----------------------------------------------------------------------------------------------------------------;
preparoSwap:
    mov     rsi,0
    mov     rdi,248 ;31 numeros de 8 bytes c/u

swap:
    cmp     rsi,128  ;16 numeros de 8 bytes c/u
    jge     fin

    mov     rdx,[vector+rsi]
    mov     rcx,[vector+rdi]

    mov     [vector+rdi],rdx
    mov     [vector+rsi],rcx

    add     rsi,8
    sub     rdi,8

    jmp     swap

;Como la logica sigue, seteo el RSI en 0
fin:
   mov     rsi,0 

;-----------------------------------------------------------------------------;
; Setea las variables y registros que se van a usar para la conversion en 0   ;
;-----------------------------------------------------------------------------;
binarioADecimal:
    mov     rcx,msgEspacio
    call    puts

    mov     rsi,0
    mov     qword[potenciaVector],0 
    mov     qword[resultadoDecimal],0

;-------------------------------------------;
; Realiza las multiplicaciones sucesivas    ;
;-------------------------------------------;
calcularBinarioaDecimal:
pasarBinarioADecimal:
    cmp      rsi,256  ;256
    jge      chequeoSigno

    mov     rdx,qword[vector+rsi]
    mov     rcx, qword[potenciaVector]
    mov     qword[acumulador],rcx

    cmp     rdx,0
    je      avanzoVectorBinario

    cmp     rdx,1
    je      continuoBinarioADecimal

;-------------------------------------;
;   Revisa el valor de la potencia    ;                                                         
;-------------------------------------
continuoBinarioADecimal:
    cmp     qword[potenciaVector],0
    je      potencia0Binario

    cmp     qword[potenciaVector],1
    je      potencia1Binario

    mov     r8,2
    mov     r9,2

    call    potenciaBinario
    jmp     avanzoVectorBinario

;------------------------------------------------------------------------;
;Si la potencia es 0, entonces resultadoDecimal simplemente aumenta en 1 ;                                                                
;------------------------------------------------------------------------;
potencia0Binario:
    inc     qword[resultadoDecimal]
    jmp     avanzoVectorBinario

;---------------------------------------------------------------------;
;Si la potencia es 1, entonces multiplico el elemento del vector x 2  ;
;---------------------------------------------------------------------;
potencia1Binario:
    mov     r8,2
    mov     r9,[vector+rsi]

    imul    r8,r9
    add     qword[resultadoDecimal],r8

    jmp     avanzoVectorBinario

;----------------------------------------------------------------------;
; Realiza las multiplicaciones sucesivas con los exponentes =/= 0,1    ;
;----------------------------------------------------------------------;
potenciaBinario:
    imul    r8,r9

    dec     qword[potenciaVector]
    cmp     qword[potenciaVector],1
    jne     potenciaBinario

    
    mov     r9,[vector+rsi]
    imul    r8,r9

    add     qword[resultadoDecimal],r8

;-----------------------------------------------------------------------------------------------;
; Va avanzando por el vector, dandole valor a la variable de potencia segun la posicion actual  ;
;-----------------------------------------------------------------------------------------------;
avanzoVectorBinario:
    mov     rcx, qword[acumulador] 
    mov     qword[potenciaVector],rcx
    add     qword[potenciaVector],1 
    
    add     rsi,8   
    
    jmp     calcularBinarioaDecimal
ret  

;-----------------------------------------------------------------------;
; Revisa si la flag de negativo esta activa. Bifurca segun corresponda  ;
;-----------------------------------------------------------------------;
chequeoSigno:
    cmp     qword[esNegativo],1
    je      decimalNegativo
    jmp     decimalPositivo
ret
;-------------------------------------------------------------------;
; Multiplico por -1 a la variable que tiene almacenada el resultado ;
;-------------------------------------------------------------------;
decimalNegativo:
    mov     r10,qword[resultadoDecimal]
    imul    r10,-1
    mov     qword[resultadoDecimal],r10

;----------------------;
; Imprimo el resultado ;
;----------------------;
decimalPositivo:
    mov     rcx,msgNumDecimal
    mov     rdx,[resultadoDecimal]

    add     rsp,32
    call    printf
    add     rsp,32
ret


;----------------------------------OPCION 3-----------------------------------------------------;

;------------------------------------------------------------------;
;Opcion 3: Decimal a base 2,4,8 en las configuraciones anteriores  ;
;------------------------------------------------------------------;
opcion3:
    mov     rcx, msgSignoDecimal
    sub 	rsp,32
	call 	printf
	add 	rsp,32

    cmp     rax,1
    jl      opcion3

    sub 	rsp,32
    call    signoDecimal
    add 	rsp,32

    jmp     final

;-------------------------------------------------------;
; Pido el ingreso del signo correspondiente al decimal  ;
;-------------------------------------------------------;
signoDecimal:
    mov     qword[esNegativo],0

    mov     rcx,signo
    sub     rsp,32
    call    gets
    add     rsp,32

    mov     rcx,signo 
    mov     rdx,formatoString
    mov     r8,signoIngresado
    sub     rsp,32
    call    sscanf
    add     rsp,32

    call    chequearSigno
ret

;-----------------------------------------------------;
; Valida que el input sea correspondiente a lo pedido ;
;-----------------------------------------------------;
chequearSigno:
    cmp    qword[signoIngresado],'+'
    je     signoPositivo

    cmp    qword[signoIngresado],'-'
    je     signoNegativo

    jmp    errorIngreso  ;Si no es ninguno entonces es invalido

;-----------------------------;
; Activa la flag de negativo  ;
;-----------------------------;
signoNegativo:
    mov     qword[esNegativo],1
    jmp     ingresoDecimal
ret

;--------------------------------------------;
; Si es positivo, simplemente sigue de largo ;
;--------------------------------------------;
signoPositivo:
    mov     rsi,0

;----------------------------------------------------------------;
; Pide el ingreso del numero decimal y lo guarda en una variable ;
;----------------------------------------------------------------;
ingresoDecimal:
 	mov 	rcx,msgIngresoDec
	sub 	rsp,32
	call 	printf
	add 	rsp,32

    mov     rcx,inputNumeros
    sub     rsp,32
    call    gets
    add     rsp,32

    mov     rcx,inputNumeros 
    mov     rdx,formatoNumero
    mov     r8,decimal
    sub     rsp,32
    call    sscanf
    add     rsp,32

    mov     rbx,qword[decimal]
    mov     qword[auxDecimal], rbx


;-------------------------------A BASE OCTAL----------------------------------------------;
;--------------------------------------------------;
; Realiza las divisiones sucesivas con divisor = 8 ;
;--------------------------------------------------;
aOctal:
decimalAOctal:

    mov     rcx, msgEspacio
    sub     rsp,32
    call    puts
    add     rsp,32

;------------------------------------------;
; Le da el valor a la variable del divisor ;
;------------------------------------------;
pasarDecAOctal:
    
    mov     qword[numeroBase],8
    mov     qword[contadorDivisiones],0

dividoOctal:

    cmp     rsi,256
    jge     preparoSwapOctal

    mov     rax,rbx ;lo que voy a dividir 
    sub     rdx,rdx
    
    idiv    qword[numeroBase] ;divido por la base

    mov     rbx,rax

    mov     rdx,rdx
    mov     rdi,rdx

    cmp     rdi,0   ;Cuando el resto sea 0, entonces no lo tengo en cuenta
    jne     aumentoContador

    add     rsi,8
    jmp     dividoOctal
ret

aumentoContador:
    add     qword[contadorDivisiones],1
    
    mov     [vectorOctal+rsi],rdi ; agrega el resto al vector
  
    add     rsi,8
    jmp     dividoOctal

 ret


;---------------------------------------------------------------------------------------------------------------------------------------------------;
;Como en la division anterior los restos se agregaron al vector en orden inverso, doy vuelta el vector para que muestre correctamente por pantalla  ;
;---------------------------------------------------------------------------------------------------------------------------------------------------;
preparoSwapOctal:
    mov     rsi,0

    mov     r8,8
    mov     r9,qword[contadorDivisiones]
    sub     r9,1
    imul    r9,r8

    mov     rdi,r9
swapOctal:
    mov     r8,2
    mov     r9,8
    mov     rax,qword[contadorDivisiones]
    imul    rax,r9
    sub     rdx,rdx
    idiv    r8

    cmp     rsi,rax
    jge     octalValido

    mov     rdx,[vectorOctal+rsi]
    mov     rcx,[vectorOctal+rdi]

    mov     [vectorOctal+rdi],rdx
    mov     [vectorOctal+rsi],rcx

    add     rsi,8
    sub     rdi,8

    jmp     swapOctal
ret

octalValido:
    mov     rsi,0 

    mov		rcx,msgNumOctal	
	sub     rsp,32
	call 	printf
    add     rsp,32

    cmp     qword[esNegativo],1
    je      octalNegativo
    jmp     imprimoVectorOctal

;--------------------------------------------------------------------------;
; Le agrega el signo negativo en caso de que la flag se encuentre activa   ;
;--------------------------------------------------------------------------;
octalNegativo:
    mov     rcx, msgNegativo

    sub     rsp,32
    call    printf
    add     rsp,32

;------------------------------------;
; Printea los elementos del vector   ;
;------------------------------------;
imprimoVectorOctal:

    mov     r8,8  ;Bytes que pesa cada numero
    mov     r10,qword[contadorDivisiones]
    imul    r10,r8
    
    cmp     rsi,r10
    jge     sigo
    
    mov     rcx, formatoNumero
    mov     rdx, [vectorOctal + rsi ]
    sub     rsp,32
    call    printf
    add     rsp,32

    add     rsi,8
    jmp     imprimoVectorOctal
ret
;--------------------------A BASE 4-------------------------------------------;
;------------------------------------;
; Siguiente conversion               ;
;------------------------------------;
sigo:
    mov     rsi,0

;--------------------------------------------------;
; Realiza las divisiones sucesivas con divisor = 4 ;
;--------------------------------------------------;
aBaseCuatro:
decimalaBaseCuatro:

    mov     rcx, msgEspacio
    sub     rsp,32
    call    puts
    add     rsp,32
pasarDecABaseCuarta:
    mov     qword[numeroBase],4
    mov     qword[contadorDivisiones],0
dividoCuarta:

    cmp     rsi,256
    jge     preparoSwapC  

    mov     rax,qword[auxDecimal] ;lo que voy a dividir 
    sub     rdx,rdx
    
    idiv    qword[numeroBase] ;divido por la base

    mov     qword[auxDecimal],rax

    mov     rdx,rdx
    mov     rdi,rdx

    cmp     rdi,0   ;Cuando el resto sea 0, entonces no lo tengo en cuenta
    jne     aumentoContadorBaseCuarta

    add     rsi,8
    jmp     dividoCuarta
ret

aumentoContadorBaseCuarta:
    add     qword[contadorDivisiones],1
    
    mov     [vectorCuarta+rsi],rdi ; agrega el resto al vector
  
    add     rsi,8
    jmp     dividoCuarta

 ret
;---------------------------------------------------------------------------------------------------------------------------------------------------;
;Como en la division anterior los restos se agregaron al vector en orden inverso, doy vuelta el vector para que muestre correctamente por pantalla  ;
;---------------------------------------------------------------------------------------------------------------------------------------------------;
preparoSwapC:
    mov     rsi,0

    mov     r8,8
    mov     r9,qword[contadorDivisiones]
    sub     r9,1
    imul    r9,r8
    mov     rdi,r9

swapC:
    mov     r8,2
    mov     r9,8
    mov     rax,qword[contadorDivisiones]
    imul    rax,r9
    sub     rdx,rdx
    idiv    r8

    cmp     rsi,rax
    jge     BaseCuartaValido

    mov     rdx,[vectorCuarta+rsi]
    mov     rcx,[vectorCuarta+rdi]

    mov     [vectorCuarta+rdi],rdx
    mov     [vectorCuarta+rsi],rcx

    add     rsi,8
    sub     rdi,8

    jmp     swapC
ret

BaseCuartaValido:
 
    mov     rsi,0 
    mov		rcx,msgNumBaseCuatro	
	sub     rsp,32
	call 	printf
    add     rsp,32

    cmp     qword[esNegativo],1
    je      baseCuartaNegativo
    jmp     imprimoVectorBaseCuarta

;--------------------------------------------------------------------------;
; Le agrega el signo negativo en caso de que la flag se encuentre activa   ;
;--------------------------------------------------------------------------;

baseCuartaNegativo:
    mov     rcx, msgNegativo

    sub     rsp,32
    call    printf
    add     rsp,32

;------------------------------------;
; Printea los elementos del vector   ;
;------------------------------------;
imprimoVectorBaseCuarta:
    mov     r8,8  ;Bytes que pesa cada numero
    mov     r10,qword[contadorDivisiones]
    imul    r10,r8

    cmp     rsi,r10
    jge     ultimaConversion
    
    mov     rcx, formatoNumero
    mov     rdx, [vectorCuarta+rsi]
    sub     rsp,32
    call    printf
    add     rsp,32

    add     rsi,8
    jmp     imprimoVectorBaseCuarta

ret

;--------------------------A BINARIO-----------------------------------
;En este caso, el resultado final se va a mostrar en BPF C/signo 32 bits
;------------------------------------;
; Siguiente conversion               ;
;------------------------------------;
ultimaConversion:
    mov     rsi,0
    mov     rbx,0 ;Lo utilizo para el complemento a 2

;--------------------------------------------------;
; Realiza las divisiones sucesivas con divisor = 2 ;
;--------------------------------------------------;
aBinario:
decimalaBinario:

    mov     rcx, msgEspacio
    sub     rsp,32
    call    puts
    add     rsp,32

pasarDecABina:
    mov     qword[numeroBase],2
    mov     qword[contadorDivisiones],0
divido:

    cmp     rsi,256
    jge     verificoSignoDecimal

    mov     rax,qword[decimal] ;lo q voy a dividir 
    sub     rdx,rdx
    
    idiv    qword[numeroBase] ; divido por la base

    mov     qword[decimal],rax

    mov     rdx,rdx
    mov     rdi,rdx

    mov     [vectorBinario+rsi],rdi ;agrega el resto al vector

    add     rsi,8
 
    jmp     divido

ret

aumentoContadorBinario:
    add     qword[contadorDivisiones],1

    mov     [vectorBinario+rsi],rdi ;agrega el resto al vector
    add     rsi,8
 
    jmp     divido
    
 ret

;------------------------------------------------------------------------------------------------------;
; Si la flag de negativo esta activada, entonces realiza el complemento a 2. Sino, da vuelta el vector ;
;------------------------------------------------------------------------------------------------------;
verificoSignoDecimal:
    cmp     qword[esNegativo],1
    je      complementoVectorBinario
    jmp     preparoSwapBinario
ret

complementoVectorBinario:
    mov     rsi,0

;-------------------------------;
;Realizo el complemento a 2     ;
;-------------------------------;   
notVectorBinario:

    cmp     rsi,256 ;32 numeros de 8 bytes c/u
    jge     preparoSwapBinario

    mov     rbx,qword[vectorBinario+rsi]
    NEG     rbx
    add     rbx,1
    mov     [vectorBinario+rsi],rbx ;Esta parte de por si me da vuelta el vector
                                
    add     rsi,8

    jmp     notVectorBinario
ret
;---------------------------------------------------------------------------------------------------------------------------------------------------;
;Como en la division anterior los restos se agregaron al vector en orden inverso, doy vuelta el vector para que muestre correctamente por pantalla  ;
;---------------------------------------------------------------------------------------------------------------------------------------------------;
preparoSwapBinario:
    mov     rsi,0
    mov     rdi,248

swapBinario:
    cmp     rsi,128
    jge     binarioObtenido

    mov     rdx,[vectorBinario+rsi]
    mov     rcx,[vectorBinario+rdi]

    mov     [vectorBinario+rdi],rdx
    mov     [vectorBinario+rsi],rcx

    add     rsi,8
    sub     rdi,8

    jmp     swapBinario
ret

binarioObtenido:
 
    mov     rsi,0 ;CARGA EL VECTOR
    mov		rcx,msgNumBinario	
	sub     rsp,32
	call 	printf
    add     rsp,32
;------------------------------------;
; Printea los elementos del vector   ;
;------------------------------------;
imprimoVectorBinario:

    cmp     rsi,256
    jge     final

    mov     rcx, formatoNumero
    mov     rdx, [vectorBinario+rsi]
    sub     rsp,32
    call    printf
    add     rsp,32

    add     rsi,8
    jmp     imprimoVectorBinario

ret
final:
ret