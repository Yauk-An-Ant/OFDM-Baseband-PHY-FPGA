
# OFDM Physical Layer Baseband Transceiver

A SystemVerilog-based digital baseband implementation of an OFDM physical layer transceiver designed for simulation and FPGA prototyping. The project focuses on building and integrating core DSP communication blocks such as FFT/IFFT processing, QPSK modulation/demodulation, cyclic prefix handling, and fixed-point datapath design in hardware.

## 1. Project Overview

This design implements a 64-subcarrier Orthogonal Frequency Division Multiplexing (OFDM) digital baseband transceiver pipeline,  The primary goal is to construct a bit-accurate, hardware-realizable system capable of streaming data serially, transforming it into the frequency and time domains, and recovering it over an emulated noisy RF channel.

### 1.1 Key System Parameters 

| Parameter          | Specification                        | Notes                                          |
| ------------------ | ------------------------------------ | ---------------------------------------------- |
| System Word Length | 16-bit                               | Signed two's complement fixed-point arithmetic |
| Modulation Format  | Quadrature Phase Shift Keying (QPSK) | 2 bits per subcarrier                          |
| FFT/IFFT Size      | 64 Points                            | N = 64 subcarriers                             |
| Cyclic Prefix      | 16 Samples                           | A quarter of the symbol length                 |
| Total Symbol Size  | 80 Samples                           | Cyclic Prefix (16) + Symbol (64)               |

## 2. Fixed-Point Arithmetic & Precision Specifications

## 3. System Architecture and RTL Diagram

## 4. Hardware Module Specifications

## 5. Verification Strategy

## 6. Results
