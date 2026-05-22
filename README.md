
# OFDM Physical Layer Baseband Transceiver

A SystemVerilog-based digital baseband implementation of an OFDM physical layer transceiver designed for simulation and FPGA prototyping. The project focuses on building and integrating core DSP communication blocks such as FFT/IFFT processing, soft-decision QPSK modulation/demodulation, cyclic prefix handling, and fixed-point datapath design in hardware.

## 1. Project Overview

This design implements a 64-subcarrier Orthogonal Frequency Division Multiplexing (OFDM) digital baseband transceiver pipeline,  The primary goal is to construct a bit-accurate, hardware-realizable system capable of streaming data serially, transforming it into the frequency and time domains, and recovering it over an emulated noisy RF channel. Signal recovery is performed over an emulated noisy RF channel using a 4-bit Log-Likelihood Ratio (LLR) extraction layer designed to seamlessly drive downstream error-correction units.

### 1.1 Key System Parameters 

| Parameter          | Specification                        | Notes                                          |
| ------------------ | ------------------------------------ | ---------------------------------------------- |
| System Word Length | 16-bit                               | Signed two's complement fixed-point arithmetic |
| Modulation Format  | Quadrature Phase Shift Keying (QPSK) | 2 bits per subcarrier                          |
| FFT/IFFT Size      | 64 Points                            | N = 64 subcarriers                             |
| Cyclic Prefix      | 16 Samples                           | A quarter of the symbol length                 |
| Total Symbol Size  | 80 Samples                           | Cyclic Prefix (16) + Symbol (64)               |

## 2. Fixed-Point Arithmetic & Precision Specifications

To optimize hardware resource utilization while still retaining the precision needed for accurate demodulation and Fourier transform computation, a variable fixed-point allocation strategy is used with different bit widths for each function.

### 2.1 Quantization Summary

| Interface Boundary         | Fixed-Point Notation |
| -------------------------- | -------------------- |
| QPSK Mapper Output Format  | Q1.15                |
| QPSK Demapper Input Format | Q1.15                |
| IFFT Output Format         | Q6.10                |
| FFT Input Format           | Q6.10                |
### 2.2 Fractional Bit Width vs. Quantization Noise Plot

![](/diagrams/bitplot.png)

### 2.3 Signal Scaling & Headroom Analysis

**Mapper Normalization:** To prevent mathematical overflow inside the IFFT butterfly calculation stages, input QPSK symbols are scaled down by a factor of $1/\sqrt{2} \approx 0.707$. The coordinates are mapped to the signed integers `+23170` (`16'h5A82`) and `-23170` (`16'hA57E`).

**IFFT/FFT Headroom:** An unscaled 64-point calculation can result in a worst-case signal amplitude growth across its 6 radix stages. Allocating 6 integer bits (`Q6.10`) provides an absolute register ceiling of $\pm 31.0$, which safely bounds the peak-to-average power ratio of the OFDM waveform without hard clipping.

## 3. System Architecture and RTL Diagrams

The system operates on a Synchronous Continuous Stream Architecture. Sub-modules track sample phases using synchronized internal counters cleared by a global active-low reset, eliminating the need for explicit handshake/ready signals.  

### 3.1 Transmitter Top Level RTL Diagram

![](/diagrams/transmittercorertl.png)
### 3.2 Receiver Top Level RTL Diagram

![](/diagrams/receivercorertl.png)
### 3.3 QPSK Mapper RTL Diagram

![](/diagrams/qpskmapperrtl.png)
### 3.4 QPSK Demapper RTL Diagram

![](/diagrams/qpskdemapperrtl.png)
### 3.5 FFT Core RTL Diagram

![](/diagrams/fft.png)
![](/diagrams/compblock.png)

### 3.6 Cyclic Prefix Handler RTL Diagram

![](/diagrams/cyclicprefixrtl.png)
## 4. Hardware Module Specifications

### 4.1 Transmitter Top Level Core (```ofdm_tx.sv```)

#### 4.1.1 Module Description
This module fully encapsulates the transmission baseband pipeline, handling the transition from frequency-domain bits into time-domain complex waveform. It accepts a serialized bitstream grouped into 2-bit symbols, which the QPSK mapper uses to create the normalized I and Q values, which are fed into the FFT core in IFFT mode. Then, the cyclic prefix is inserted with the cyclic prefix handler and sent as a continuous output stream in $Q6.10$ format.
#### 4.1.2 Portmap

| Port Name | Direction | Width | Description                                  |
| --------- | --------- | ----- | -------------------------------------------- |
| clk       | Input     | 1     | System clock                                 |
| n_rst     | Input     | 1     | Global active-low asynchronous reset         |
| serial_in | Input     | 1     | Serial bit input stream (2 bit symbol)       |
| out_i     | Output    | 16    | Real component amplitude ($Q6.10$ format)    |
| out_q     | Output    | 16    | Complex component amplitude ($Q6.10$ format) 
### 4.2 Receiver Top Level Core (```ofdm_rx.sv```)
#### 4.2.1 Module Description
This module fully encapsulates the reception baseband pipeline, handling the transition from a time-domain complex waveform into frequency-domain soft metrics. It accepts a continuous input stream of complex time-domain samples in `Q6.10` format from an external channel or ADC interface. The Cyclic Prefix Handler strips the 16-sample prefix, routing the 64-sample frames to the FFT core to demodulate the subcarriers back to the frequency domain. Finally, the normalized frequency-domain values (`Q1.15`) are processed by the soft-decision QPSK Demapper, which extracts and serializes a continuous stream of 4-bit Log-Likelihood Ratios (LLRs) for downstream error-correction units.
#### 4.2.2 Portmap

| Port Name | Direction | Width | Description                                                          |
| --------- | --------- | ----- | -------------------------------------------------------------------- |
| clk       | Input     | 1     | System clock                                                         |
| n_rst     | Input     | 1     | Global active-low asynchronous reset                                 |
| in_i      | Input     | 16    | Real time-domain component from channel/ADC ($Q6.10$ format)         |
| in_q      | Input     | 16    | Complex time-domain component from channel/ADC      ($Q6.10$ format) |
| llr_out   | Output    | 4     | 4-bit Signed Log-Likelihood Ratio stream                             |
### 4.3 QPSK Mapper (```qpsk_mapper.sv```)
#### 4.3.1 Module Description
The QPSK mapper converts a serial input bitstream grouped into 2-bit symbols into complex frequency domain coordinates. The two bits determine the sign of the real $I$ component, and the complex $Q$ component (e.g. ```10```, $1-j$), which are then normalized by scaling by a factor of 0.707 to prevent overflow.
#### 4.3.2 Portmap

| Port Name | Direction | Width | Description                                      |
| --------- | --------- | ----- | ------------------------------------------------ |
| clk       | Input     | 1     | System clock                                     |
| n_rst     | Input     | 1     | Global active-low asynchronous reset             |
| serial_in | Input     | 1     | Serial bit input (2 bit symbol)                  |
| out_i     | Output    | 16    | Real component amplitude ($Q1.15 \pm0.707$)      |
| out_q     | Output    | 16    | Complex component amplitude ($Q1.15 \pm j0.707$) |
### 4.4 QPSK Demapper (```qpsk_demapper.sv```)
#### 4.4.1 Module Description
The QPSK demapper is a soft-decision demodulation block that converts a complex time-domain wave into a continuous output stream of log likelihood ratios. The input values determine the sign of the real $I$ and complex $Q$ components.  These are then converted into 4-bit LLR values to account for noise and allow downstream error correction units to recover the original data bits with better precision, even under severe channel degradation.
#### 4.4.2 Portmap

| Port Name | Direction | Width | Description                                                 |
| --------- | --------- | ----- | ----------------------------------------------------------- |
| clk       | Input     | 1     | System clock                                                |
| n_rst     | Input     | 1     | Global active-low asynchronous reset                        |
| in_i      | Input     | 16    | Real frequency-domain component from FFT                    |
| in_q      | Input     | 16    | Complex frequency-domain component from FFT                 |
| llr_out   | Output    | 4     | 4-bit Signed Log-Likelihood Ratio stream (two's complement) |

### 4.5 FFT Core (```fft_64_core.sv```)
#### 4.5.1 Module Description
The FFT Core is a parameterized Fast Fourier Transform Acceleration block that translates signals between the time and frequency domains using a pipelined radix-2 butterfly architecture.  By default, the core will convert a signal from the time-domain to the frequency-domain. When configured in the IFFT mode, the core performs an inverse Fourier transform which reverses the process and converts a signal from the frequency-domain to the time-domain.
#### 4.5.2 Portmap

| Parameter Name | Width | Description                                           |
| -------------- | ----- | ----------------------------------------------------- |
| INVERSE        | 1     | Selects whether the module performs an FFT or an IFFT |

| Port Name | Direction | Width | Description                                                     |
| --------- | --------- | ----- | --------------------------------------------------------------- |
| clk       | Input     | 1     | System clock                                                    |
| n_rst     | Input     | 1     | Global active-low reset                                         |
| valid     | Input     | 1     | Indicates that the input data is valid                          |
| in_i      | Input     | 16    | Real input sample stream ($Q6.10$ if FFT, $Q1.15$  if IFFT)     |
| in_q      | Input     | 16    | Complex input sample stream ($Q6.10$ if FFT, $Q1.15$  if IFFT)  |
| valid_out | Output    | 1     | Signals that the FFT/IFFT computation is finished               |
| out_i     | Output    | 16    | Real output sample stream ($Q1.15$ if FFT, $Q6.10$  if IFFT)    |
| out_q     | Output    | 16    | Complex output sample stream ($Q1.15$ if FFT, $Q6.10$  if IFFT) |
### 4.6 Cyclic Prefix Handler (```cyclic_prefix_handler.sv```)
#### 4.6.1 Module Description
The cyclic prefix handler is a parameterized module that can both insert a cyclic prefix before a symbol, or strip a symbol of its cyclic prefix, depending on its configuration. When configured to insert, the handler reads 64 samples, and sends out a serial 80 sample window with the last 16 samples first and then the full 64 samples. When configured to trim, the handler reads in 16 samples and discards them before reading in the actual 64 sample symbol. The cyclic prefix is necessary because the same signal can reach the antenna at slightly different times by bouncing off walls or the ground. This can cause one symbol's tail to bleed into the start of another symbol, so the 16 sample prefix acts as a guard to make sure no data is lost.  
#### 4.6.2 Portmap

| Parameter Name | Width | Description                                                   |
| -------------- | ----- | ------------------------------------------------------------- |
| TRIM           | 1     | Selects whether the module inserts or trims the cyclic prefix |

| Port Name    | Direction | Width | Description                                                                            |
| ------------ | --------- | ----- | -------------------------------------------------------------------------------------- |
| clk          | Input     | 1     | System clock                                                                           |
| n_rst        | Input     | 1     | Global active-low reset                                                                |
| valid_data   | Input     | 1     | Indicates that the IFFT is done processing the symbol and to start counting the inputs |
| in_i         | Input     | 16    | Real input sample stream                                                               |
| in_q         | Input     | 16    | Complex input sample stream                                                            |
| valid_symbol | Output    | 1     | Signals that the data is part of the symbol and not the stripped cyclic prefix segment |
| out_i        | Output    | 16    | Real output sample stream                                                              |
| out_q        | Output    | 16    | Complex output sample stream                                                           |
## 5. Verification Strategy

### 5.1 Noise Module Specification

To emulate a real world RF channel with noise, an extra module is used for verification of transmission and retrieval. This module ```noise.sv``` acts as a manual noise injection device, which adds pseudo-random noise to both the $I$ and $Q$ parameters. This module is placed in between the transmitter and receiver cores to test end-to-end behavior. Its portmap is defined below.

| Port Name   | Direction | Width | Description                                                |
| ----------- | --------- | ----- | ---------------------------------------------------------- |
| clk         | Input     | 1     | System clock                                               |
| n_rst       | Input     | 1     | Global active-low asynchronous reset                       |
| noise_level | Input     | 4     | Amount of noise                                            |
| in_i        | Input     | 16    | Real time-domain component from transmitter core           |
| in_q        | Input     | 16    | Complex time-domain component from transmitter core        |
| out_i       | Output    | 16    | Noisy real time-domain component going to receiver core    |
| out_q       | Output    | 16    | Noisy complex time-domain component going to receiver core |
### 5.2 Top Level Verification

| Testcase Name       | Feature Tested                             | Inputs                                                                                                  | Expected Outputs                                                                                                       |
| ------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Asynchronous Reset  | Asynchronous reset                         | n_rst = 0                                                                                               | All registers should reset to their correct reset values                                                               |
| Clean <br>Loopback  | Ideal System Integrity &<br>System Latency | Minimum noise level<br>Random string of 64 bits into transmitter                                        | Received data should match transmitted data exactly<br>Latency should match total pipeline depth of system             |
| Moderate Noise      | Soft-Decision Demodulation                 | Moderate noise level<br>Same string of 64 bits as previous case                                         | Received LLR will vary in magnitude but the sign should indicate the correct transmitted bit                           |
| Heavy Noise         | System Output Under Stress                 | High noise level<br>Same string of 64 bits as previous case                                             | Received LLRs may be close to 0 indicating high noise level. Some bits may be flipped causing an expected non-zero BER |
| Cyclic Prefix Delay | Cyclic Prefix Channel Delay Tolerance      | Minimum noise level<br>Manual 5 cycle delay/reflection and then 64 bit input string from previous cases | The cyclic prefix should absorb the delay completely<br>Received data should match transmitted data exactly            |
### 5.3 QPSK Mapper Verification

| Testcase Name      | Feature Tested                    | Inputs                                                   | Expected Outputs                                               |
| ------------------ | --------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------- |
| Asynchronous Reset | Asynchronous reset                | n_rst = 0                                                | All registers should reset to their correct reset values       |
| Bit mapping        | Correct mapping and normalization | Serial stream of all possible bit pairs (00, 01, 10, 11) | Bits should be correctly mapped to 0.707 with the correct sign |
### 5.4 QPSK Demapper Verification
| Testcase Name            | Feature Tested                    | Inputs                                                                 | Expected Outputs                                                                                     |
| ------------------------ | --------------------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Asynchronous Reset       | Asynchronous reset                | n_rst = 0                                                              | All registers should reset to their correct reset values<br>                                         |
| Noiseless Demapping      | Demapping of ideal inputs         | Stream of all possible input pairs ($\pm0.707$)                        | LLRs should be at maximum magnitudes and demap into the correct bits                                 |
| Moderate Noise Demapping | Demapping of different magnitudes | Stream of inputs at different magnitudes between $\pm0.2$ and $\pm0.6$ | LLRs should show that there is some noise, but still correctly identify bits                         |
| Heavy Noise Demapping    | Demapping of high noise inputs    | Stream of inputs with low magnitudes close to 0                        | LLRs should show that the inputs have a lot of noise and identify which bit they are closer to being |
### 5.5 FFT Core Verification

| Testcase Name            | Feature Tested                      | Inputs                                                              | Expected Outputs                                                                                      |
| ------------------------ | ----------------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Asynchronous Reset       | Asynchronous reset                  | n_rst = 0                                                           | All registers should reset to their correct reset values<br>                                          |
| Constant Value           | DC isolation                        | Constant maximum value for 64 samples                               | Spike in first bin, then all 0s for remaining 63                                                      |
| All Zeroes               | Idle Stability                      | Input is 0 for all samples                                          | Output should be 0 without any self induced oscillation                                               |
| Single Frequency         | Sine wave fourier transform         | Sine wave input of four cycles across the 64 samples                | Bins corresponding to $\pm4$ should have non-zero values, with minimal leakage into surrounding bins  |
| Single Frequency Inverse | Sine wave inverse fourier transform | Feed expected output of previous test case as input to inverse mode | Sine wave of four cycles across the 64 samples                                                        |
| Overflow Prevention      | Overflow Prevention                 | Alternating maximum and minimum values                              | Output data should be concentrated in the center bin without clipping or rollovers                    |
| Linear Superposition     | Multi-Frequency Inputs              | A 2 cycle sine wave added to an 8 cycle sine wave                   | Two distinct magnitude spikes in bins 2 and 8 respectively with minimal leakage into surrounding bins |
| Linear Superposition     | Multi-Frequency Inputs              | Two distinct magnitude spikes in bins 2 and 8 respectively          | A 2 cycle sine wave added to an 8 cycle sine wave                                                     |
| Single Spike             | All-Pass Characteristic             | Single magnitude spike at sample 0, all other samples at 0          | Output should be a flat frequency spectrum of uniform, non-zero value                                 |
| Flat Spectrum            | All-Pass Characteristic             | Flat spectrum of uniform, non-zero value                            | Output should be a single spike at sample 0                                                           |
### Cyclic Prefix Verification

| Testcase Name      | Feature Tested          | Inputs                       | Expected Outputs                                             |
| ------------------ | ----------------------- | ---------------------------- | ------------------------------------------------------------ |
| Asynchronous Reset | Asynchronous reset      | n_rst = 0                    | All registers should reset to their correct reset values<br> |
| Prefix Insertion   | Cyclic Prefix Insertion | TRIM = 0<br>64 sample stream | 80 sample stream starting with the last 16 samples           |
| Prefix Trimming    | Cyclic Prefix Trimming  | TRIM = 1<br>80 sample stream | 64 sample stream with the 16 sample cyclic prefix discarded  |
## 6. Results
### 6.1 Python Model

#### 6.1.1 Model Description

First, a complete, end-to-end software simulation model was constructed in Python. This behavioral model serves as the mathematical "golden reference" for the entire OFDM communication transceiver pipeline, simulating a realistic physical layer link over an impaired channel. The model randomly generates bit pairs mapped to QPSK symbols as inputs to the transmitter and goes through the mathematical processes of the transmitter core. Then, Additive White Gaussian Noise (AWGN) is injected into the channel by adding it to the transmitter output. These noisy outputs are then put through the receiver model that plots the frequency domain outputs on a constellation plot shown below. With low and moderate amounts of noise, the BER is calculated to be 0. At elevated noise levels, the BER scales predictably higher, aligning precisely with the expected theoretical waterfall curve characteristics of a classic AWGN channel.
#### 6.1.2 Constellation Plot

![](/diagrams/constellationplot.png)