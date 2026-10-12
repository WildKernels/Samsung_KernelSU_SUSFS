#!/usr/bin/env python3
"""Reshape 6.12 sublevel 92+ show_smaps_rollup to the pre-refactor shape, and
back again after the SUSFS patch has been applied.

WHY: the SUSFS patch's two show_smaps_rollup hunks are written against the older
loop:

    vma_start = vma->vm_start;
    do {
            smap_gather_stats(vma, &mss, 0);
            last_vma_end = vma->vm_end;
            ...
            /* Case 4 above */
            if (vma->vm_end > last_vma_end) {
                    smap_gather_stats(vma, &mss, last_vma_end);
                    last_vma_end = vma->vm_end;
            }
    } for_each_vma(vmi, vma);

Sublevel 92 (2026-09) and lts replaced that with proc_maps_locking_ctx /
proc_get_vma() / smap_gather_stats_range(). `apply` puts the old shape back so
patch's hunks match; `revert` restores the 92 form afterwards. Nothing compiles
between the two, so the old 3-arg smap_gather_stats(vma, &mss, start) call that
patch introduces is never built or executed - it only has to satisfy patch's
context matching. The guard the patch adds is preserved across the revert.

Usage: susfs_fake_612.py <task_mmu.c> apply|revert
"""
import sys

MARK = "/* Fake-patch marker for 6.12 sublevel 92+ show_smaps_rollup reshape. */"

# --- APPLY: 92 form -> pre-refactor form -------------------------------

A_NEW_LOOP = """\tif (!IS_ERR(vma))
\t\tvma_start = vma->vm_start;

\twhile (vma) {
\t\tif (IS_ERR(vma)) {
\t\t\tret = PTR_ERR(vma);
\t\t\tgoto out_unlock;
\t\t}

\t\tif (vma->vm_start < last_vma_end) {
\t\t\t/*
\t\t\t * After retaking the lock, already reported VMA grew
\t\t\t * or got merged with the next one and we found it
\t\t\t * again. Gather stats for the remaining portion by
\t\t\t * starting at last_vma_end.
\t\t\t */
\t\t\tsmap_gather_stats_range(priv, vma, &mss, last_vma_end);
\t\t} else {
\t\t\t/* Found next unreported VMA, start from its beginning */
\t\t\tsmap_gather_stats(priv, vma, &mss);
\t\t}
\t\tlast_vma_end = vma->vm_end;
"""

A_OLD_LOOP = """\tvma_start = vma->vm_start;
\tdo {
\t\tsmap_gather_stats(vma, &mss, 0);
\t\tlast_vma_end = vma->vm_end;
""" + MARK + "\n"

A_NEW_TAIL = """\t\t\tpos = last_vma_end;
\t\t\tvma_iter_init(&priv->iter, mm, pos);
\t\t}
\t\tvma = proc_get_vma(m, &pos);
\t}
"""

A_OLD_TAIL = """\t\t\tpos = last_vma_end;
\t\t\tvma_iter_init(&priv->iter, mm, pos);
\t\t}
\t\t\t/* Case 4 above */
\t\t\tif (vma->vm_end > last_vma_end) {
\t\t\t\tsmap_gather_stats(vma, &mss, last_vma_end);
\t\t\t\tlast_vma_end = vma->vm_end;
\t\t\t}
\t\t\tvma = proc_get_vma(m, &pos);
\t} for_each_vma(vmi, vma);
"""

# --- REVERT: post-patch text -> 92 form -------------------------------
# The patch interleaved its SUS_MAP guards into both regions, so the revert
# matches the guarded form and re-emits the guards into the 92 shape.

R_NEW_LOOP = """\tvma_start = vma->vm_start;
\tdo {
#ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\tif (vma->vm_file && SUSFS_IS_INODE_SUS_MAP(file_inode(vma->vm_file)))
\t\t\tgoto bypass_orig_flow;
#endif // #ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\tsmap_gather_stats(vma, &mss, 0);
#ifdef CONFIG_KSU_SUSFS_SUS_MAP
bypass_orig_flow:
#endif // #ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\tlast_vma_end = vma->vm_end;
""" + MARK + "\n"

R_OLD_LOOP = """\tif (!IS_ERR(vma))
\t\tvma_start = vma->vm_start;

\twhile (vma) {
\t\tif (IS_ERR(vma)) {
\t\t\tret = PTR_ERR(vma);
\t\t\tgoto out_unlock;
\t\t}

#ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\tif (vma->vm_file && SUSFS_IS_INODE_SUS_MAP(file_inode(vma->vm_file)))
\t\t\tgoto bypass_orig_flow_rollup;
#endif // #ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\tif (vma->vm_start < last_vma_end) {
\t\t\t/*
\t\t\t * After retaking the lock, already reported VMA grew
\t\t\t * or got merged with the next one and we found it
\t\t\t * again. Gather stats for the remaining portion by
\t\t\t * starting at last_vma_end.
\t\t\t */
\t\t\tsmap_gather_stats_range(priv, vma, &mss, last_vma_end);
\t\t} else {
\t\t\t/* Found next unreported VMA, start from its beginning */
\t\t\tsmap_gather_stats(priv, vma, &mss);
\t\t}
#ifdef CONFIG_KSU_SUSFS_SUS_MAP
bypass_orig_flow_rollup:
#endif // #ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\tlast_vma_end = vma->vm_end;
"""

R_NEW_TAIL = """\t\t\t/* Case 4 above */
\t\t\tif (vma->vm_end > last_vma_end) {
#ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\t\t\tif (!vma->vm_file || !(SUSFS_IS_INODE_SUS_MAP(file_inode(vma->vm_file)))) {
\t\t\t\t\tsmap_gather_stats(vma, &mss, last_vma_end);
\t\t\t\t\tlast_vma_end = vma->vm_end;
\t\t\t\t}
#else
\t\t\t\tsmap_gather_stats(vma, &mss, last_vma_end);
\t\t\t\tlast_vma_end = vma->vm_end;
#endif // #ifdef CONFIG_KSU_SUSFS_SUS_MAP
\t\t\t}
\t\t\tvma = proc_get_vma(m, &pos);
\t} for_each_vma(vmi, vma);
"""

R_OLD_TAIL = """\t\tvma = proc_get_vma(m, &pos);
\t}
"""

PAIRS = {
    "apply": [(A_NEW_LOOP, A_OLD_LOOP, "loop"), (A_NEW_TAIL, A_OLD_TAIL, "tail")],
    "revert": [(R_NEW_LOOP, R_OLD_LOOP, "loop"), (R_NEW_TAIL, R_OLD_TAIL, "tail")],
}


def main():
    if len(sys.argv) != 3 or sys.argv[2] not in PAIRS:
        print("usage: susfs_fake_612.py <file> apply|revert", file=sys.stderr)
        return 2
    path, mode = sys.argv[1], sys.argv[2]

    with open(path, encoding="utf-8", errors="surrogateescape") as fh:
        src = fh.read()

    changed = False
    for frm, to, label in PAIRS[mode]:
        n = src.count(frm)
        if n == 1:
            src = src.replace(frm, to)
            changed = True
        elif n > 1:
            print(f"susfs-fake-612: {mode} {label} anchor found {n} times "
                  f"(expected 1)", file=sys.stderr)
            return 1
        elif MARK not in src:
            print(f"susfs-fake-612: {mode} {label} anchor not found and no "
                  f"marker present; tree is not in the expected state",
                  file=sys.stderr)
            return 1

    if changed:
        with open(path, "w", encoding="utf-8", errors="surrogateescape") as fh:
            fh.write(src)
    print(f"susfs-fake-612: {mode} changed={changed}")
    return 0


if __name__ == "__main__":
    sys.exit(main())