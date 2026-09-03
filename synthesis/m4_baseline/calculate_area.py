import re

LIB = "/home/jackhunt2004/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
NETLIST = "netlist/m4_baseline/riscv_core_baseline_m4.v"

with open(LIB) as f:
    lib = f.read()

areas = {}
for cell, area in re.findall(
    r'cell\s+\("([^"]+)"\)\s*\{.*?area\s*:\s*([0-9.]+)\s*;',
    lib,
    re.S
):
    areas[cell] = float(area)

with open(NETLIST) as f:
    netlist = f.read()

counts = {}
for cell in areas:
    pattern = r'\b' + re.escape(cell) + r'\b'
    count = len(re.findall(pattern, netlist))
    if count:
        counts[cell] = count

total_cells = sum(counts.values())
total_area = sum(counts[cell] * areas[cell] for cell in counts)

print(f"Mapped standard-cell instances: {total_cells}")
print(f"Total cell area: {total_area:.4f} um^2")
print()
print("Top 15 cells by area contribution:")
for cell, count in sorted(
    counts.items(),
    key=lambda x: x[1] * areas[x[0]],
    reverse=True
)[:15]:
    contribution = count * areas[cell]
    print(f"{cell:40s} {count:5d}  {areas[cell]:10.4f}  {contribution:12.4f}")
