.data
character:  .byte 0,0
box:        .byte 0,0
target:     .byte 0,0

numPlayersPrompt: .string "\nEnter the number of players: "
standings_title: .string "\n***STANDINGS***\n"
standings_first: .string "Player "
standings_middle: .string " finished the game in "
standings_end: .string " moves\n"
endGame: .string "\nGAME OVER!"
gamePrompt: .string "\nEnter 1 to restart or 0 to exit: "
success: .string "You have successfully placed the box onto the target!\n"
next: .string "\nNEXT PLAYER'S TURN!\n"
playersArr: .word 0x20000000

.globl main
.text

main:
    START:
    li a7, 4
    la a0, numPlayersPrompt
    ecall

    call readInt
    mv s11, a0
    
    li a7, 214
    mv a0, s11
    ecall
    
    bnez a0, exit
    
    jal boardINIT
    
    INIT_OBJECTS:
                
    # Box location
    # Load the address of 'box' into register a3
    la a3, box
    li s1, 1
    li s6, 6

    # Call 'rand' or 'randLCG' to generate random x,y coordinate
    # Store the random x,y coordinate
    
    WHILE_BOX:
    li a0, 6
    jal randLCG
    mv s3, a0

    li a0, 6
    jal randLCG
    mv s4, a0
    
    beq s3, x0, WHILE_BOX # x-coordinate is zero
    beq s4, x0, WHILE_BOX # y-coordinate is zero
    
    beq s3, s1, BOX_ON_EDGE
    beq s3, s6, BOX_ON_EDGE
    j STORE_BOX
    
    BOX_ON_EDGE:
        beq s4, s1, WHILE_BOX
        beq s4, s6, WHILE_BOX
    
    STORE_BOX:
    sb s3, 0(a3) # Store x-coordinate
    sb s4, 1(a3) # Store y-coordinate
    
    
    # Target Location
    # Load the address of 'target' into register a3
    la a3, target

    # Call 'rand' or 'randLCG' to generate random x,y coordinate
    # Store the random x,y coordinate
    
    WHILE_TARGET:
    beq s3, s1, TARGET_ON_EDGE_V
    beq s3, s6, TARGET_ON_EDGE_V
    beq s4, s1, TARGET_ON_EDGE_H
    beq s4, s6, TARGET_ON_EDGE_H
    
    li a0, 6
    jal randLCG
    mv s5, a0

    li a0, 6
    jal randLCG
    mv s6, a0
    
    beq s5, x0, WHILE_TARGET # x-coordinate is zero
    beq s6, x0, WHILE_TARGET # y-coordinate is zero
    
    j COMPARE_TARGET_WITH_BOX
    
    TARGET_ON_EDGE_V:
        mv s5, s3
        
        li a0, 6
        jal randLCG
        mv s6, a0
        j COMPARE_TARGET_WITH_BOX
        
    TARGET_ON_EDGE_H:
        li a0, 6
        jal randLCG
        mv s5, a0
        
        mv s6, s4
    
    COMPARE_TARGET_WITH_BOX:
        bne s3, s5, STORE_TARGET
        bne s4, s6, STORE_TARGET
        j WHILE_TARGET
    
    STORE_TARGET:
    sb s5, 0(a3) # Store x-coordinate
    sb s6, 1(a3) # Store y-coordinat
    
    
    # Player Location
    # Load the address of 'character' into register a3
    la a3, character

    # Call 'rand' or 'randLCG' to generate random x,y coordinate
    # Store the random x,y coordinate
    
    WHILE_PLAYER:
    li a0, 7
    jal rand
    mv s7, a0

    li a0, 7
    jal rand
    mv s8, a0
    
    beq s7, x0, WHILE_PLAYER # x-coordinate is zero
    beq s8, x0, WHILE_PLAYER # y-coordinate is zero
    
    
    COMPARE_PLAYER_WITH_BOX:
        bne s3, s7, COMPARE_PLAYER_WITH_TARGET
        bne s4, s8, COMPARE_PLAYER_WITH_TARGET
        j WHILE_PLAYER
    
    COMPARE_PLAYER_WITH_TARGET:
        bne s5, s7, STORE_PLAYER
        bne s6, s8, STORE_PLAYER
        j WHILE_PLAYER
        
    STORE_PLAYER:
    sb s7, 0(a3) # Store x-coordinate
    sb s8, 1(a3) # Store y-coordinate
    
    
    # TODO: Enter a loop and wait for user input. Whenever user input is 
    # received, update the grid with the new location of the player 
    # (and if applicable, box and target). You will also need to restart the
    # game if the user requests it and indicate when the box is located
    # in the same position as the target.
    
    
    li a3, 0
    MULTIPLAYER_LOOP:
        
    # Calculate current player's address
    la a4, playersArr
    add a4, a4, a3
    
    addi a3, a3, 1
        
    # Reset board
    jal boardINIT
    
    # Load x,y values of character
    la s10, character
    lb s8, 0(s10)
    lb s9, 1(s10)
    
    # Draw character
    li a0, 0xCBC3E3
    mv a1, s8
    mv a2, s9
    jal setLED
    
    # Load x,y values of box
    la s7, box
    lb s4, 0(s7)
    lb s5, 1(s7)
    
    # Draw box
    li a0, 0xD2B48C
    mv a1, s4
    mv a2, s5
    jal setLED
    
    # Load x,y values of target
    la t6, target
    lb t4, 0(t6)
    lb t5, 1(t6)
    
    # Draw target
    li a0, 0xFFFFFF
    mv a1, t4
    mv a2, t5
    jal setLED
    
    # GAME LOOP VARIABLES
    li a5, 0 # <Number of moves> counter
    li s1, 1
    li s2, 2
    li s3, 3
    li s6, 6
    GAME_LOOP:
        
        # Copy inital x,y values of character
        mv a1, s8
        mv a2, s9
        
        jal pollDpad
        
        # Execute command based on input
        beq a0, zero, MOVE_UP
        beq a0, s1, MOVE_DOWN
        beq a0, s2, MOVE_LEFT
        beq a0, s3, MOVE_RIGHT
        
        MOVE_UP:
            beq s9, s1, CONTINUE
            sub s9, s9, s1
            
            bne s8, s4, MOVE_PLAYER
            bne s9, s5, MOVE_PLAYER
            
            beq s5, s1, REVERT_U
            
            sub s5, s5, s1
            j MOVE_PLAYER_AND_BOX
            
            REVERT_U:
                add, s9, s9, s1
                j CONTINUE
            
        MOVE_DOWN:
            beq s9, s6, CONTINUE
            addi s9, s9, 1
            
            bne s8, s4, MOVE_PLAYER
            bne s9, s5, MOVE_PLAYER
            
            beq s5, s6, REVERT_D
            
            addi s5, s5 1
            j MOVE_PLAYER_AND_BOX
            
            REVERT_D:
                sub s9, s9, s1
                j CONTINUE
            
        MOVE_LEFT:
            beq s8, s1, CONTINUE
            sub s8, s8, s1
            
            bne s8, s4, MOVE_PLAYER
            bne s9, s5, MOVE_PLAYER
            
            beq s4, s1, REVERT_L
            
            sub s4, s4, s1
            j MOVE_PLAYER_AND_BOX
            
            REVERT_L:
                add s8, s8, s1
                j CONTINUE
            
        MOVE_RIGHT:
            beq s8, s6, CONTINUE
            addi s8, s8, 1
            
            bne s8, s4, MOVE_PLAYER
            bne s9, s5, MOVE_PLAYER
            
            beq s4, s6, REVERT_R
            
            addi s4, s4, 1
            j MOVE_PLAYER_AND_BOX
            
            REVERT_R:
                sub s8, s8, s1
                j CONTINUE
            
        MOVE_PLAYER:
            
            bne a1, t4, SET_PREV_BLACK
            bne a2, t5, SET_PREV_BLACK
            
            li a0, 0xFFFFFF
            jal setLED
            j SET_PLAYER_LED
            
            SET_PREV_BLACK:
                li a0, 0x000000
                jal setLED
            
            SET_PLAYER_LED:
            li a0, 0xCBC3E3
            mv a1, s8
            mv a2, s9
            jal setLED
            
            j CONTINUE
            
        MOVE_PLAYER_AND_BOX:
            
            bne a1, t4, SET_PREV_BLACK_W_BOX
            bne a2, t5, SET_PREV_BLACK_W_BOX
            
            li a0, 0xFFFFFF
            jal setLED
            j SET_PLAYER_AND_BOX_LED
            
            SET_PREV_BLACK_W_BOX:
                li a0, 0x000000
                jal setLED
                
            SET_PLAYER_AND_BOX_LED:
            # Update character
            li a0, 0xCBC3E3
            mv a1, s8
            mv a2, s9
            jal setLED
            
            # Update box
            li a0, 0xD2B48C
            mv a1, s4
            mv a2, s5
            jal setLED
            
            bne s4, t4, CONTINUE
            bne s5, t5, CONTINUE
            j ROUND_OVER
        
        CONTINUE:
            addi a5, a5, 1
            
            beq s4, s1, BOX_IN_CORNER
            beq s4, s6, BOX_IN_CORNER
            
            j GAME_LOOP
            
            BOX_IN_CORNER:
                beq s5, s1, PROMPT
                beq s5, s6, PROMPT
                
            j GAME_LOOP
            
    ROUND_OVER:
        # Store current player's number of moves
        sb a5, 0(a4)
        
        li a7, 4
        la a0, success
        ecall
        
        li a7, 4
        la a0, next
        ecall
        
        bne a3, s11, MULTIPLAYER_LOOP 

    GAME_OVER:
        
        # Display standings of player_i where i is the current_index+1 of playersArr
        li a7, 4
        la a0, standings_title
        ecall
        
        li s0, 0
        la a4, playersArr
        ARRAY_LOOP:
            add a4, a4, s0
            lb a5, 0(a4)
            addi s0, s0, 1
            
            li a7, 4
            la a0, standings_first
            ecall
            
            li a7, 1
            mv a0, s0
            ecall
            
            li a7, 4
            la a0, standings_middle
            ecall
            
            li a7, 1
            mv a0, a5
            ecall
            
            li a7, 4
            la a0, standings_end
            ecall
            
            bne s0, s11, ARRAY_LOOP
            
        EXIT_LOOP:
        
        # Display end game prompt and wait for input to restart or exit
        li a7, 4
        la a0, endGame
        ecall
        
        PROMPT:
        li a7, 4
        la a0, gamePrompt
        ecall
        
        call readInt
        beq a0, s1, START
    
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit

boardINIT:
    
    sw ra -4(sp)
    
    # RESET_LED_LOOP_INIT
    li a0, 0x000000
    li a2, 0
    li s0, 8
        
    RESET_Y_LOOP:
    # Check if y is greater than 7 (exit the loop if true)
    beq a2, s0, WALL_LED

    li a1, 0  # Initialize x to 0

    RESET_X_LOOP:
    # Check if x is greater than 7 (exit the inner loop if true)
    beq a1, s0, RESET_Y
    
    jal setLED

    # Increment x
    addi a1, a1, 1
    j RESET_X_LOOP

    RESET_Y:
    # Increment y
    addi a2, a2, 1
    j RESET_Y_LOOP
    
    
    WALL_LED:
    
    # WALL_LED_LOOP_INIT
    li a0, 0x800000 # Maroon Wall
    li a2, 0
    li s0, 8
        
    WALL_LED_Y_LOOP:
    # Check if y is greater than 7 (exit the loop if true)
    beq a2, s0, DONE

    li a1, 0  # Initialize x to 0
    li t2, 0 # Initialize temp variable

    WALL_LED_X_LOOP:
    # Check if x is greater than 7 (exit the inner loop if true)
    beq a1, s0, ADD_Y
    beq a2, t2, SET_LED
    bne a1, t2, INCREMENT_X
    
    SET_LED:
    jal setLED

    INCREMENT_X:
    # Increment x
    addi a1, a1, 1
    beq a2, x0, WALL_LED_X_LOOP
    
    UPDATE_TEMP:
    li t2, 7 # Update temp variable to 7
    j WALL_LED_X_LOOP

    ADD_Y:
    addi a2, a2, 1 # Increment y
    j WALL_LED_Y_LOOP
    
    DONE: 
    lw ra -4(sp)
    jr ra

# Takes in a number in a0, and returns a (sort of) (okay not really) random 
# number from 0 to this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    remu a0, a0, t0
    jr ra
    

randLCG:
    # Inputs:
    # a0: upper limit for random number (inclusive)
    
    # Load upper limit into t1
    mv t1, a0

    # Get seed value as system time
    li a7, 30
    ecall
    mv t0, a0

    # LCG parameters
    li t2, 75
    li t3, 74

    # Compute the random number: (t0 * t2 + t3) % t1
    mul t0, t0, t2
    add t0, t0, t3
    remu t0, t0, t1

    # Adjust the result to be between 1 and t1
    addi t0, t0, 1

    # Return the result
    mv a0, t0
    jr ra

    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra

    
readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -2
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret

error:
    li a7, 93
    li a0, 1
    ecall
