import numpy as np
import matplotlib.pyplot as plt

from fixedpoint import *

#params
plt.style.use('dark_background')
N = 64
CP = 16
mod_order = 2
num_symbols = 20

#Transmitter

#QPSK map
bits = np.random.randint(0, 2, num_symbols * N * mod_order)
matrix = bits.reshape(num_symbols, N * mod_order)

tx_signal = np.array([], dtype=complex)
all_rx_fxp = np.array([], dtype=complex)
rx_bits = []

for i in range(num_symbols):
    curr_bits = matrix[i, :]

    i = curr_bits[::2]
    q = curr_bits[1::2]
    qpsk_symbols = ((1 - 2*i) + 1j * (1 - 2*q)) * 0.707
    qpsk_fxp = quantize(qpsk_symbols, wordlength=16, fraclength=15)

    #IFFT
    time_symbol = np.fft.ifft(qpsk_fxp, N)
    time_fxp = quantize(time_symbol, wordlength=16, fraclength=13)

    cp_list = time_fxp[-CP:]
    tx_signal = np.concatenate([tx_signal, cp_list, time_fxp])

#Noise to emulate RF signal noise
#scale the noise to the signal power or else its random scatter
SNR_dB = 20
sig_power = np.mean(np.abs(tx_signal) ** 2)
noise_power = sig_power / (10 ** (SNR_dB / 10))
sigma = np.sqrt(noise_power / 2)
noise = sigma * (np.random.randn(len(tx_signal)) + 1j*np.random.randn(len(tx_signal)))
rx_signal = tx_signal + noise

#Reciever (we will recieve the transmitted signal with the added noise)

length = N + CP
for i in range(num_symbols):
    curr_rx = rx_signal[i * length : (i + 1) * length]

    true_rx = curr_rx[CP:CP+N]
    rx_qpsk = np.fft.fft(true_rx, N)
    rx_fxp = quantize(rx_qpsk, wordlength=16, fraclength=15)
    all_rx_fxp = np.concatenate([all_rx_fxp, rx_fxp])

    rx_i = (np.real(rx_fxp) < 0).astype(int)
    rx_q = (np.imag(rx_fxp) < 0).astype(int)

    rx_symbol_bits = np.empty(curr_bits.shape, dtype=int)
    rx_symbol_bits[::2] = rx_i
    rx_symbol_bits[1::2] = rx_q
    rx_bits.extend(rx_symbol_bits)

#Constellation plot !
total_errors = np.sum(bits != rx_bits)
print(f"Total Transmitted Bits: {len(bits)}")
print(f"Total Bit Errors: {total_errors}")
print(f"BER: {total_errors / len(bits)}")

# Plot all 640 received subcarrier points
plt.scatter(np.real(all_rx_fxp), np.imag(all_rx_fxp), color='cyan', s=10, alpha=0.7)
plt.title(f"Received QPSK Constellation ({num_symbols} OFDM Symbols)")
plt.xlabel('In-Phase (I)', fontsize=11, fontweight='bold')
plt.ylabel('Quadrature (Q)', fontsize=11, fontweight='bold')
plt.grid(True, alpha=0.3)
plt.show()