;*******************************************************************************
; *
; Filename: EXERCICIO1.asm *
; Date: Agosto-17 *
; File Version: 1 *
; Author: RONY MARK *
; Company: IFSULDEMINAS *
; Description: *
 ;******************************************************************************* 
;******************************************************************************* 
; TODO INSERT INCLUDE CODE HERE 
#include "p16f84a.inc" 
 
; TODO INSERT CONFIG HERE
; CONFIG 
 
__CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _CP_ON 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* PAGINA??O DE MEM?RIA * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 ;DEFINI??O DE COMANDOS DE USU?RIO PARA ALTERA??O DA P?GINA DE MEM?RIA 
 
#DEFINE BANK0 BCF STATUS,RP0
#DEFINE BANK1 BSF STATUS,RP0 
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* VARI?VEIS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; DEFINI??O DOS NOMES E ENDERE?OS DE TODAS AS VARI?VEIS UTILIZADAS
; PELO SISTEMA 
 
    CBLOCK 0x20 
    
	CONTADOR    ;ARMAZENA O VALOR DA CONTAGEM 
	UP_DOWN	    ;ARMAZENA OS FLAGS DE CONTROLE
	FILTRO	    ;FILTRAGEM PARA O BOT?O 
	
    ENDC	    ;FIM DO BLOCO DE MEM?RIA 
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* FLAGS INTERNOS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; DEFINI??O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA 
    
#DEFINE CONTROLE    UP_DOWN,0 
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 ;* CONSTANTES *
 ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 ; DEFINI??O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA 
 
MIN	    EQU	    .1 
MAX	    EQU	    .9 
T_FILTRO    EQU	    .230 
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* ENTRADAS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 ; DEFINI??O DE TODOS OS PINOS QUE SER?O UTILIZADOS COMO ENTRADA
 ; RECOMENDAMOS TAMB?M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1) 
 
#DEFINE BOTAO PORTA,2 ; 0 -> PRESSIONADO 
                      ; 1 -> LIBERADO 
		      
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* SA?DAS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
; DEFINI??O DE TODOS OS PINOS QUE SER?O UTILIZADOS COMO SA?DA
 ; RECOMENDAMOS TAMB?M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1) 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* VETOR DE RESET *
 ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
    ORG 0x00	;ENDERE?O INICIAL DE PROCESSAMENTO 
    GOTO INICIO 
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 ;* IN?CIO DA INTERRUP??O *
 ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 ; AS INTERRUP??ES N?O SER?O UTILIZADAS, POR ISSO PODEMOS SUBSTITUIR
 ; TODO O SISTEMA EXISTENTE NO ARQUIVO MODELO PELO APRESENTADO ABAIXO 
; ESTE SISTEMA N?O ? OBRIGAT?RIO, MAS PODE EVITAR PROBLEMAS FUTUROS 
 
    ORG 0x04	;ENDERE?O INICIAL DA INTERRUP??O 
    RETFIE	;RETORNA DA INTERRUP??O 
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* INICIO DO PROGRAMA *
 ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
INICIO 
    BANK1
    MOVLW B'00000100'
    MOVWF TRISA		 ;CONFIGURA AS PORTAS RA0,RA1,RA3 E RA4 COM ENTRADA E RA2 COMO SA?DA

    MOVLW B'00000000'
    MOVWF TRISB		;CONFIGURA AS PORTAS RB0 AT? RB7 COMO SA?DA

    MOVLW B'10000000'
    MOVWF OPTION_REG	;DESABILITA OS PULL-UPS DO PORTB

    MOVLW B'00000000' 
    MOVWF INTCON	;TODAS AS INTERRUP??ES DESLIGADAS 
    BANK0 
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* INICIALIZA??O DAS VARI?VEIS *
 ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 
    CLRF PORTA ;LIMPA O PORTA
    
    CLRF PORTB ;LIMPA O PORTB
    MOVLW MIN
    MOVWF CONTADOR ;MOVE O VALOR DO ACUMULADOR (MIN = 1) PARA CONTADOR

 ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 ;* ROTINA PRINCIPAL *
 ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
MAIN 
    MOVF CONTADOR,W ;MOVE O VALOR DO CONTADOR PARA O ACUMULADOR
    
    MOVWF PORTB ;MOVE O VALOR DO ACUMULADOR PARA PORTB
    
    MOVLW T_FILTRO 
    
    MOVWF FILTRO ;MOVE O VALOR DO ACUMULADOR PARA FILTRO
    
CHECA_BT 
    BTFSC BOTAO ;VERIFICA SE O BOT?O EST? LIMPO, SE ESTIVER PULA A PR?XIMA INSTRU??O 

    GOTO MAIN ;VAI PARA MAIN
    
    DECFSZ FILTRO,F ;DECREMENTA FILTRO, PULA SE F FOR IGUAL A 0 
    
    GOTO CHECA_BT ;VAI PARA CHECA_BT
    
TRATA_BT 
    BTFSS CONTROLE ;SE CONTROLE FOR 0 EXECUTA A PROXIMA INSTRU??O, SE N?O, PULA A PR?XIMA INSTRU??O
    
    GOTO SOMA ;VAI PARA SOMA
    
SUBTRAI 
    DECF CONTADOR,F ;DECREMENTA CONTADOR, SE F FOR 0 O RESULTADO SER? ARMAZENADO NO ACUMULADOR, SEN?O O RESULTADO SERA ARMAZENADO DE VOLTA NO CONTADOR
    
    MOVLW MIN ;MOVE O VALOR DE MIN PARA O ACUMULADOR
    
    SUBWF CONTADOR,W ;SUBTRAI O VALOR DO ACUMULADOR DO CONTADOR, SE W(ACUMULADOR) FOR 0 O RESUTADO SER? ARMAZENADO NO ACUMULADOR, SEN?O O RESULTADO SER? ARMAZENADO DE VOLTA NO CONTADOR
    
    BTFSC STATUS,Z ;SE O BIT Z NO REGISTRADOR STATUS FOR 1, A PROXIMA INSTRU??O ? EXECUTADA, SEN?O ? PULADA
    
    BCF CONTROLE ;LIMPA O BIT CONTROLA
    
    GOTO ATUALIZA ;VAI PARA ATUALIZA

SOMA 
    INCF CONTADOR,F ;INCREMENTA CONTADOR, SE F ? 0 O RESULTADO ? COLOCADO NO ACUMULADOR, SEN?O ? COLOCADO NO CONTADOR
    
    MOVLW MAX ;MOVE O VALOR DE MAX PARA O ACUMULADOR
    
    SUBWF CONTADOR,W ;DECREMENTA CONTADOR, SE F ? 0 O RESULTADO ? COLOCADO NO ACUMULADOR, SEN?O ? COLOCADO NO CONTADOR
    
    BTFSC STATUS,Z ;SE O BIT Z NO REGISTRADOR STATUS FOR 1, A PROXIMA INSTRU??O ? EXECUTADA, SEN?O ? PULADA
    
BSF CONTROLE ;SETA O BIT DE CONTROLE
    
ATUALIZA 
    MOVF CONTADOR,W ;MOVE O VALOR DE CONTADOR PARA W(ACUMULADOR)
    
    MOVWF PORTB ;MOVE O VALOR DO PORTB PARA O ACUMULADOR
    
    BTFSS BOTAO ;SE BOT?O FOR 1 A PR?XIMA INSTRU??O ? PULADA, SEN?O N?O
    
    GOTO $-1 ;VAI PARA A INSTRU??O ANTERIOR
    
    GOTO MAIN ;VAI PARA MAIN
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* FIM DO PROGRAMA * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
    
    END ;OBRIGAT?RIO 
