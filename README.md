---
editor: visual
---

# Replication Package for Blurring the Marriage Market? Contemporary Patterns of Multiracial Marriage

This is a replication package for the article "Blurring the Marriage Market? Contemporary Patterns of Multiracial Marriage" by Aaron Gullickson and Jenifer Bratter that is forthcoming in *Demography*.

The data used for this project are a subsample of the [IPUMS USA](https://usa.ipums.org/usa/) data. Any use of these data should be cited as follows:

> Steven Ruggles, Sarah Flood, Matthew Sobek, Daniel Backman, Grace Cooper, Julia A. Rivera Drew, Stephanie Richards, Renae Rodgers, Jonathan Schroeder, and Kari C.W. Williams. IPUMS USA: Version 16.0 \[dataset\]. Minneapolis, MN: IPUMS, 2025. [https://doi.org/10.18128/D010.V16.0](https://urldefense.com/v3/__https://doi.org/10.18128/D010.V16.0__;!!C5qS4YX3!CJTSdv0c1D0fh3i0IT9CysSf0y5rD3xCZTIJyRXFXHfs9YjGCJtrfS586FzM9_x1puhPFuEsx7qhaBY$ "https://urldefense.com/v3/__https://doi.org/10.18128/D010.V16.0__;!!C5qS4YX3!CJTSdv0c1D0fh3i0IT9CysSf0y5rD3xCZTIJyRXFXHfs9YjGCJtrfS586FzM9_x1puhPFuEsx7qhaBY$")

The data included with this project is intended only for replication purposes. Individuals are not to redistribute the data without permission. Contact [ipums\@umn.edu](#0) for redistribution requests. For all other uses of these data, please access data directly via [usa.ipums.org](#0).

Because of the size of the data, they are housed separately from this repository on Google Drive. However, the `analysis/organize_data.qmd` code will download these data to read locally when it is rendered. Furthermore the codebook for the extract is included with the repository at at `data/data_raw/usa_00139.cbk.txt`.

The entire project can be run as a [quarto](https://quarto.org/) project with the following command in the base directory:

``` bash
quarto render
```

Running the project as a quarto project should install the required packages via the `utils/check_packages.R` script. This script can also be sourced separately to load all dependencies. The main analysis can also be run by rendering the following quarto documents separately.

1.  `analysis/organize_data.qmd`
2.  `analysis/run_models.qmd` Be aware that these models are computationally intensive and will take at least several hours to run and will require substantial RAM.
3.  `analysis/analysis.qmd`
