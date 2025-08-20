import matplotlib.pyplot as plt
import numpy as np


def cross_correlation(signal1, signal2):
    # Compute the cross-correlation
    cross_corr = np.correlate(signal1, signal2, mode='full')
    return cross_corr


def autocorrelation(signal):
    # Compute the autocorrelation
    auto_corr = np.correlate(signal, signal, mode='full')
    return auto_corr


# Define the discrete-time signals
signal1 = np.array([1, 2, 3, 4, 5])
signal2 = np.array([2, 4, 6, 8, 10])

# Compute the cross-correlation
cross_corr = cross_correlation(signal1, signal2)

# Compute the autocorrelation
auto_corr = autocorrelation(signal1)

# Create the time lags for plotting
lags_cross = np.arange(-len(signal1) + 1, len(signal2))
lags_auto = np.arange(-len(signal1) + 1, len(signal1))

# Plot the cross-correlation and autocorrelation signals
plt.figure(figsize=(10, 6))

plt.subplot(2, 1, 1)
plt.stem(lags_cross, cross_corr)
plt.title('Cross-correlation')
plt.xlabel('Time Lag')
plt.ylabel('Magnitude')

plt.subplot(2, 1, 2)
plt.stem(lags_auto, auto_corr)
plt.title('Autocorrelation')
plt.xlabel('Time Lag')
plt.ylabel('Magnitude')

plt.tight_layout()
plt.savefig("./Corelation.png")
print("File Saved at Corelation.png")
plt.show()
