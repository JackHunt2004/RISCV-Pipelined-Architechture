import re

src = "netlist/sta/riscv_core_baseline_sta.v"
dst = "/tmp/riscv_core_baseline_sta_opensta_final.v"

with open(src, "r") as f:
    lines = f.readlines()

out = []
i = 0
count = 0

while i < len(lines):
    if r"\$mux" in lines[i]:
        block = lines[i]
        i += 1

        while i < len(lines):
            block += lines[i]
            if ");" in lines[i]:
                i += 1
                break
            i += 1

        name = re.search(r"\)\s*([^\s(]+)\s*\(", block)
        a = re.search(r"\.A\s*\(\s*([^)]*)\s*\)", block)
        b = re.search(r"\.B\s*\(\s*([^)]*)\s*\)", block)
        s = re.search(r"\.S\s*\(\s*([^)]*)\s*\)", block)
        y = re.search(r"\.Y\s*\(\s*([^)]*)\s*\)", block)

        if not all([name, a, b, s, y]):
            raise RuntimeError("Could not parse mux:\n" + block)

        out.append(
            f"""  sky130_fd_sc_hd__mux2_1 {name.group(1)} (
    .A0({a.group(1).strip()}),
    .A1({b.group(1).strip()}),
    .S({s.group(1).strip()}),
    .X({y.group(1).strip()})
  );
"""
        )
        count += 1
    else:
        out.append(lines[i])
        i += 1

print(f"Converted muxes: {count}")

if count != 1528:
    raise RuntimeError(
        f"Expected 1528 muxes, but converted {count}"
    )

with open(dst, "w") as f:
    f.writelines(out)

print(f"Wrote: {dst}")
