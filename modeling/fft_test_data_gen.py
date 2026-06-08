import math
import numpy as np

def float_to_q1_15(val):
    scaled_val = int(round(val * (1 << 15)))
    scaled_val = max(-32768, min(32767, scaled_val)) & 0xFFFF
    return f"{scaled_val:04X}"

def float_to_q6_10(val):
    scaled_val = int(round(val * (1 << 10)))
    scaled_val = max(-32768, min(32767, scaled_val)) & 0xFFFF
    return f"{scaled_val:04X}"

def write_to_files(in_i, in_q, inverse, real_path, imag_path):
    with open(real_path, "w") as real_file, open(imag_path, "w") as imag_file:
        for i in in_i:
            scaled = 0
            if(not inverse):
                scaled = float_to_q1_15(i)
            else:
                scaled = float_to_q6_10(i)

            real_file.write(scaled+"\n")

        for i in in_q:
            scaled = 0
            if(not inverse):
                scaled = float_to_q1_15(i)
            else:
                scaled = float_to_q6_10(i)

            imag_file.write(scaled+"\n")

N = 64

#all 0 test
i_list = np.zeros(N)
q_list = np.zeros(N)
write_to_files(i_list, q_list, False, "testdata/fft_test_zeroes_real.txt", "testdata/fft_test_zeroes_imag.txt")

#constant dc test
i_list = np.ones(N)
write_to_files(i_list, q_list, False, "testdata/fft_test_dc_real.txt", "testdata/fft_test_dc_imag.txt")

#single freqeucny wave, 4 cycles
for i in range(N):
    i_list[i] = np.sin(2 * np.pi * 4 / N * i)

write_to_files(i_list, q_list, False, "testdata/fft_test_sine_real.txt", "testdata/fft_test_sine_imag.txt")

#single phasor, 4 cycles
for i in range(N):
    i_list[i] = np.cos(2 * np.pi * 4 / N * i)
    q_list[i] = np.sin(2 * np.pi * 4 / N * i)

write_to_files(i_list, q_list, False, "testdata/fft_test_phasor_real.txt", "testdata/fft_test_phasor_imag.txt")

#overflow prevention
for i in range(N):
    if(i % 2):
        i_list[i] = -1.0
    else:
        i_list[i] = 0.999969
q_list = np.zeros(N)
write_to_files(i_list, q_list, False, "testdata/fft_test_overflow_real.txt", "testdata/fft_test_overflow_imag.txt")

#linear superposition
for i in range(N):
    i_list[i] = np.cos(2 * np.pi * 2 / N * i) + np.cos(2 * np.pi * 8 / N * i)
    q_list[i] = np.sin(2 * np.pi * 2 / N * i) + np.sin(2 * np.pi * 8 / N * i)

write_to_files(i_list, q_list, False, "testdata/fft_test_superposition_real.txt", "testdata/fft_test_superposition_imag.txt")

#single spike
i_list = [0.999969] + [0.0]*63
q_list = np.zeros(N)
write_to_files(i_list, q_list, False, "testdata/fft_test_spike_real.txt", "testdata/fft_test_spike_imag.txt")

#single frequency inverse
i_list = [0.0]*3 + [0.999969] + [0.0]*(N-9) + [0.999969] + [0.0]*4
q_list = np.zeros(N)
write_to_files(i_list, q_list, True, "testdata/ifft_test_sine_real.txt", "testdata/ifft_test_sine_imag.txt")

#single phasor inverse
i_list = [0.0]*3 + [0.999969] + [0.0]*(N-4)
q_list = np.zeros(N)
write_to_files(i_list, q_list, True, "testdata/ifft_test_phasor_real.txt", "testdata/ifft_test_phasor_imag.txt")

#superposition inverse
i_list = np.zeros(N)
q_list = np.zeros(N)

i_list[2] = 0.5
q_list[2] = 0.5
i_list[8] = 0.5
q_list[8] = 0.5
write_to_files(i_list, q_list, True, "testdata/ifft_test_superposition_real.txt", "testdata/ifft_test_superposition_imag.txt")

#flat spectrum
i_list = [1.0 / N]*N
q_list = np.zeros(N)
write_to_files(i_list, q_list, True, "testdata/ifft_test_flat_real.txt", "testdata/ifft_test_flat_imag.txt")
