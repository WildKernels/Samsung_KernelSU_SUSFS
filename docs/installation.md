# Installation

> [!CAUTION]
> Wild Kernels is not responsible for bricked devices or damage. By flashing, you assume all risk. Back up your data and understand the risks before flashing.

## Choose your method

| Method | When to use | Requires root | Guide |
|--------|-------------|---------------|-------|
| **Custom Recovery** | Flash AnyKernel3 ZIP for your model/OneUI branch | No (unlocked bootloader) | See below |
| **Kernel Flasher** | Upgrading with root already available, no PC needed | Yes | [Kernel Flasher](https://github.com/fatalcoder524/KernelFlasher) |

## Prerequisites

- [ ] Samsung device with an unlocked bootloader
- [ ] Full backup (at minimum the `boot` partition or have a stock unmodified `boot.img`/`AP` tar)
- [ ] Correct AnyKernel3 ZIP for your model/OneUI branch from [Releases](https://github.com/WildKernels/Samsung_KernelSU_SUSFS/releases)

### Supported branches

Samsung branches are per model + OneUI version (e.g. `SM-S938B-Oneui8.5`, `SM-S928B-Oneui7`, `SM-A546B-Oneui7`). See the matrix in [`.github/workflows/kernel-samsung.yml`](../.github/workflows/kernel-samsung.yml) for the full list. Match exactly to your device/OneUI version.

## Flashing via recovery

1. Download the AnyKernel3 ZIP matching your `BRANCH` (model + OneUI) and desired variant (KSUN/KSU/RESUKISU + features).
2. Boot to custom recovery (TWRP/OrangeFox).
3. Flash the ZIP — AnyKernel3 will patch the boot image in place.
4. Reboot to system.

For GKI generic instructions and manager setup, see also [GKI Installation Guide](https://github.com/WildKernels/GKI_KernelSU_SUSFS/blob/dev/docs/installation.md).

## After flashing

- Install your root manager (KernelSU-Next / KernelSU / ReSukiSU manager matching the flavor you flashed).
- If you flashed with SUSFS, install the SUSFS module: [sidex15/susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module) and verify hiding.
- Check KernelSU app shows working, and test root with a root checker.

---

> [!NOTE]
> Portions of this documentation are adapted from the official [KernelSU documentation](https://kernelsu.org/).
