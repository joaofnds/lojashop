.data
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
	.word 200                     # price
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
	lw $s0, block_size

	la $a0, inventory
	jal create_item
	nop

	la $a0, inventory
	jal create_item
	nop

	la $a0, prompt_id
	li $v0, 51
	syscall

	or $a1, $zero, $a0
	la $a0, inventory

	jal find_item_by_id
	nop

	or $a0, $zero, $v0
	jal get_item_name
	nop

	or $a0, $zero, $v0
	li $a1, 1
	li $v0, 55
	syscall

	li $v0, 10
	syscall

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
