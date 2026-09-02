import re

src = "netlist/sta/riscv_core_exp2_sta.v"
dst = "/tmp/riscv_core_exp2_sta_opensta_final.v"

with open(src, "r") as f:
    text = f.read()

pattern = re.compile(
    r'\\\$mux\s*#\(\s*'
    r'\.WIDTH\(32\'d1\)\s*'
    r'\)\s*(\S+)\s*\(\s*'
    r'\.A\(([^)]+)\),\s*'
    r'\.B\(([^)]+)\),\s*'
    r'\.S\(([^)]+)\),\s*'
    r'\.Y\(([^)]+)\)\s*'
    r'\);',
    re.MULTILINE
)

def replace_mux(match):
    cell = match.group(1)
    a = match.group(2)
    b = match.group(3)
    s = match.group(4)
    y = match.group(5)

    return (
        f"sky130_fd_sc_hd__mux2_1 {cell} ("
        f".A0({a}), .A1({b}), .S({s}), .X({y})"
        f");"
    )

text, count = pattern.subn(replace_mux, text)

with open(dst, "w") as f:
    f.write(text)

print(f"Converted muxes: {count}")
print(f"Wrote: {dst}")
