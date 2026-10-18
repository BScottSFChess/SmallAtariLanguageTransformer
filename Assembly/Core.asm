;Small Atari Language Transformer / SALT
;By Brendan Scott / Bree Scott, 2026 onward
;Open source project for the Atari 400 PC



;Bit shift multiplicator code

MultiplyRoutineStart : {     ;Configures and makes first comparison

     LDX #%00000001          ;Load shift mask
     STX $0700               ;Save shift mask
     LDX #8                  ;Repeat count
     STX $0703               ;Save decermenting counter
     LDA $0701               ;Get multiplicant
     AND $0700               ;Compare with mask
     STA $0705                ;Keep comparison in memory
     LDA #0                   ;Reset accumulator
     JMP MultiplyRoutineIter ;Start iter routine
}

MultiplyRoutineIter :              ;Checks for eighth run and performs
                                    ;branching logic, after comparing again

     LDA $0703                     ;Load countdown
     BEQ BreakMult                  ;Break on completion
     LDA $0701                      ;Load multiplicant
     AND $0700                      ;Compare with mask
     BNE MultiplyRoutineCompute    ;Add number to be multiplied
                                   ;when the mask matches the multiplicant bit
     JMP MultIterReset             ;Just in case its wanting to be terse

     MultIterReset : {                  ;Resets for next shift comparison

               ASL $0700                     ;Shift for future mask use
               ASL $0702                     ;Shift for future miltiplicand use
               BVS  MultiplyRoutineCheckOFlow ;Check if larger than 255
          JumpBackPoint :                      ;Reentry to routine
               DEC $0703                     ;Decriment counter
               JMP MultiplyRoutineIter       ;Repeat the process
     }
}

MultiplyRoutineCheckOFlow : {  ;Save overflow flag to memory
     LDY #1                    ;If flag is 1, load 1 to Y
     STY $0706                  ;Store Y
     LDY #0                     ;Reset Y
     JMP JumpBackPoint         ;Go back
}

MultiplyRoutineCompute : {    ;Performs the addition

     LDA #0702                ;Set accumulator to prior value
     CLC                      ;Clear carry flag to fix addition
     ADC $0704                ;add number to be multiplied
     STA $0704                ;Store addition to memory
     LDA #0                   ;Reset accumulator
     JMP MultIterReset        ;Goto prior
}

BreakMult : { ;Generic breaking space for the multiplicator
     
}