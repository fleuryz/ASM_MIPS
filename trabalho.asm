.data
bitmap_addres: .space 0x80000
menu: .asciiz "1. Carregar Arquivo. \n2. Inverter Componente.\n3. Zerar Componente.\n0. Sair\n"
pergunta_altura: .asciiz "Qual a altura de sua imagem?\n"
pergunta_largura: .asciiz "Qual a largura de sua imagem?\n"
ops: .asciiz "1. Vermelho.\n2. Verde.\n3. Azul.\n"
erro_ler: .asciiz "Erro de leitura. Encerrando programa.\n"
sucesso_ler: .asciiz "Leitura feita com sucesso.\n"
entrada: .asciiz "entrou\n"
imagem: .asciiz "imagem2.txt"
escolha: .word 4
altura: .word 4
largura: .word 4
tamanho_imagem: .word 4
buffer: .word 4
.

.text
main:

	move $s0, $zero	#zerar o registrador s0
	move $s1, $zero	#zerar o registrador s1
	
	la $a0, menu
	li $v0, 4
	syscall	#Imprimir o menu
	
	la $a0, escolha
	la $a1, escolha
	li $v0, 8
	syscall	#Buscar a opcao
	
	lw $t0, escolha
	
	beq $t0, 0xa31, carregar	#chamar funçao carregar
	beq $t0, 0xa32, inverter	#chamar funcao inverter
	beq $t0, 0xa33, zerar		#chamar funcao zerar
	beq $t0, 0xa30, encerra		#finalizer o programa

	j main
	
	
carregar:
	la $a0, pergunta_altura
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	sw $v0, altura		#salvar a altura em memoria
	
	move $s0, $v0		#Salvar a altura em s0
	
	la $a0, pergunta_largura
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	sw $v0, largura		#Salvar a largura em memoria
	
	move $s1, $v0		#salvar a largura em s1
	
	addi $s2, $zero, 512
	sub $s2, $s2, $s1	#salvar a diferenca da largura total e a largura da imagem
	sll $s2, $s2, 2		#multiplicar por 4 por contar dos bytes
	
	mult $s0, $s1	
	mflo $t0	
	addi $t1, $zero, 6
	mult $t0, $t1
	mflo $t0	#salvar o tamanho da imagem quando ainda no arquivo de texto. para cada byte da imagem serão necessários 6 bytes de leitura.

	la $a0, imagem
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	move $s6, $v0		#abrir arquivo de imagem

	move $a0, $s6
	la $a1, buffer
	lw $a2,$t0		#preparar a memória para a imagem
	
leitura:
	li $v0, 14
	syscall		#Salvar a imagem em memória
	
	beqz $v0, sucesso_leitura
	bltz $v0, erro_leitura
	addu $a1, $a1, $v0
	subu $a2, $a2, $v0
	bnez $a2, leitura
	
sucesso_leitura:
	la $a0, sucesso_ler
	li $v0, 4
	syscall
	j fim_leitura
	
erro_leitura:
	la $a0, erro_ler
	li $v0, 4
	syscall
	j fim_leitura
	
fim_leitura:
	move $a0, $s6
	li $v0, 16
	syscall
	move $s0, $zero
	move $s1, $zero
	j char2hex
	
char2hex:
	bge $t3, $s2, main 		#verificar se totas as linhas foram escritas
	bge $t4, $s3, pula_linha 	#verificar se ja foi preenchida a linha da imagem

	addi $t2, $zero, 0
	lw $t1, buffer($s1)
	addi $s1, $s1, 4
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 28
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 24
	or $t2, $v0, $t2 
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 20
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 16
	or $t2, $v0, $t2

	lw $t1, buffer($s1)
	addi $s1, $s1, 4
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 12
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 8
	or $t2, $v0, $t2 
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 4
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	or $t2, $v0, $t2
	
	sw $t2, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	bge $t4, $s3, pula_linha 	#verificar se ja foi preenchida a linha da imagem
	
	
	addi $t2, $zero, 0
	lw $t1, buffer($s1)
	addi $s1, $s1, 4
	srl $t1, $t1, 16
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 28
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 24
	or $t2, $v0, $t2
	
	lw $t1, buffer($s1)
	addi $s1, $s1, 4
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 20
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 16
	or $t2, $v0, $t2 
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 12
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 8
	or $t2, $v0, $t2
	
	lw $t1, buffer($s1)
	addi $s1, $s1, 4
	andi $a0, $t1, 0xff
	jal get_hex
	sll $v0, $v0, 4
	or $t2, $v0, $t2
	srl $t1, $t1, 8
	andi $a0, $t1, 0xff
	jal get_hex
	or $t2, $v0, $t2 

	sw $t2, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	j char2hex
	
pula_linha:
	
	move $t4, $zero
	add $s0, $s0, $s4
	addi $t3, $t3, 1

	j char2hex
	
	
	
get_hex:
	beq $a0, 0x30,hex0
	beq $a0, 0x31,hex1
	beq $a0, 0x32,hex2
	beq $a0, 0x33,hex3
	beq $a0, 0x34,hex4
	beq $a0, 0x35,hex5
	beq $a0, 0x36,hex6
	beq $a0, 0x37,hex7
	beq $a0, 0x38,hex8
	beq $a0, 0x39,hex9
	beq $a0, 0x41,hexA
	beq $a0, 0x42,hexB
	beq $a0, 0x43,hexC
	beq $a0, 0x44,hexD
	beq $a0, 0x45,hexE
	beq $a0, 0x46,hexF
retorno_get_hex:
	jr $ra
	
hex0:
	addi $v0, $zero, 0x0
	j retorno_get_hex

hex1:
	addi $v0, $zero, 0x1
	j retorno_get_hex
	
hex2:
	addi $v0, $zero, 0x2
	j retorno_get_hex

hex3:
	addi $v0, $zero, 0x3
	j retorno_get_hex

hex4:
	addi $v0, $zero, 0x4
	j retorno_get_hex

hex5:
	addi $v0, $zero, 0x5
	j retorno_get_hex

hex6:
	addi $v0, $zero, 0x6
	j retorno_get_hex

hex7:
	addi $v0, $zero, 0x7
	j retorno_get_hex

hex8:
	addi $v0, $zero, 0x8
	j retorno_get_hex

hex9:
	addi $v0, $zero, 0x9
	j retorno_get_hex

hexA:
	addi $v0, $zero, 0xA
	j retorno_get_hex

hexB:
	addi $v0, $zero, 0xB
	j retorno_get_hex

hexC:
	addi $v0, $zero, 0xC
	j retorno_get_hex

hexD:
	addi $v0, $zero, 0xD
	j retorno_get_hex

hexE:
	addi $v0, $zero, 0xE
	j retorno_get_hex

hexF:
	addi $v0, $zero, 0xF
	j retorno_get_hex

	
inverter:

	move $t3, $zero
	move $t4, $zero

	la $a0, ops
	li $v0, 4
	syscall
	
	la $a0, escolha
	la $a1, escolha
	li $v0, 8
	syscall
	
	lw $t0, escolha
	
	beq $t0, 0xa31, invert_r
	beq $t0, 0xa32, invert_g
	beq $t0, 0xa33, invert_b

	j main
	
invert_r:
	bge $t3, $s2, main 			#verificar se totas as linhas foram escritas
	bge $t4, $s3, pula_linha_invert_r	#verificar se ja foi preenchida a linha da imagem
	
	lw $t0, bitmap_addres($s0)
	not $t1, $t0
	andi $t1, $t1, 0x00ff0000
	andi $t0, $t0, 0xff00ffff
	or $t0, $t0, $t1
	sw $t0, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	j invert_r

pula_linha_invert_r:
	
	move $t4, $zero
	add $s0, $s0, $s4
	addi $t3, $t3, 1

	j invert_r

invert_g:
	bge $t3, $s2, main 			#verificar se totas as linhas foram escritas
	bge $t4, $s3, pula_linha_invert_g 	#verificar se ja foi preenchida a linha da imagem
	
	lw $t0, bitmap_addres($s0)
	not $t1, $t0
	andi $t1, $t1, 0x0000ff00
	andi $t0, $t0, 0xffff00ff
	or $t0, $t0, $t1
	sw $t0, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	j invert_g
	
pula_linha_invert_g:
	
	move $t4, $zero
	add $s0, $s0, $s4
	addi $t3, $t3, 1

	j invert_g
	
invert_b:
	bge $t3, $s2, main 			#verificar se totas as linhas foram escritas
	bge $t4, $s3, pula_linha_invert_b 	#verificar se ja foi preenchida a linha da imagem
	
	lw $t0, bitmap_addres($s0)
	not $t1, $t0
	andi $t1, $t1, 0x000000ff
	andi $t0, $t0, 0xffffff00
	or $t0, $t0, $t1
	sw $t0, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	j invert_b
	
pula_linha_invert_b:
	
	move $t4, $zero
	add $s0, $s0, $s4
	addi $t3, $t3, 1

	j invert_b
	
zerar:

	move $t3, $zero
	move $t4, $zero

	la $a0, ops
	li $v0, 4
	syscall
	
	la $a0, escolha
	la $a1, escolha
	li $v0, 8
	syscall
	
	lw $t0, escolha
	
	beq $t0, 0xa31, zerar_r
	beq $t0, 0xa32, zerar_g
	beq $t0, 0xa33, zerar_b

	j main
	
zerar_r:
	bge $t3, $s2, main 			#verificar se totas as linhas foram escritas
	bge $t4, $s3, pula_linha_zerar_r 	#verificar se ja foi preenchida a linha da imagem
	
	lw $t0, bitmap_addres($s0)
	andi $t0, $t0, 0xff00ffff
	sw $t0, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	j zerar_r
	
pula_linha_zerar_r:
	
	move $t4, $zero
	add $s0, $s0, $s4
	addi $t3, $t3, 1

	j zerar_r
	
zerar_g:
	bge $t3, $s2, main 			#verificar se totas as linhas foram escritas
	bge $t4, $s3, pula_linha_zerar_g 	#verificar se ja foi preenchida a linha da imagem
	
	lw $t0, bitmap_addres($s0)
	andi $t0, $t0, 0xffff00ff
	sw $t0, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	j zerar_g
	
pula_linha_zerar_g:
	
	move $t4, $zero
	add $s0, $s0, $s4
	addi $t3, $t3, 1

	j zerar_g
	
zerar_b:
	bge $t3, $s2, main 			#verificar se totas as linhas foram escritas
	bge $t4, $s3, pula_linha_zerar_b 	#verificar se ja foi preenchida a linha da imagem
	
	lw $t0, bitmap_addres($s0)
	andi $t0, $t0, 0xffffff00
	sw $t0, bitmap_addres($s0)
	addi $s0, $s0, 4
	addi $t4, $t4, 1
	
	j zerar_b
	
pula_linha_zerar_b:
	
	move $t4, $zero
	add $s0, $s0, $s4
	addi $t3, $t3, 1

	j zerar_b
	
encerra:
	li $v0, 10
	syscall
	
