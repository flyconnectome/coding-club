# 🧠 Coding Club Challenge: ALPN Connectivity-cosine clustering (Python & R)

This challenge introduces how to perform **connectivity-cosine similarity clustering** on ALPNs using **Python and R**, focusing on their upstream connectivity and/or  connectivity with sensory neurons only. Participants will extract synaptic connectivity from the *Aedes* dataset and apply clustering and visualization methods to identify neuronal groups based on shared connectivity profiles.

---

## 📊 Workflow Overview (Python)
   
1. 📚 **Fetch Metadata Retrieval**
   - Retrieve neuron metadata from FlyTable / SeaTable excluding the following statuses: duplicate, tiny or fragment.

2. 🧠 **Connectivity Data Retrieval**
   - Adjust synapse threshold if needed.
   - Choose upstream and/or downstream partners. *(For ALPN clustering use upstream partners or restrict it to sensory neuron connectivity)* Try both and compare the resulting dendrograms.
   - Ensure compatible query settings for synapse tables.
   - Fetch synapse-level connectivity data using **fafbseg synapse connectivity** (not navis). *(Control batch size for speed and acceptance of query to the server)*

3. 🔗 **Connectivity Matrix Construction**
   - Fetch adjacency data using **fafbseg adjacency** (not navis). *(Control batch size for speed and acceptance of query to the server)*
   - Use navis for cosine clustering (adjacency matrix axes for source or target 
   matter). *sklearn cosine_similarity is another option*

4. 🔬 **Clustering Analysis**
   - Perform hierarchical or graph-based clustering.

5. 📈 **Visualization**
   - Plot clustered heatmaps, dendrograms, and connectivity summaries.
   - Include root_id, type, group & side on the dendrogram labels.
   - Save high-resolution figures.

4. 📊 **Reviewing Clustering**   
   - Generate a csv file for review.

## 📊 Workflow Overview (R)
   
1. 📚 **Fetch Metadata Retrieval**   
   - Retrieve neuron metadata from FlyTable / SeaTable excluding the following statuses: duplicate, tiny or fragment.

2. 🧠 **Connectivity Data Retrieval and cosine similarity clustering**
   - Use `cf_cosine_plot()` function to fetch partner connectivity data & run the cosine clustering 👉 *https://natverse.org/coconatfly/reference/cf_cosine_plot.html*
      - Use ids or regular expression to specify the class or superclass of the neurons of interest *(specified with an initial "/")* 
      - Adjust synapse threshold if needed. *(default threshold=5)*
      - Choose upstream and/or downstream partners. *(For ALPN clustering use upstream partners or restrict it to sensory neuron connectivity)* Try both and compare the resulting dendrograms.
      - Ensure that the `group` parameter is used.    
   - Fetch metadata for the neurons that have been clustered and add relevant clustering information. *(e.g. dendrogram order, groups)*
      
   

3. 📈 **Visualization**
   - Plot the dendrogram.
   - Include root_id, type, group & side on the dendrogram labels.
   - Save high-resolution figures.

4. 📊 **Reviewing Clustering**   
   - Generate a spreadsheet to review the ALPN clusters.
---

## ⚙️ Setup Instructions

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

- `coconatfly` *(installed through natmanager)* 👉 *https://natverse.org/coconatfly/*
- `coconat` 👉 *https://natverse.org/coconat/*
- `googlesheets4` 👉 *https://googlesheets4.tidyverse.org/*
- `fafbseg` 👉 *https://natverse.org/fafbseg/*
- `dplyr`👉 *https://dplyr.tidyverse.org/*

Additionally, source the Aedes-specific helper file supplied by Greg.

---

## 🧩 Mandatory Requirements & Constraints

```r
source("R/funs/aedes-dataset-funs.R")
choose_aedes()
```

---

### 🔗 Synapse Table Access (Python)
- To access the synapse table in Python, you **must**:
  - Use the **modified fafbseg file supplied**, **OR**
  - Remove references to unsupported columns (e.g. *synaptic cleft score*).

- When fetching synaptic tables, you **must disable unsupported views** by using:

```python
materialisation = "live", filtered = False
```

Failing to do so will result in query errors.

---

### 🧠 Connectivity Source (Python)
- **Must use fafbseg synapse connectivity**
- **Must NOT use navis connector data** (connector data are not available for this dataset).

---

### ⚠️ Multiprocessing Safety (Python)
When using navis similarity or clustering utilities, you **must** protect execution with:

```python
if __name__ == "__main__":
    # clustering or similarity code here
```

This prevents multiprocessing issues on certain systems.

The navis similarity calculation can often be slow or cause memory issues with large matrices.
Using sklearn's `cosine_similarity` function 👉 *https://scikit-learn.org/stable/modules/generated/sklearn.metrics.pairwise.cosine_similarity.html* can vastly speed up processing (due to multi-threaded processing) and an added layer of granuality when writing your code, though you will need to manually apply changes (e.g. thresholding, matrix conversion) before runnning this function.

#### Example code 

```python
X = adjacency.to_numpy(dtype=np.float32)

S = cosine_similarity(X)

matching_scores = pd.DataFrame(S, index=adjacency.index, columns=adjacency.columns)
```

## 📌 Notes

- Always confirm you are working with the **wclee_aedes_brain** dataset.
- The clustering always runs against the latest materialised version of the synapse table.
   - the synapse table is updated every day at 14:10 UK time. 
- Avoid cached or materialized views that are unsupported for synapse tables.
- Save intermediate connectivity matrices.
- Keep in mind that the column names will differ from those in the aedes table when fetching the metadata from the clustering; renaming is required before generating the spreadsheet for review.
  

---
