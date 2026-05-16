import numpy as np

def quantize(val, wordlength, fraclength):
        #if val is complex, quantize by component
        if np.iscomplexobj(val):
            return quantize(np.real(val), wordlength, fraclength) + 1j * quantize(np.imag(val), wordlength, fraclength)
        
        scaling_factor = 2 ** fraclength
        scaled = val * scaling_factor

        truncated = np.floor(scaled)
        clipped = np.clip(truncated, -1 * (2 ** (wordlength - 1)) , (2 ** (wordlength - 1)) - 1)
        
        return clipped / scaling_factor
