#!/usr/bin/env python3
"""Stacked bar chart comparing BUSCO completeness of the genome assembly (Flye)
and the annotated protein set (MAKER, longest isoform per gene)."""
import re
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

base = "/data/users/jli/genome_annotation_course"
runs = {  # plotted bottom-to-top
    "Annotated proteins\n(MAKER)": f"{base}/busco_proteins/short_summary.specific.brassicales_odb10.busco_proteins.txt",
    "Genome assembly\n(Flye)": f"{base}/short_summary.specific.brassicales_odb10.flye.txt",
}
# BUSCO's conventional colours
cats = [("S", "Complete, single-copy (S)", "#56B4E9"),
        ("D", "Complete, duplicated (D)", "#3492C7"),
        ("F", "Fragmented (F)", "#F0E442"),
        ("M", "Missing (M)", "#F04442")]


def parse(path):
    vals, notation = {}, ""
    for line in open(path):
        m = re.match(r"\s*(\d+)\s+.*?\((S|D|F|M)\)", line)
        if m:
            vals[m.group(2)] = int(m.group(1))
        m = re.match(r"\s*(\d+)\s+Total BUSCO groups searched", line)
        if m:
            vals["n"] = int(m.group(1))
        if line.strip().startswith("C:"):
            notation = line.strip()
    return vals, notation


fig, ax = plt.subplots(figsize=(10, 3.2))
names = list(runs)
for y, name in enumerate(names):
    v, notation = parse(runs[name])
    left = 0
    for key, label, col in cats:
        pct = v[key] / v["n"] * 100
        ax.barh(y, pct, left=left, color=col, edgecolor="black", linewidth=0.5,
                height=0.6, label=label if y == 0 else None)
        left += pct
    # BUSCO notation inside the bar (strip the trailing E: field for brevity)
    ax.text(1, y, re.sub(r",E:[\d.]+%", "", notation), va="center", ha="left",
            fontsize=10, fontweight="bold", color="black")

ax.set_yticks(range(len(names)), names, fontsize=11)
ax.set_xlim(0, 100)
ax.set_xlabel("% of BUSCOs (brassicales_odb10, n = 4,596)", fontsize=11)
ax.spines[["top", "right"]].set_visible(False)
ax.legend(ncol=4, loc="upper center", bbox_to_anchor=(0.5, -0.3), frameon=False, fontsize=10)
fig.tight_layout()
for ext in ("png", "pdf"):
    fig.savefig(f"{base}/plots/04_BUSCO_genome_vs_proteins.{ext}", dpi=300)
