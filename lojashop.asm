.data
prompt_id:
	.asciiz "digite o id"

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
	la $a0, prompt_id
	li $v0, 51
	syscall

	or $a1, $zero, $a0
	la $a0, inventory

	jal find_item_by_id
	nop

	or $a0, $zero, $v0
	jal get_item_name

	or $a0, $zero, $v0
	li $v0, 4
	syscall

	li $v0, 10
	syscall

# find_item_by_id(*inventory, item_id): (*item | null)
find_item_by_id:
	or $t0, $zero, $a0 # current item
	# $a1 item_id to find
	loop:
		lw $t1, 0($t0)
		beq $a1, $t1, exit
		nop

		beqz $t1, exit
		nop

		addi $t0, $t0, 0x20

		j loop
		nop
	exit:
		or $v0, $zero, $t0
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