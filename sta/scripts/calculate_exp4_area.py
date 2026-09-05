import re
from collections import Counter

LIB = "/home/jackhunt2004/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

NETLIST = "netlist/m4_exp3/riscv_core_exp3_m4.v"

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
# Count Sky130 cells in EXP4 netlist
# ------------------------------------------------------------

counts = Counter()

with open(NETLIST, "r") as f:
    text = f.read()

pattern = re.compile(
    r'^\s*(sky130_fd_sc_hd__\w+)\s+\S+\s*\(',
    re.MULTILINE
)

for cell in pattern.findall(text):
    counts[cell] += 1

# ------------------------------------------------------------
# Calculate area
# ------------------------------------------------------------

total_area = 0.0
missing = []

for cell, count in counts.items():
    if cell in cell_areas:
        total_area += count * cell_areas[cell]
    else:
        missing.append(cell)

# ------------------------------------------------------------
# Report
# ------------------------------------------------------------

print()
print("=" * 72)
print("EXP4 AREA")
print("=" * 72)

print(f"Netlist           : {NETLIST}")
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
        contributors.append(
            (area, cell, count, cell_areas[cell])
        )

for area, cell, count, unit_area in sorted(
    contributors, reverse=True
)[:15]:
    print(
        f"{cell:35s} "
        f"count={count:5d} "
        f"unit={unit_area:10.4f} "
        f"area={area:12.4f}"
    )
