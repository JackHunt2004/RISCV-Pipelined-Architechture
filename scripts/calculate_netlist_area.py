import re

netlist = "netlist/m4_exp2/riscv_core_exp2_m4.v"
liberty = "/home/jackhunt2004/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

with open(liberty) as f:
    lib = f.read()

areas = dict(re.findall(
    r'cell\s+\("([^"]+)"\)\s*\{.*?^\s*area\s*:\s*([0-9.]+);',
    lib,
    re.S | re.M
))

with open(netlist) as f:
    text = f.read()

cells = re.findall(
    r'\bsky130_fd_sc_hd__[A-Za-z0-9_]+\s+\S+\s*\(',
    text
)

total = 0.0
matched = 0

for cell in cells:
    cell = cell.split()[0]
    if cell in areas:
        total += float(areas[cell])
        matched += 1

print(f"Mapped standard-cell instances: {len(cells)}")
print(f"Cells matched to Liberty: {matched}")
print(f"Total cell area: {total:.4f} um^2")
