# 🧠 Coding Club Challenge: ALPN Connectivity-cosine Clustering (Python & R)

This challenge introduces how to perform **connectivity-cosine clustering** on ALPNs using **Python and R**, focusing on synapse connectivity with sensory neurons. Participants will extract synaptic connectivity from the Aedes dataset and apply clustering and visualization methods to identify neuronal groups based on shared connectivity profiles.

---

## 📊 Workflow Overview (Python)
   
1. 📚 **Fetch Metadata Retrieval**
   - Retrieve neuron metadata from FlyTable / SeaTable.

2. 🧠 **Connectivity Data Retrieval**
   - Adjust threshold connectivity as needed.
   - Choose upstream and/or downstream partners. *(For ALPNs only upstream partners)*
   - Ensure compatible query settings for synapse tables.
   - Fetch synapse-level connectivity data using **fafbseg synapse connectivity** (not navis).

3. 🔗 **Connectivity Matrix Construction**
   - Fetch adjacency data using **fafbseg adjacency** (not navis).
   - Use navis for cosine clustering (adjacency matrix axes for source or target 
   matter). *sklearn cosine_similarity is another option*

4. 🔬 **Clustering Analysis**
   - Perform hierarchical or graph-based clustering.

5. 📈 **Visualization**
   - Plot clustered heatmaps, dendrograms, and connectivity summaries.
   - Save high-resolution figures suitable for presentations.

4. 📊 **Reviewing Clustering**   
   - Generate a csv file for review.

## 📊 Workflow Overview (R)
   
1. 📚 **Fetch Metadata Retrieval**   
   - Retrieve neuron metadata from FlyTable / SeaTable.

2. 🧠 **Connectivity Data Retrieval and Cosine similarity clustering**
   - Use `cf_cosine_plot` 👉 *https://natverse.org/coconatfly/reference/cf_cosine_plot.html*
   - Adjust threshold connectivity as needed.
   - Choose upstream and/or downstream partners. *(For ALPNs only upstream partners)*
   - Fetch metadata and add clustering relevant informatio. *(e.g. dendid)*
   

3. 📈 **Visualization**
   - Plot clustered heatmaps, dendrograms.
   - Save high-resolution figures suitable for presentations.

4. 📊 **Reviewing Clustering**   
   - Generate a spreadsheet for review.
---

## ⚙️ Setup Instructions

### 📚 Required Libraries

### Python
Ensure the following Python libraries are installed:

- `sea-serpent`
- `navis`
- `fafbseg` *(modified version supplied)*
- `matplotlib`
- `seaborn`
- `scipy`
- `numpy`

### R
Ensure the following R libraries are installed:

- `coconatfly` *(installed through natmanager)*
- `coconat`
- `googlesheets4`
- `fafbseg`
- `dplyr`

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
  - Use the **modified fafbseg library supplied**, **OR**
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

### Example code 

```python
X = adjacency.to_numpy(dtype=np.float32)

S = cosine_similarity(X)

matching_scores = pd.DataFrame(S, index=adjacency.index, columns=adjacency.columns)
```

## 📌 Notes

- Always confirm you are working with the **wclee_aedes_brain** dataset.
- Avoid cached or materialized views that are unsupported for synapse tables.
- Save intermediate connectivity matrices.

---
