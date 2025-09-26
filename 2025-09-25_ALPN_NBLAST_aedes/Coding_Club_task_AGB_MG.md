# 🧠 Python & R Coding Club Challenge: Running NBLAST on Neuron Populations

This challenge introduces how to use **NBLAST** (https://doi.org/10.1016/j.neuron.2016.06.012), a fast and sensitive algorithm to measure pairwise neuronal similarity on a population of neurons using Python & R. Specifically, you will perform an NBLAST clustering of the ALPNs using the aedes dataset. The workflow will take you from environment setup to data transformation, NBLAST execution, clustering and visualisation.

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
   - Install the required packages and load all the necessary libraries.
   - Retrieve ALPN neuron metadata from Flytable excluding the following statuses: duplicate, tiny or fragment.
   - Retrieve neurons as simplified dotprops via FlyWire.
      - Python `fafbseg.flywire.get_l2_dotprops()` 👉
      - R `read_l2dp()` 👉 *https://natverse.org/fafbseg/reference/read_l2skel.html*

4. 🔄 **Mirroring registration**
   - *In R, you could run `aedes_mirroreg()`directly(see Key Functions & Conversions for details) or follow separately the steps below:*
      - Decode landmarks' URL to access annotation table.
        
         (Landmarks' coordinates can be found in pointA & pointB column of the annotations table)
         ```
         url = 'https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/4693107724517376'
         ```
      - Convert Landmarks' coordinates (raw → µm).
      - Generate transform with annotation table data.
         - Use the **thin plate spine transform** to generate the transform for mirroring neurons (Python)
      - Mirror neurons on one side of the brain using `xform()`.
         - **R**      👉 *https://natverse.org/fafbseg/reference/xform.ngscene.html*
         - **Python**
         - Navis version of tps transform is not accessible like fafbseg R, keep reference and target coordinates as separate variables too (Python)


5. 🔬 **Running NBLAST and clustering**
   - Run `nblast_allbyall()` comparisons across the ALPN population.
     **R**      👉 *https://natverse.org/nat.nblast/reference/nblast_allbyall.html*
     **Python** 👉
   - Run hierarchical clustering.
      - linkage using arg `method = 'ward'` (Python)

6. 📈 **Visualisation**
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
👉 *https://global.daf-apis.com/auth/api/v1/user/token*

### R

**fafbseg package installation**

👉 *https://natverse.org/fafbseg/index.html*

**FlyWire token**
```
library(fafbseg)
fafbseg::flywire_set_token()
```
*https://natverse.org/fafbseg/reference/flywire_set_token.html*

**Seatable token**
```
flytable_set_token(user='xxx@gmail.com', pwd='yyy', url = "https://flytable.mrc-lmb.cam.ac.uk/")

👉 *https://natverse.org/fafbseg/reference/flytable_login.html*
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

- `fafbseg`             👉 *https://natverse.org/fafbseg/*
- `dplyr`               👉 *https://dplyr.tidyverse.org/*
- `library(nat.nblast)` 👉 *https://natverse.org/nat.nblast/*

In addition, in order to access aedes specific functions you need to source `source("R/funs/aedes-dataset-funs.R")` after starting up the *2025aedes.Rproj* & choose the aedes dataset`choose_aedes()`.

👉 *https://github.com/flyconnectome/2025aedes/blob/adf079ab86ca7a2f7c5746b03efc2466dae99edc/R/funs/aedes-dataset-funs.R*

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
**Python**

```aedes_mirroreg <- function(units=c("microns", 'nm')) {
  um='https://spelunker.cave-explorer.org/#!middleauth+https://global.daf-apis.com/nglstate/api/v1/4693107724517376'
  mann=fafbseg::ngl_annotations(um)
  ptsA=with_aedes(fafbseg::flywire_raw2nm(mann$pointA))
  ptsB=with_aedes(fafbseg::flywire_raw2nm(mann$pointB))
  units=match.arg(units)
  if(units=='microns')
    aedes_mirror.um=nat::tpsreg(rbind(ptsA, ptsB)/1e3, rbind(ptsB, ptsA)/1e3)
  else
    aedes_mirror=nat::tpsreg(rbind(ptsA, ptsB), rbind(ptsB, ptsA))
}
```
**R**
- Saves image at **high resolution**, ensuring readable x-axis labels.

---

## 📌 Notes

- If you require access to Aedes Flytable dataset, ask for permission from Greg or Philipp.
- Always plot Landmarks to check that all the points are on the correct side before carrying out transformations.  
- Must do **micrometer conversions** for NBLAST.  
- High-resolution plots are essential for reading x axis.  
- Store NBLAST results in CSV for downstream analysis or clustering.

---
