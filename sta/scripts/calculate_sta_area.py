import re
from collections import Counter, defaultdict

LIB = "/home/jackhunt2004/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

NETLISTS = {
    "Baseline": "netlist/sta/riscv_core_baseline_sta.v",
    "EXP2": "netlist/sta/riscv_core_exp2_sta.v",
}

# ------------------------------------------------------------
# Parse Liberty cell areas
# ------------------------------------------------------------

with open(LIB, "r") as f:
    lib_text = f.read()

cell_areas = {}

cell_pattern = re.compile(
    r'cell \("([^"]+)"\) \{(.*?)\n    \}',
    re.DOTALL
)

for match in cell_pattern.finditer(lib_text):
    cell_name = match.group(1)
    cell_body = match.group(2)

    area_match = re.search(
        r'^\s*area\s*:\s*([0-9.]+);',
        cell_body,
        re.MULTILINE
    )

    if area_match:
        cell_areas[cell_name] = float(area_match.group(1))

# ------------------------------------------------------------
# Count instantiated Sky130 cells in a netlist
# ------------------------------------------------------------

def count_cells(netlist_path):
    counts = Counter()

    with open(netlist_path, "r") as f:
        text = f.read()

    # Match Sky130 cell instantiations.
    # Example:
    # sky130_fd_sc_hd__mux2_1 _123_ (
    pattern = re.compile(
        r'^\s*(sky130_fd_sc_hd__\w+)\s+\S+\s*\(',
        re.MULTILINE
    )

    for cell in pattern.findall(text):
        counts[cell] += 1

    return counts

# ------------------------------------------------------------
# Calculate and report
# ------------------------------------------------------------

results = {}

for name, path in NETLISTS.items():
    counts = count_cells(path)

    total_area = 0.0
    missing = []

    for cell, count in counts.items():
        if cell in cell_areas:
            total_area += count * cell_areas[cell]
        else:
            missing.append(cell)

    results[name] = (counts, total_area, missing)

    print()
    print("=" * 72)
    print(name)
    print("=" * 72)

    print(f"Unique cell types : {len(counts)}")
    print(f"Total cell count  : {sum(counts.values())}")
    print(f"Total cell area   : {total_area:.4f}")

    if missing:
        print()
        print("WARNING: Missing Liberty areas:")
        for cell in sorted(missing):
            print(f"  {cell}")

    print()
    print("Top 15 area contributors:")
    print("-" * 72)

    contributors = []

    for cell, count in counts.items():
        if cell in cell_areas:
            area = count * cell_areas[cell]
            contributors.append((area, cell, count, cell_areas[cell]))

    for area, cell, count, unit_area in sorted(
        contributors, reverse=True
    )[:15]:
        print(
            f"{cell:35s} "
            f"count={count:5d} "
            f"unit={unit_area:10.4f} "
            f"area={area:12.4f}"
        )

# ------------------------------------------------------------
# Final comparison
# ------------------------------------------------------------

base_area = results["Baseline"][1]
exp2_area = results["EXP2"][1]

delta = exp2_area - base_area
percent = (delta / base_area) * 100.0

print()
print("=" * 72)
print("BASELINE vs EXP2")
print("=" * 72)

print(f"Baseline area : {base_area:.4f}")
print(f"EXP2 area     : {exp2_area:.4f}")
print(f"Difference    : {delta:+.4f}")
print(f"Area change   : {percent:+.3f}%")

if base_area != 0:
    print(f"Area reduction: {(-delta / base_area) * 100:.3f}%")
