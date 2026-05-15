import numpy as np
import matplotlib.pyplot as plt

#params
plt.style.use('dark_background')
N = 64
CP = 16
mod_order = 2
num_symbols = 10

#Transmitter

#QPSK map
bits = np.random.randint(0, 2, N * mod_order)

i = bits[::2]
q = bits[1::2]
qpsk_symbols = (1 - 2*i) + 1j * (1 - 2*q)

#IFFT
time_symbol = np.fft.ifft(qpsk_symbols, N);
cp_list = time_symbol[-CP:]
tx_signal = np.concatenate([cp_list, time_symbol])

#Noise to emulate RF signal noise
SNR_dB = 20
sigma = 10**(-SNR_dB/20)
noise = (sigma/np.sqrt(2)) * (np.random.randn(len(tx_signal)) + 1j*np.random.randn(len(tx_signal)))
rx_signal = tx_signal + noise

#Reciever (we will recieve the transmitted signal with the added noise)

true_rx = rx_signal[CP:]
rx_qpsk = np.fft.fft(true_rx, N)
rx_i = (np.real(rx_qpsk) < 0).astype(int)
rx_q = (np.real(rx_qpsk) > 0).astype(int)

#Constellation plot !
plt.scatter(np.real(rx_qpsk), np.imag(rx_qpsk))
plt.title("Received QPSK Constellation")
plt.grid(True)
plt.show()