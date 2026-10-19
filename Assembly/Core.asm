;Small Atari Language Transformer / SALT
;By Brendan Scott / Bree Scott, 2026 onward
;Open source project for the Atari 400 PC



;Bit shift multiplicator code

MultiplyRoutineStart : {           ;Configures and chooses failsafe counter value

          LDA $0701                      ;Load multiplied number to check for a zero
          BEQ MultiplyByZero             ;Immediately output zero if 0701 is zero
          LDA #0                           ;Reset A to zero
          LDX #%00000001                ;Load shift mask
          STX $0700                     ;Save shift mask
           LDX #0                        ;Repeat count
           STX $0703                     ;Save decermenting counter
          JMP MultiplyRoutineSetRepeater ;Determine 0703 value change if needed
     ReturnPoint :
          LDA #8                        ;Load amount of default leading zeros
          CLC                             ;Clear carry
          SBC $0703                     ;Calculate number length
          STA $0703                      ;Save number length
          LDX #0                        ;Load zero
          STX $0704                     ;Reinit output to zero
          STX $0705                      ;Start overflow at zero
          JMP MultiplyRoutineIter       ;Start iter routine
}

MultiplyByZero : { ;Set to 0 if 0701 is zero
     LDX #0        ;Pull zero
     STX $0704     ;Set zero
     JMP Break     ;Exit
}

MultiplyRoutineSetRepeater : {     ;Sets failsafe counter

          LDA $0701                ;Loads multiplicant
          STA $0706                ;Copies to new location for shifting
          AND #%10000000           ;Compares leftmost bit for a one
          BNE ReturnPoint          ;If one, return
          JMP JumpLocation         ;Otherwise sart loop
     JumpLocation :
          CLC                        ;Clear carry
          INC $0703                 ;Incremen counter
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
     BEQ Break                     ;Break on completion
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
     JMP BreakMult              ;Go back and stop
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
     JMP BreakMult              ;Returns to core aystem loop

}

BreakMult : {          ;Begin set answer to aero if overflow
     LDA $0705         ;Get is if overflow
     BNE MultSetToZero ;Goto set zero
     JMP Break         ;Otherwise break
}

MultSetToZero : {    ;Set to zero if overflow
     LDA #0          ;Load zero
     STA $0704       ;Set to zero
     JMP BreakLooper. ;Goto idle system loop
}

BreakLooper : {       ;Idle system loop
     JMP BreakLooper
}