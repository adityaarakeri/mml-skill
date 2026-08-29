#!/usr/bin/env python3
"""Regenerate references/elements.md from the official MML XSD.

Usage:
  python3 scripts/generate-elements-reference.py path/to/mml/packages/schema/src/schema-src/mml.xsd
"""
import re, sys, os
import xml.etree.ElementTree as ET

ns = {'xs': 'http://www.w3.org/2001/XMLSchema'}

def doc(e):
    d = e.find('xs:annotation/xs:documentation', ns)
    return re.sub(r'\s+', ' ', d.text).strip() if d is not None and d.text else ''

def appinfo(e):
    a = e.find('xs:annotation/xs:appinfo', ns)
    return a.text.strip() if a is not None and a.text else ''

def main(xsd):
    r = ET.parse(xsd).getroot()
    out = ["# MML element and attribute reference", "",
           "Generated from the official `mml.xsd` schema in the mml-io/mml repository. Attribute groups are shared sets of attributes that several elements reuse. Each element section lists which groups it uses plus its own attributes.",
           "", "## Shared attribute groups", ""]
    for g in r.findall('xs:attributeGroup', ns):
        out.append(f"### {g.get('name')}\n\n{doc(g)}\n")
        out.append("| attribute | type | description |\n|---|---|---|")
        for a in g.findall('xs:attribute', ns):
            ai = appinfo(a); extra = f" (event: `{ai}`)" if ai else ""
            out.append(f"| `{a.get('name')}` | {a.get('type')} | {doc(a)}{extra} |")
        out.append("")
    out.append("## Elements\n")
    for el in r.findall('xs:element', ns):
        out.append(f"### `<{el.get('name')}>`\n\n{doc(el)}\n")
        ct = el.find('xs:complexType', ns)
        if ct is None:
            continue
        grs = [g.get('ref') for g in ct.findall('.//xs:attributeGroup', ns)]
        if grs:
            out.append("Uses attribute groups: " + ", ".join(f"`{g}`" for g in grs) + "\n")
        attrs = ct.findall('.//xs:attribute', ns)
        if attrs:
            out.append("| attribute | type | description |\n|---|---|---|")
            for a in attrs:
                ty = a.get('type') or ''
                st = a.find('xs:simpleType/xs:restriction', ns)
                if st is not None:
                    vals = [e.get('value') for e in st.findall('xs:enumeration', ns)]
                    if vals:
                        ty = "one of: " + ", ".join(vals)
                ai = appinfo(a); extra = f" (event: `{ai}`)" if ai else ""
                out.append(f"| `{a.get('name')}` | {ty} | {doc(a)}{extra} |")
            out.append("")
        ch = ct.findall('.//xs:element', ns)
        if ch:
            out.append("Allowed children: " + ", ".join(f"`<{c.get('ref') or c.get('name')}>`" for c in ch) + "\n")
    dest = os.path.join(os.path.dirname(__file__), '..', 'references', 'elements.md')
    with open(dest, 'w') as f:
        f.write("\n".join(out))
    print(f"wrote {dest}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(__doc__); sys.exit(1)
    main(sys.argv[1])
