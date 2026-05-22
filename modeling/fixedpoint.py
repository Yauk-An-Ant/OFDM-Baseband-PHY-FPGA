import numpy as np
import matplotlib.pyplot as plt

def quantize(val, wordlength, fraclength):
        #if val is complex, quantize by component
        if np.iscomplexobj(val):
            return quantize(np.real(val), wordlength, fraclength) + 1j * quantize(np.imag(val), wordlength, fraclength)
        
        scaling_factor = 2 ** fraclength
        scaled = val * scaling_factor

        truncated = np.floor(scaled)
        clipped = np.clip(truncated, -1 * (2 ** (wordlength - 1)) , (2 ** (wordlength - 1)) - 1)
        
        return clipped / scaling_factor

np.random.seed(42)
num_samples = 50000
test_signal = np.random.uniform(-0.9, 0.9, num_samples) + 1j * np.random.uniform(-0.9, 0.9, num_samples)

WORD_LENGTH = 16
frac_lengths = np.arange(0, 16)
noise_powers_db = []

for f_len in frac_lengths:
    quantized_signal = quantize(test_signal, WORD_LENGTH, f_len)
    
    noise = test_signal - quantized_signal
    
    noise_variance = np.var(noise)

    #db conversion
    noise_db = 10 * np.log10(noise_variance)
    noise_powers_db.append(noise_db)


plt.style.use('dark_background')
plt.figure(figsize=(8, 5))
plt.plot(frac_lengths, noise_powers_db, marker='o', color='#007acc', linewidth=2)

plt.title('Quantization Noise Power vs. Fractional Bit Width', fontsize=12, fontweight='bold')
plt.xlabel('Fractional Bit Length (fraclength)', fontsize=11)
plt.ylabel('Quantization Noise Power (dB)', fontsize=11)
plt.grid(True, linestyle='--', alpha=0.5)
plt.xticks(frac_lengths)

# Add text labels on top of each point for your report
for i, db_val in enumerate(noise_powers_db):
    plt.annotate(f"{db_val:.1f} dB", (frac_lengths[i], noise_powers_db[i]),
                 textcoords="offset points", xytext=(0,10), ha='center', fontsize=9)

plt.tight_layout()
plt.savefig('quantization_noise_analysis.png', dpi=300)
plt.show()