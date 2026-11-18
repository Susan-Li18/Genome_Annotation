#!/usr/bin/env python3
"""Cumulative distribution of MAKER Annotation Edit Distance (AED),
from the output of AED_cdf_generator.pl (scripts/13_exam_AED.sh)."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

base = "/data/users/jli/genome_annotation_course"
aed_file = f"{base}/output/MAKER/final/assembly.all.maker.renamed.gff.AED.txt"

aed, frac = [], []
with open(aed_file) as fh:
    next(fh)  # header: AED <gff name>
    for line in fh:
        a, f = line.split()[:2]
        aed.append(float(a))
        frac.append(float(f))

at_half = dict(zip(aed, frac))[0.5]

fig, ax = plt.subplots(figsize=(6, 4.5))
ax.plot(aed, frac, color="#3B7DD8", linewidth=2, marker="o", markersize=3)
ax.axvline(0.5, color="grey", linestyle="--", linewidth=1)
ax.axhline(at_half, color="grey", linestyle="--", linewidth=1)
ax.annotate(f"{at_half * 100:.1f}% of models\nwith AED ≤ 0.5", xy=(0.5, at_half),
            xytext=(0.58, 0.72), fontsize=10,
            arrowprops=dict(arrowstyle="->", color="black", lw=0.8))
ax.set_xlim(0, 1)
ax.set_ylim(0, 1.02)
ax.set_xlabel("Annotation Edit Distance (AED)", fontsize=11)
ax.set_ylabel("Cumulative fraction of gene models", fontsize=11)
ax.spines[["top", "right"]].set_visible(False)
fig.tight_layout()
for ext in ("png", "pdf"):
    fig.savefig(f"{base}/plots/05_AED_cumulative_distribution.{ext}", dpi=300)
