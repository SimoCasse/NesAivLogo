.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014

.define SPRITE_X $02
.define SPRITE_Y $03

.define JOYPAD1 $4016
.define JOYPAD2 $4017

.define SCROLL_X $00
.define buttons $01

start:
    LDA #%10010000
    STA PPUCTRL
    LDA #%00011110
    STA PPUMASK
    
    ; load background palette
    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR

    LDA #$15
    STA PPUDATA
    LDA #$22
    STA PPUDATA
    LDA #$23
    STA PPUDATA
    LDA #$0F
    STA PPUDATA

     ; load aiv logo on nametables
    LDA #$20
    STA PPUADDR
    LDA #0
    STA PPUADDR
    JSR Load_aiv_logo
    LDA #$24
    STA PPUADDR
    LDA #0
    STA PPUADDR
    JSR Load_aiv_logo

    ; load first sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$21
    STA PPUDATA
    LDA #$22
    STA PPUDATA
    LDA #$23
    STA PPUDATA
    LDA #$24
    STA PPUDATA

    ; load second sprite palette
    LDA #$16
    STA PPUDATA
    LDA #$17
    STA PPUDATA
    LDA #$18
    STA PPUDATA
    LDA #$19
    STA PPUDATA

    ; load background tiles
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDA #$02
    STA PPUDATA
    LDA #$FD
    STA PPUDATA
    LDA #$FE
    STA PPUDATA

    LDA #0
    STA OAMADDR
    LDA #104
    STA OAMDATA
    STA SPRITE_Y
    LDA #$02
    STA OAMDATA
    LDA #%10000001
    STA OAMDATA
    LDA #116
    STA OAMDATA
    STA SPRITE_X



Load_aiv_logo:
    LDX #0
    LDY #0
    LDA #$10  
    STA $10    
    STA $11
    
first_loop:
    STX PPUDATA
    INX
    DEC $10
    BNE first_loop
    STA $10

second_loop:
    STY PPUDATA
    DEC $10
    BNE second_loop
    STA $10
    DEC $11
    BNE first_loop
    RTS    


loop:
    JMP loop


readjoy:
    LDA #$01
    STA JOYPAD1
    STA buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A 
    ROL buttons
    BCC joyloop
    RTS


nmi:
    PHA
    JSR readjoy ; read input each nmi
    LDA buttons
    ; reject up+down and left+right
    AND #%00001010    
    LSR A
    AND buttons  
    BEQ Left_check
    PLA
    RTI


Left_check:
    LDA buttons
    AND #%00000010  
    BEQ Right_check
    DEC SCROLL_X
    DEC SCROLL_X
    JSR Move_left


Up_check:
    LDA buttons
    AND #%00001000  
    BEQ Down_check
    JSR Move_up

Down_check:
    LDA buttons
    AND #%00000100  
    BEQ Update_scroll
    JSR Move_down

Right_check:
    LDA buttons
    AND #%00000001  
    BEQ Up_check
    INC SCROLL_X
    INC SCROLL_X
    JSR Move_right


Update_scroll:
    JMP loadscroll



Move_left:
    LDA SPRITE_X
    CMP #0
    BEQ Return_L
    DEC SPRITE_X
    LDA #3
    STA OAMADDR
    LDA SPRITE_X
    STA OAMDATA
Return_L:
    RTS


Move_right:
    LDA SPRITE_X
    CMP #247
    BEQ Return_R
    INC SPRITE_X
    LDA #3
    STA OAMADDR
    LDA SPRITE_X
    STA OAMDATA
Return_R:
    RTS


Move_up:
    LDA SPRITE_Y
    CMP #8
    BEQ Return_U
    DEC SPRITE_Y
    LDA #0
    STA OAMADDR
    LDA SPRITE_Y
    STA OAMDATA
Return_U:
    RTS


Move_down:
    LDA SPRITE_Y
    CMP #222
    BEQ Return_D
    INC SPRITE_Y
    LDA #0
    STA OAMADDR
    LDA SPRITE_Y
    STA OAMDATA
Return_D:
    RTS


loadscroll:
    LDA SCROLL_X
    STA PPUSCROLL
    LDA #0
    STA PPUSCROLL
    RTI

irq:
    RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin mario0.chr
.incbin aiv256.chr