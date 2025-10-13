# Replication Package for Blurring the Marriage Market? Contemporary Patterns of Multiracial Marriage

This is a replication package for the article "Blurring the Marriage Market? Contemporary Patterns of Multiracial Marriage" by Aaron Gullickson and Jenifer Bratter that is forthcoming in *Demography*.

The data for this project comes from [IPUMS USA](https://usa.ipums.org/usa/), which does not allow the re-distribution of data. Therefore, the raw data are not included in this replication package. However, the codebook available at `data/data_raw/usa_00139.cbk.txt` contains all the information needed to generate an identical extract which can then be read in with minor modification to the `read-data` code chunk in `analysis/organize_data.R`.

Once the data are replicated, the entire project can be run as a [quarto](https://quarto.org/) project with the following command in the base directory:

``` bash
quarto render
```

Running the project as a quarto project should install the required packages via the `utils/check_packages.R` script. This script can also be sourced separately to load all dependencies. The main analysis can also be run by rendering the following quarto documents separately.

1.  `analysis/organize_data.qmd`
2.  `analysis/run_models.qmd` Be aware that these models are computationally intensive and will take at least several hours to run and will require substantial RAM.
3.  `analysis/analysis.qmd`
