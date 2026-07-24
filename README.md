# Figure reproduction code - RL vs. PID/MPC glucose control (T1DM and T2DM)

Managing diabetes requires constant attention to glucose levels and the corresponding adjustment of insulin doses. We developed a computer-based learning approach to determine the appropriate insulin doses to regulate glucose in real time and counteract unannounced disturbances. This approach proved effective in the management of both type 1 and type 2 diabetes mellitus, and it requires no input other than continuous glucose measurements. Here, we provide scripts to create figures of simulations.

This repository contains the MATLAB code used to generate the main-text figures
of the manuscript:

> **"Reinforcement learning optimization of automated insulin delivery in type 1 and type 2 diabetes mellitus"**
> Nelida E. Lopez-Palau1, Pablo Naranjo-Meneses, Julia Szendroedi, Roland Eils, Stefan M. Kallenberger

The script reproduces the three figures comparing a Reinforcement Learning (RL)
glucose-control policy against classical controllers (PID, MPC) for in-silico
Type 1 (T1DM) and Type 2 (T2DM) diabetes cohorts.

---

## Contents

| File | Description |
|------|-------------|
| `SimulationsAndPlots.m` | Single script that regenerates Figures 2–4 and prints the associated statistical tests to the Command Window. |

---

## Figure map

| Flag in the script | Output | Description |
|--------------------|--------|-------------|
| `Task_showBoxplot` | **Fig. 2** | Cumulative-reward boxplots: untrained vs. optimal RL policy, training vs. validation environment (1500 virtual patients). |
| `Task_showAvgSubjectBG` | **Fig. 3** | Exemplary glucose/insulin time series (PID / MPC / RL) for a representative T1DM and T2DM subject. |
| `Task_showScatterPlot` | **Fig. 4** | Scatter plots of RL vs. PID (left) and RL vs. MPC (right) for TIR / TAR / TBR metrics, with per-group trend lines and Pearson correlations. |

Each flag can be set to `1` (generate) or `0` (skip) in the **Task definition**
block at the top of the script.

---

## Requirements

- **MATLAB R2026a** (the code was developed and tested on this release).
- **Statistics and Machine Learning Toolbox** — required by `signrank`,
  `ranksum`, `corr`, and `polyfit`/`polyval`.

No other toolboxes are needed. All plotting functions (`boxchart`, `stairs`,
`stem`, `yline`, `xline`, `yyaxis`) are part of base MATLAB.

---

## Data and folder structure

The `.mat` data files are included in this repository 
Place them relative to the script exactly as follows:

```
SimulationsAndPlots.m
Policies_simulations.mat
Controllers/
├── T1_SimulationResults_AvgSubject/
│   ├── T1_PIDResults.mat
│   ├── T1_MPCResults.mat
│   └── T1_RLResults.mat
├── T2_SimulationResults_AvgSubject/
│   ├── T2_PIDResults.mat
│   ├── T2_MPCResults.mat
│   └── T2_RLResults.mat
├── T1_SimulationResults/
│   ├── T1_PIDResults.mat
│   ├── T1_MPCResults.mat
│   └── T1_RLResults.mat
└── T2_SimulationResults/
    ├── T2_PIDResults.mat
    ├── T2_MPCResults.mat
    └── T2_RLResults.mat
```

Expected variables inside each file:

- **`Policies_simulations.mat`** (used for Fig. 2):
  `T1_ag0_env`, `T1_ag5_env`, `T1_ag5_envT`,
  `T2_ag0_env`, `T2_ag9_env`, `T2_ag9_envT`.
  Each is an array of simulation structs with a `.Reward.Data` field.
  Naming key: `ag0` = untrained agent, `ag5`/`ag9` = trained agent,
  `env` = training environment, `envT` = validation environment.

- **`*_AvgSubject/*Results.mat`** (Fig. 3): contain `PopulationPIDResults`,
  `PopulationMPCResults`, `PopulationRLResults` (cell arrays of per-subject
  simulation structs with fields `glucose_mgdL`, `rivi_ctrl_mUmin`,
  `rivi_bolus_mUmin`, `rivi_total_mUmin`, `meals`, `time`).

- **`T1_SimulationResults/*Results.mat` and `T2_SimulationResults/*Results.mat`** (Fig. 4):
  contain the metric vectors `TIR`, `TAR`, `TBR` (one row per virtual patient).

---

## Usage

1. Clone the repository and place the `.mat` data files as shown above.
2. Open MATLAB R2026a and set the working directory to the repository root.
3. Run the script:

   ```matlab
   SimulationsAndPlots
   ```

4. Three figure windows open (Figures 2–4). The statistical test results are
   printed to the Command Window.


## Citation
If you use this code, please cite the manuscript:

```bibtex
@article{Lopez-Palau2025.10.12.25337835,
  author       = {Lopez-Palau, Nelida E. and Naranjo-Meneses, Pablo and Szendroedi, Julia and Eils, Roland and Kallenberger, Stefan M.},
  title        = {Reinforcement learning optimization of automated insulin delivery in type 1 and type 2 diabetes mellitus},
  elocation-id = {2025.10.12.25337835},
  year         = {2025},
  doi          = {10.1101/2025.10.12.25337835},
  publisher    = {Cold Spring Harbor Laboratory Press},
  url          = {https://www.medrxiv.org/content/early/2025/10/14/2025.10.12.25337835},
  eprint       = {https://www.medrxiv.org/content/early/2025/10/14/2025.10.12.25337835.full.pdf},
  journal      = {medRxiv}
}
```

---

## Contacts
Nelida López-Palau (Nelida.lopez-palau@bioquant.uni-heidelberg.de), 
Stefan Kallenberger (stefan.kallenberger@bioquant.uni-heidelberg.de).
