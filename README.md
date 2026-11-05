# Wine Cultivar Classification with R

**Virtual Data Science with R Apprentice Internship — five-week integrated project**

## Project overview
This project explores whether 13 chemical measurements can distinguish three wine cultivars in the UCI Wine Recognition dataset. The released dataset contains 178 records, 13 numeric predictors, and a three-level cultivar class. The data originated from chemical analysis of wines grown in the same Italian region but derived from three cultivars.

## Repository structure
```text
r_apprentice_project/
├── data/
│   ├── raw/wine_recognition_raw.csv
│   └── processed/
│       ├── wine_clean.csv
│       ├── wine_scaled_demo.csv
│       ├── split_assignment.csv
│       ├── quality_audit.csv
│       ├── outlier_flags.csv
│       ├── summary_statistics.csv
│       └── class_means.csv
├── src/
│   ├── 01_clean_data.R
│   ├── 02_eda.R
│   ├── 03_preprocess.R
│   ├── 04_modeling.R
│   ├── 05_final_summary.R
│   └── run_all.R
├── reports/figures/
├── outputs/
├── deliverables/
└── submission_descriptions.txt
```

## Run the R workflow
1. Install R (4.2 or later recommended).
2. Open a terminal with this folder as the working directory.
3. Install the recommended packages if needed: `install.packages(c("MASS", "nnet"))`.
4. Run: `Rscript src/run_all.R`.
5. Review the generated files in `data/processed/`, `reports/figures/`, and `outputs/`.

The EDA and cleaning scripts use base R. The model script uses `MASS::lda()` and `nnet::multinom()`. The supplied split assignment is fixed and stratified (124 training records, 54 test records) for repeatable evaluation. Scaling parameters are fitted on training records only and then applied to the test set to reduce data leakage.

## Dataset provenance and limitations
The CSV is packaged from the public Wine Recognition dataset distributed with scikit-learn, with the original UCI class labels restored to 1, 2, and 3. Cite the original UCI dataset: Aeberhard, S. & Forina, M. (1992). *Wine*. UCI Machine Learning Repository. https://doi.org/10.24432/C5PC7J. Dataset details: https://archive.ics.uci.edu/dataset/109/wine.

This is a small, curated benchmark dataset. Results should not be interpreted as proof that the models generalize to all commercial wines or as a basis for consumer, health, or regulatory decisions. The dataset lacks brand, price, and broader geographic information.

## Execution note
The authoring workspace did not include an R runtime. The R source files are provided for reproducible execution, but were not executed here. Files with `reference_python` in their names and the corresponding embedded model visuals are clearly marked benchmark outputs from equivalent scikit-learn models on the same data split, not R-native output. Run the R workflow and use `outputs/model_metrics_R.csv` for final R metrics before making an R-execution claim. See `ENVIRONMENT_NOTE.txt`.

## References
- Aeberhard, S. & Forina, M. (1992). *Wine* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5PC7J
- UCI Machine Learning Repository. *Wine dataset, ID 109*. https://archive.ics.uci.edu/dataset/109/wine
- scikit-learn Developers. *Wine recognition dataset documentation*. https://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_wine.html
