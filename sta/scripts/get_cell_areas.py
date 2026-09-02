import re

lib = "/home/jackhunt2004/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

cells = [
    "sky130_fd_sc_hd__dfxtp_1",
    "sky130_fd_sc_hd__mux2_1",
    "sky130_fd_sc_hd__mux2i_1",
    "sky130_fd_sc_hd__mux4_2",
]

with open(lib, "r") as f:
    text = f.read()

for cell in cells:
    pattern = rf'cell \("{re.escape(cell)}"\) \{{(.*?)\n    \}}'
    match = re.search(pattern, text, re.DOTALL)

    if not match:
        print(f"{cell}: NOT FOUND")
        continue

    area = re.search(r'^\s*area\s*:\s*([0-9.]+);', match.group(1), re.MULTILINE)

    if area:
        print(f"{cell}: {area.group(1)}")
    else:
        print(f"{cell}: AREA NOT FOUND")
