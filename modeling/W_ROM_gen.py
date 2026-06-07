import math

def float_to_q2_14(val):
    scaled_val = int(round(val * (1 << 14)))
    scaled_val = max(-32768, min(32767, scaled_val)) & 0xFFFF
    return f"{scaled_val:04X}"

N = 64
num_words = 32

with open("W_ROM_real.mem", "w") as real_file, open("W_ROM_imag.mem", "w") as imag_file:
    for i in range(num_words):
        angle = -2.0 * math.pi * i / N

        w_real = math.cos(angle)
        w_imag = math.sin(angle)

        hex_real = float_to_q2_14(w_real)
        hex_imag = float_to_q2_14(w_imag)

        real_file.write(f"{hex_real}\n")
        imag_file.write(f"{hex_imag}\n")


