


;TODO INSERT INCLUDE CODE HERE 
		      
#include "p16f84a.inc" 
		      
;TODO INSERT CONFIG HERE
;CONFIG
		      
__CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _CP_ON
		      
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* PAGINA??O DE MEM?RIA * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
;Defini??o de comandos do usu?rio para altera??o da p?gina de mem?ria

#DEFINE BANK0 BCF STATUS,RP0
#DEFINE BANK1 BSF STATUS,RP0 
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* VARI?VEIS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
;Defini??o dos nomes e endere?os de todas as v?riaveis utilizadas 
;pelo sistema 
 
CBLOCK 0x20 
		      
STATUS_TEMP ;V?riavel utilizada para salvar o contexto do STATUS
W_TEMP ;V?riavel utilizada para salvar o contexto do ACUMULADOR(W)
CONTADOR ;Armazena o valor da contagem
UP_DOWN ;Armazena os flags de controle
FILTRO ;Filtragem para o bot?o
ENDC ;Fim do bloco de mem?ria
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* FLAGS INTERNOS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 
;Defini??o de todos os flags utilizados pelo sistema 

#DEFINE CONTROLE UP_DOWN,0
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* CONSTANTES *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 
;Defini??o de todas as constantes utilizadas no sistema
 
MIN EQU .1 
MAX EQU .9 
T_FILTRO EQU .230 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* ENTRADAS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 
;Defini??o de todos os pinos que ser?o utilizados como entradas
;Recomendamos tamb?m comentar o significado de seus estado (0 e 1)
 
#DEFINE BOTAO PORTB,2 ;0 -> PRESSIONADO 
                      ;1 -> LIBERADO 
		      
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* SA?DAS * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		      
;Defini??o de todos os pinos que ser? utilizados com sa?das
;Recomendamos tamb?m comentar o significado de seus estados (0 e 1)
		      
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* VETOR DE RESET *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
ORG 0x00 ;Endere?o inicial de processamente GOTO INICIO
GOTO INICIO
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* IN?CIO DA INTERRUP??O *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		      
;As interrup??es n?o seram utilizadas, por isso podemos substituir
;Todo o sistema existente no arquivo modelo pelo apresentado abaixo
;Este sistema n?o ? obrigat?rio, mas pode evitar problemas futuros
		      
ORG 0x04 ;Endere?o inicial da interrup??o
   
MOVWF W_TEMP	    ;Move o estado atual do acumulador para o W_TEMP
SWAPF STATUS, W	    ;Move o estado atual do STATUS para o acumulador, com a sequ?ncia de BITS invertida
		    ;Necessida de usar o SWAPF, pois o MOVFW altera o estado do STATUS      
MOVWF STATUS_TEMP   ;Move do acumulador para o STATUS_TEMP
	
BTFSS PORTB,7 ;Verifica o n?vel l?gico do RB7. Caso 1, apaga, caso 0, acende
GOTO ACENDE   ;Jump para onde ser? setado n?vel l?gico alto no RB7
GOTO APAGA    ;Jump para onde ser? setado n?vel l?gico baixo no RB7
    
FIM	      
SWAPF STATUS_TEMP, W ;Move o estado de STATUS_TEMP para o acumulador, desinvertendo o seu estado
MOVWF STATUS	     ;Move do acumulador para o STATUS
SWAPF W_TEMP, F	     ;Inverte o estado de W_TEMP e armazena no pr?pio
SWAPF W_TEMP, W	     ;Move o estado de W_TEMP para o acumulador

;Aparti daqui tanto o STATUS como o acumulador retornaram ao estado que estavem antes de entrarem na interrup??o

BCF INTCON, 1	;Limpa o bit no INTCON que sinaliza que ocorreu a interrup??o no RBO/INT
RETFIE		;Retorna da interrup??o
		      
		      
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* INICIO DO PROGRAMA *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
INICIO

 
BANK1
MOVLW B'00000000' ;Move o n?mero bin?rio 00000000 para o acumulador
MOVWF TRISA       ;Move o estado do acumulador para o Registrador TRISA, habilitando o PORTA com sa?da

MOVLW B'00000101' ;Move o n?mero bin?rio 00000000 para o acumulador
MOVWF TRISB	  ;Move o n?mero bin?rio 00000000 do acumulador para o registrador TRISB, habilitando assim RB0 e RB2 como entrada
	          ;e todas as outras com sa?das
	    
MOVLW B'11000000';Move o n?mero bin?rio 11000000 para o acumulador
MOVWF OPTION_REG ;Move o estado de acumulador para o registrador OPTION_REG, desabilitando PORTB PULL-UPS
		 ;e ativando a interrup??o no RBO/INT por borda de subida

MOVLW B'10010000' ;Move o n?mero bin?rio 10010000 para o acumulador 
MOVWF INTCON      ;Move o estado do ACUMULADOR para o INTCON, habilitando a interrup??o no RB0/INT

BANK0
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* INICIALIZA??O DAS VARI?VEIS *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

CLRF PORTA ;Limpa as sa?das do PORTA
CLRF PORTB ;Limpa as sa?das do PORTB
 
MOVLW MIN      ;Move o valor de MIN para o acumulador
MOVWF CONTADOR ;Move o valor de MIN no acumulador para o CONTADOR
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* ROTINA PRINCIPAL *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

MAIN 
MOVF CONTADOR,W ;Move o valor de CONTADOR para o acumulador
MOVWF PORTA     ;Move o valor de CONTADOR no acumulador para as SA?DAS do PORTB
 
MOVLW T_FILTRO ;Move o valor de T_FILTRO para o acumulador
MOVWF FILTRO   ;Move o valor de T_FILTRO no acumulador para FILTRO

 
CHECA_BT 
BTFSC BOTAO ;Confere se o bot?o est? pressionado, se n?o, pula a prox?ma instru??o
GOTO MAIN   ;Pula para o MAIN
 
DECFSZ FILTRO,F ;Decrementa FILTRO e armazena o resultado no pr?prio FILTRO, at? encontrar 0 e ent?o pular a pr?xima instru??o
GOTO CHECA_BT   ;Pula para CHECA_BT
 
 
TRATA_BT 
BTFSS CONTROLE ;Confere se CONTROLE est? em 1, se sim, pula a pr?xima instru??o
GOTO SOMA      ;Pula para SOMA
 
		      
SUBTRAI 
DECF CONTADOR,F ;Decrementa o contador
 
MOVLW MIN	 ;Move o que est? no min para o acumulador
SUBWF CONTADOR,W ;subtrai o que esta no acumulador do contador
 
BTFSC STATUS,Z ;confere se o STATUS esta em 0, se sim, pula a pr?xima instru??o
BCF CONTROLE   ;Limpa o bit de controle
GOTO ATUALIZA  ;Pula para o ATUALIZA

    
SOMA 
INCF CONTADOR,F ;Incrementa o contador em +1
MOVLW MAX	;Move o que est? em MAX para o acumulador
SUBWF CONTADOR,W;Subtrai o que est? no acumulador do contador
BTFSC STATUS,Z  ;Confere se o STATUS est? em 0, se sim, pula a pr?xima instru??o
BSF CONTROLE    ;Seta n?vel l?gico alto no bit de controle
 
 
ATUALIZA 
MOVF CONTADOR,W ;MOve o que est? no CONTADOR para o ACUMULADOR
MOVWF PORTA	;Move o que est? no ACUMULADOR para o PORTA
BTFSS BOTAO	;Confere se o BOTAO est? em 1, se sim, pula a pr?xima instru??o
GOTO $-1	;Volta para a instru??o anterior
GOTO MAIN	;Pula para MAIN

APAGA
BCF PORTB,7     ;Seta RB7 com n?vel l?gico baixo
GOTO FIM
 
ACENDE
BSF PORTB,7	;Seta RB7 com n?vel l?gico alto
GOTO FIM
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
;* FIM DO PROGRAMA * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
END ;OBRIGAT?RIO 



