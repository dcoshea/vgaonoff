;;; Copyright 2024 David O'Shea
;;;
;;; VGAONOFF is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; VGAONOFF is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with VGAONOFF. If not, see
;;; <https://www.gnu.org/licenses/>.

        .MODEL tiny

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .DATA

;;; Main

usage   DB 'Usage: VGAONOFF [ON|OFF]', 13, 10
        DB 'Version 0.2', 13, 10
        DB 'https://github.com/dcoshea/vgaonoff', 13, 10
        DB '$'

no_vga_message  DB 'Fatal error: VGA not detected', 13, 10
                DB '$'

on_command              DB 'ON', 13
on_command_len          EQU $ - on_command
off_command             DB 'OFF'
off_command_len         EQU $ - off_command

psp_cmd_tail_ofs        EQU 81h ; Start of command-line tail in PSP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .CODE

        ORG 100h                ; .COM starting offset - reserve space for PSP

main:
        ;; Check for VGA
        mov ax, 1a00h
        int 10h                 ; get display combination code
        cmp al, 1ah
        jne vga_absent          ; function not supported
        ;; As per Ralf Brown's Interrupt List 61, the above function
        ;; may indicate that VGA is present for the ATI EGA Wonder, so
        ;; use the recommended procedure to rule out that card.
        mov ax, 1c00h
        int 10h                 ; get save/restore video state buffer size
        cmp al, 1ch
        je vga_present          ; function IS supported
        ;; fall through

vga_absent:
        mov dx, OFFSET no_vga_message
        mov ah, 09h             ; print string
        int 21h
        jmp exit_error

vga_present:
        cld

        ;; Process command line
        mov si, psp_cmd_tail_ofs
        lodsb
        ;; Tail must start with a space as subcommands don't have '/'
        ;; prefixes.
        cmp al, ' '
        jne print_usage

        ;; Normalise command-line tail to uppercase
        mov di, si              ; DS:SI = ES:DI
        ;; Normalise the entire command-line tail buffer rather than
        ;; worrying about whether the expected terminating CR is
        ;; actually present.  Subtract 1 for the space check already
        ;; performed above.
        mov cx, OFFSET main - psp_cmd_tail_ofs - 1
upcase_loop:
        lodsb
        cmp al, 'a'
        jl upcase_char_done
        cmp al, 'z'
        jg upcase_char_done
        ;; character is in range ['a', 'z']
        xor al, 20h             ; convert lowercase to uppercase
upcase_char_done:
        stosb
        loop upcase_loop

        ;; Determine which subcommand was requested
upcase_done:
        mov si, psp_cmd_tail_ofs + 1
        mov di, OFFSET on_command
        mov cx, on_command_len
        repe cmpsb
        je turn_on

        mov si, psp_cmd_tail_ofs + 1
        mov di, OFFSET off_command
        mov cx, off_command_len
        repe cmpsb
        je turn_off

        ;; Unrecognised subcommand, fall through to print usage message

print_usage:
        mov dx, OFFSET usage
        mov ah, 09h             ; print string
        int 21h
exit_error:
        mov al, 0ffh            ; errorlevel 255
exit:
        mov ah, 4ch             ; exit program, errorlevel 255
        int 21h

        ;; Determine desired value for RAM Enable bit
turn_on:
        mov ah, 02h
        jmp set_ram_enable
turn_off:
        xor ah, ah
        ;; fall through

set_ram_enable:
        mov dx, 3cch            ; VGA Miscellaneous Output Register - read address
        in  al, dx
        and al, 0fdh            ; mask out RAM Enable bit
        or  al, ah              ; apply desired value to RAM Enable bit
        mov dx, 3c2h            ; VGA Miscellaneous Output Register - write address
        out dx, al

        xor al, al              ; errorlevel 0
        jmp exit

        END main
