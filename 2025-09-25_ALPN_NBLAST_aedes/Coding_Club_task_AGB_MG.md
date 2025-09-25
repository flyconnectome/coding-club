# 🧠 Python & R Coding Club Challenge: Running NBLAST on Neuron Populations

This challenge introduces how to use **NBLAST** on a population of neurons in Python, leveraging tools for neuron morphology, visualisation, and connectomics data access. The workflow will take you from environment setup to data transformation, NBLAST execution, clustering and visualisation.

---

## 📁 Contents

| Files to create | Description |
|------|-------------|
| `.env` (Python) | Configures environment variables and authenticates with FlyWire + SeaTable. |
| `.Renviron` (R) | Configures environment variables and authenticates with FlyWire + SeaTable. |
---

## 📊 Workflow Overview

1. 💻 **Environment Setup**
   - Set up required environment variables such as Flywire and Flytable.

2. 🧠 **Neuron Data Handling**
   - Retrieve ALPN neuron metadata from Flytable excluding the following statuses: Duplicate, Tiny or Fragment.
   - Retrieve neurons as simplified dotprops via FlyWire.
      - Python `fafbseg.flywire.get_l2_dotprops()`
      - R `read_l2dp()`

3. 🔄 **Mirroring registration**
   - *Can be run using `aedes_mirroreg()` in R*
      - Decode landmarks' URL to access annotation table.
        
         (Landmarks' coordinates can be found in pointA & pointB column of the annotations table)
         ```
         url = 'https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/4693107724517376'
         ```
      - Convert Landmarks' coordinates (raw → µm).
      - Generate transform with annotation table data.
         - Use the **thin plate spine transform** to generate the transform for mirroring neurons (Python)
      - Mirror neurons on one side of the brain using `xform`.
         - Navis version of tps transform is not accessible like fafbseg R, keep reference and target coordinates as separate variables too (Python)


4. 🔬 **Running NBLAST and clustering**
   - Run `nblast_allbyall` comparisons across the ALPN population.
   - Run hierarchical clustering.
      - linkage using arg `method = 'ward'` (Python)

5. 📈 **Visualisation**
   - Generate dendrogram.
   - Include root id, side, group & type on x axis.
   - Save images at high resolution.
     
        * Set figure size for wide neuron visualizations (Python):

        ```python
        matplotlib.pyplot.rcParams['figure.figsize'] = (40, 12)
        matplotlib.pyplot.savefig('x.pdf', dpi=500)
        ```

---

## ⚙️ Setup Instructions
### Python
Before running, set up the following environment variables such as:

```bash
export SEATABLE_SERVER=<your_seatable_server>
export SEATABLE_TOKEN=<your_seatable_token>
export FLYWIRE_DEFAULT_DATASET=wclee_aedes_brain
```

To get your FlyWire token, visit:  
👉 https://global.daf-apis.com/auth/api/v1/user/token  

### R

**FlyWire token**
```
library(fafbseg)
fafbseg::flywire_set_token()
```
**Seatable token**
```
flytable_set_token(user, pwd, url = "https://flytable.mrc-lmb.cam.ac.uk/")
```
---

## 📚 Required Libraries

### Python
Ensure the following Python libraries are installed:
- `sea-serpent`
- `navis`
- `fafbseg`
- `matplotlib`
- `scipy`
- `numpy`

### R
Ensure the following R libraries are installed:

- `fafbseg`
- `dplyr`
- `library(nat.nblast)`

In addition, in order to access aedes specific functions you need to source `source("R/funs/aedes-dataset-funs.R")` after starting up the *2025aedes.Rproj* & choose the aedes dataset`choose_aedes()`.

---

## 🧩 Key Functions & Conversions


### 📏 Unit Conversions
- **Nanometers → Micrometers** (Essential for NBLAST algorithm):  
```python
microns = dotprops * (1/1000)
```

- **Raw → Nanometers** (dataset scaling for `x, y, z`):  
  Multiply coordinates by `(16, 16, 45)` ***Conversion for the Aedes dataset**.

```python
def raw2loc(coordinates):
    arr = np.array(coordinates)
    factors = np.array([16, 16, 45])   # dataset scaling factors
    scaled_arr = arr * factors
    return scaled_arr.tolist()
```


- Saves image at **high resolution**, ensuring readable x-axis labels.

---

## 📌 Notes

- If you require access to Aedes Flytable dataset, ask for permission from Greg or Philipp.
- Always plot Landmarks to check that all the points are on the correct side before carrying out transformations.  
- Must do **micrometer conversions** for NBLAST.  
- High-resolution plots are essential for reading x axis.  
- Store NBLAST results in CSV for downstream analysis or clustering.

---
