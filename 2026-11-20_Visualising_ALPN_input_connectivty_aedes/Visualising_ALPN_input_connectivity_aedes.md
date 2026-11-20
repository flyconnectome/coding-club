# Coding Club Challenge: Generating a Heatmap to Visualise Input Connectivity of Antennal Lobe Projection Neurons in aedes

This challenge introduces how to plot a heatmap showing the normalised **sensory inputs** to ALPNs in aedes without using the inbuilt functions - i.e. cf_cosine_plot().


## Workflow Overview (R)


1. **Read in connectivity information**

2. **Process connectivity information**
   - Filter the neurons of interest
     - Which postsynaptic neurons should be included?
     - Which presynaptic neurons should be included?
     - Do I need to adjust the synapse threshold? *(default threshold = 5)*

3. **Group inputs**
   - What features should we group the inputs by?

4. **Normalise the connectivity information**

5. **Reshape from long to wide format & convert to a matrix**
   - pivot_wider()

6. **Plot a heatmap**


## Bonus

- **Plot a combined heatmap of sensory and Antennal Lobe Local Neuron inputs to the ALPNs**

- **Add an annotation to the heatmap to highlight a feature of interest**


### 📚 Required Libraries

### Python
Ensure the following Python libraries are installed:

- `sea-serpent` 👉 *https://pypi.org/project/sea-serpent/*
- `navis` 👉 *https://navis-org.github.io/navis/*
- `fafbseg` *(modified "Synapses.py" file supplied)* 👉 *https://fafbseg-py.readthedocs.io/en/latest/source/api.html*
- `matplotlib` 👉 *https://matplotlib.org/stable/index.html*
- `seaborn` 👉 *https://seaborn.pydata.org*
- `scipy` 👉 *https://docs.scipy.org/doc/scipy/reference/index.html#scipy-api*
- `numpy` 👉 *https://numpy.org/doc/stable/reference/index.html#reference*

### R
Ensure the following R libraries are installed:

- `aedes`👉 *https://flyconnectome.github.io/aedes/*
- `coconatfly` *(installed through natmanager)* 👉 *https://natverse.org/coconatfly/*
- `coconat` 👉 *https://natverse.org/coconat/*
- `fafbseg` 👉 *https://natverse.org/fafbseg/*
- `tidyverse`👉 *https://tidyverse.org/packages/*
- `ComplexHeatmap`👉 *https://jokergoo.github.io/ComplexHeatmap-reference/book/*

---

## 📌 Notes

