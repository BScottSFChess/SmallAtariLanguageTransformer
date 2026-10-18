;Small Atari Language Transformer / SALT
;By Brendan Scott / Bree Scott, 2026 onward
;Open source project for the Atari 400 PC



;Bit shift multiplicator code

MultiplyRoutineStart : {           ;Configures and chooses failsafe counter value

          LDX #%00000001                ;Load shift mask
          STX $0700                     ;Save shift mask
           LDX #0                        ;Repeat count
           STX $0703                     ;Save decermenting counter
          JMP MultiplyRoutineSetRepeater ;Determine 0703 value change if needed
     ReturnPoint :
          LDX #0                        ;Load zero
          STX $0704                     ;Reinit output to zero
          STX $0705                      ;Start overflow at zero
          JMP MultiplyRoutineIter       ;Start iter routine
}

MultiplyRoutineSetRepeater : {     ;Sets failsafe counter

          LDA $0701                ;Loads multiplicant
          STA $0706                ;Copies to new location for shifting
          AND #%10000000           ;Compares leftmost bit for a one
          BNE ReturnPoint          ;If one, return
          CLC                       ;Clear carry flag
          JMP JumpLocation         ;Otherwise sart loop
     JumpLocation :
          INC $0703                 ;Decrement counter
          LDA $0706                ;Load copied multiplicant
          ROL A                    ;Rotate left
          STA $0706                ;Save rotated multiplicant
          AND #%10000000           ;Compare last bit
          BNE ReturnPoint           ;If one, stop
          BEQ JumpLocation         ;If zero, retry

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

               LDA $0702                      ;Load preshift multiplicant
               AND #%10000000                 ;Check for future overflow
               STA $0707                      ;Store accumulator for future use
               ASL $0700                     ;Shift for future mask use
               ASL $0702                     ;Shift for future miltiplicand use
               LDA $0707                       ;Recover accumulator
               BNE  MultiplyRoutineCheckOFlow ;Check if larger than 255
          JumpBackPoint :                      ;Reentry to routine
               DEC $0703                     ;Decriment counter
               JMP MultiplyRoutineIter       ;Repeat the process
     }
}

MultiplyRoutineCheckOFlow : {  ;Save overflow flag to memory
     LDY #1                    ;If flag is 1, load 1 to Y
     STY $0705                  ;Store Y
     LDY #0                     ;Reset Y
     JMP JumpBackPoint         ;Go back
}

MultiplyRoutineCompute : {              ;Performs the addition

          LDA $0702                     ;Set accumulator to prior value
          CLC                           ;Clear carry flag to fix addition
          ADC $0704                     ;add number to be multiplied
          BCS MultiplyRoutineOFlowOnAdd ;If adding overfows record it
     ReturnPointAdd :
          STA $0704                     ;Store addition to memory
          LDA #0                        ;Reset accumulator
          JMP MultIterReset             ;Goto prior
}

MultiplyRoutineOFlowOnAdd : {   ;Records overflow on additions

     LDY #1                     ;Loads 1 to Y
     STY $0705                  ;Stores overflow if found
     LDY #0                     ;Resets to 0
     JMP ReturnPointAdd         ;Returns

}

BreakMult : { ;Generic breaking space for the multiplicator
     
}