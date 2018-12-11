.data

menu:
	.asciiz "0. sair\n1. inserir item\n2. procurar item\n3. mostrar inventário\n"

id_string:
	.asciiz "\n\nid:         "

quantity_string:
	.asciiz "\nquantidade: "

price_string:
	.asciiz "\npreço:      R$ "

name_string:
	.asciiz "\nnome:       "

comma_string:
	.asciiz ","

message_item_not_found:
	.asciiz "item não encontrado\n"

prompt_id:
	.asciiz "digite o id"

prompt_quantity:
	.asciiz "digite a quantitade"

prompt_price:
	.asciiz "digite o preco"

prompt_name:
	.asciiz "digite o nome"

block_size:
	.word 0x20

# +---------+---------------+------------+------------+
# | id (4B) | quantity (4B) | price (4B) | name (20B) |
# +---------+---------------+------------+------------+

inventory:
	.word 1                       # id
	.word 2                       # quantity
	.word 150                     # price
	.asciiz "coca caçulinha     " # name

	.word 2                       # id
	.word 20                      # quantity
	.word 800                     # price
	.asciiz "coca de litrao     " # name

	.word 3                       # id
	.word 30                      # quantity
	.word 1000                    # price
	.asciiz "coca de litrao mega" # name

.text

.globl main

main:
	lw $s0, block_size

	main_loop:
		la $a0, menu
		li $v0, 51
		syscall

		beqz $a0, exit_main
		nop

		li $t0, 1
		beq $a0, $t0, handle_item_insertion
		nop

		li $t0, 2
		beq $a0, $t0, handle_search_item
		nop

		li $t0, 3
		beq $a0, $t0, handle_show_inventory
		nop

		j main_loop
		nop

	exit_main:
		li $v0, 10
		syscall

handle_item_insertion:
	la $a0, inventory
	jal create_item
	nop

	j main_loop
	nop

handle_search_item:
	la $a0, prompt_id
	li $v0, 51
	syscall

	or $a1, $zero, $a0
	la $a0, inventory
	jal find_item_by_id
	nop

	beqz $v0, hsi_item_not_found
	nop

	# item found
	or $a0, $zero, $v0
	jal display_item
	nop

	j main_loop
	nop

	hsi_item_not_found:
		la $a0, message_item_not_found
		li $a1, 0
		li $v0, 55
		syscall

		j main_loop
		nop

handle_show_inventory:
	la $t0, inventory
	subi $sp, $sp, 4
	sw $t0, 0($sp)

	hsi_loop:
		lw $t1, 0($t0)

		beqz $t1, hsi_exit
		nop

		or $a0, $zero, $t0
		jal display_item
		nop

		lw $t0, 0($sp)
		add $t0, $t0, $s0
		sw $t0, 0($sp)

		j hsi_loop
		nop
	hsi_exit:
		addi $sp, $sp, 4

		li $v0, 8
		or $a0, $zero, $t0
		li $a1, 1
		syscall

		j main_loop
		nop

# find_item_by_id(*inventory, item_id): (*item | null)
find_item_by_id:
	or $t0, $zero, $a0 # current item
	# $a1 item_id to find
	fibi_loop:
		lw $t1, 0($t0)
		beq $a1, $t1, fibi_exit
		nop

		beqz $t1, fibi_exit
		nop

		add $t0, $t0, $s0

		j fibi_loop
		nop
	fibi_exit:
		or $v0, $zero, $t0
		jr $ra
		nop

# create_item(*inventory) null
create_item:
	# a0 = *inventory
	# push($ra)
	subi $sp, $sp, 4
	sw $ra, 0($sp)

	jal new_item_address
	nop

	# push(*new_item)
	subi $sp, $sp, 4
	sw $v0, 0($sp)

	lw $a0, 0($sp)
	jal prompt_and_store_item_id
	nop

	lw $a0, 0($sp)
	jal prompt_and_store_item_quantity
	nop

	lw $a0, 0($sp)
	jal prompt_and_store_item_price
	nop

	lw $a0, 0($sp)
	jal prompt_and_store_item_name
	nop

	# pop()
	addi $sp, $sp, 4

	# $ra = pop()
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
	nop

# new_item_address(*inventory) *item
new_item_address:
	nia_loop:
		lw $t1, 0($a0)

		beqz $t1, nia_exit
		nop

		add $a0, $a0, $s0

		j nia_loop
		nop

	nia_exit:
		or $v0, $zero, $a0
		jr $ra
		nop

get_item_id:
	# $a0 item pointer
	lw $v0, 0($a0)
	jr $ra
	nop

get_item_quantity:
	# $a0 item pointer
	lw $v0, 4($a0)
	jr $ra
	nop
get_item_price:
	# $a0 item pointer
	lw $v0, 8($a0)
	jr $ra
	nop

get_item_name:
	# $a0 item pointer
	la $v0, 12($a0)
	jr $ra
	nop

# store_item_id(*item, id)
store_item_id:
	sw $a1, 0($a0)
	jr $ra
	nop

# store_item_quantity(*item, quantity)
store_item_quantity:
	sw $a1, 4($a0)
	jr $ra
	nop

# store_item_price(*item, price)
store_item_price:
	sw $a1, 8($a0)
	jr $ra
	nop

# store_item_name(*item, *name)
store_item_name:
	sw $a1, 8($a0)
	jr $ra
	nop

# prompt_and_store_item_id(*item)
prompt_and_store_item_id:
	or $t0, $zero, $a0

	la $a0, prompt_id
	li $v0, 51
	syscall

	sw $a0, 0($t0)

	jr $ra
	nop

# prompt_and_store_item_quantity(*item)
prompt_and_store_item_quantity:
	or $t0, $zero, $a0

	la $a0, prompt_quantity
	li $v0, 51
	syscall

	sw $a0, 4($t0)

	jr $ra
	nop

# prompt_and_store_item_price(*item)
prompt_and_store_item_price:
	or $t0, $zero, $a0

	la $a0, prompt_price
	li $v0, 51
	syscall

	sw $a0, 8($t0)

	jr $ra
	nop

# prompt_and_store_item_name(*item)
prompt_and_store_item_name:
	or $t0, $zero, $a0

	la $a0, prompt_name
	addi $a1, $t0, 12
	li $a2, 20
	li $v0, 54
	syscall

	jr $ra
	nop

# display_item(*item)
display_item:
	or $t0, $zero, $a0

	# print(item->id)
	la $a0, id_string
	li $v0, 4
	syscall

	lw $a0 0($t0)
	li $v0, 1
	syscall

	# print(item->quantity)
	la $a0, quantity_string
	li $v0, 4
	syscall

	lw $a0 4($t0)
	li $v0, 1
	syscall

	# print(item->price)
	la $a0, price_string
	li $v0, 4
	syscall

	# $a0 = item->price (in cents)
	lw $a0 8($t0)

	div $a0, $a0, 100
	li $v0, 1
	syscall

	la $a0, comma_string
	li $v0, 4
	syscall

	mfhi $a0
	li $v0, 1
	syscall

	# print(item->name)
	la $a0, name_string
	li $v0, 4
	syscall

	la $a0, 12($t0)
	li $v0, 4
	syscall

	jr $ra
	nop
