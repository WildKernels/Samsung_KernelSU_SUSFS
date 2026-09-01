<div align="center">

# 🔥 Wild Kernels for Samsung

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Third-Party Notices](https://img.shields.io/badge/notices-THIRD__PARTY_NOTICES-lightgrey.svg)](THIRD_PARTY_NOTICES.md)
[![KernelSU](https://img.shields.io/badge/KernelSU-Supported-green)](https://kernelsu.org/)
[![SUSFS](https://img.shields.io/badge/SUSFS-Integrated-orange)](https://gitlab.com/simonpunk/susfs4ksu)

</div>

> [!CAUTION]
> Wild Kernels is not responsible for bricked devices or damage. By flashing, you assume all risk. Back up your data and understand the risks before flashing.

---

## About

Samsung kernels built on [Samsung's sources](https://github.com/WildKernels/manifest) with KernelSU and SUSFS for root hiding and detection evasion — per-model branches (OneUI) built from Samsung manifests. Now with multiple root-implementation flavors.

---

## Features

- **KernelSU / KernelSU-Next / ReSukiSU** — root implementations
- **susfs4ksu** — root hiding (incl. Ptrace Leak Fix, Unicode Fix)
- **NoMount / Mountify** — mount metamodules
- **Baseband Guard** — partition protection
- **Networking** — WireGuard, BBR, IPSet, CIFS
- **TMPFS** — xattr / POSIX ACLs
- **BPF** — BTF / eBPF / FUSE-BPF
- **Performance** — incl. NTSync
- **DroidSpaces** — container runtime

> [!TIP]
> Full documentation: [docs/features.md](https://github.com/WildKernels/GKI_KernelSU_SUSFS/blob/main/docs/features.md)

---

## Installation

See **[Installation Guide](https://github.com/WildKernels/GKI_KernelSU_SUSFS/blob/main/docs/installation.md)**.

---

## Supported Devices

Samsung branches are per model + OneUI version (e.g. `SM-S938B-Oneui8.5`, `SM-S928B-Oneui7`). See the matrix in [`.github/workflows/kernel-samsung.yml`](.github/workflows/kernel-samsung.yml) for the full list.

---

## Our Projects

| Device | Repository | Description |
|--------|------------|-------------|
| **Multi** | [GKI_KernelSU_SUSFS](https://github.com/WildKernels/GKI_KernelSU_SUSFS) | Google GKI sources — built to be generic and work across many devices |
| **Pixel** | [Sultan_KernelSU_SUSFS](https://github.com/WildKernels/Sultan_KernelSU_SUSFS) | Custom kernels for specific Pixel devices — built from Sultan sources |
| **Samsung** | [Samsung_KernelSU_SUSFS](https://github.com/WildKernels/Samsung_KernelSU_SUSFS) | Built from Samsung sources and manifest |
| **OnePlus** | [OnePlus_KernelSU_SUSFS](https://github.com/WildKernels/OnePlus_KernelSU_SUSFS) | Built from OnePlus sources and manifest |

---

## Special Thanks

**These amazing people and projects make this possible:**
- **KernelSU** — [tiann](https://github.com/tiann/KernelSU)
- **KernelSU-Next** — [rifsxd](https://github.com/KernelSU-Next/KernelSU-Next)
- **KernelSU-Next SUSFS Fork** — [pershoot](https://github.com/pershoot/KernelSU-Next)
- **ReSukiSU** — [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU)
- **Magic-KSU** — [5ec1cff](https://github.com/5ec1cff/KernelSU)
- **SUSFS** — [simonpunk](https://gitlab.com/simonpunk/susfs4ksu)
- **SUSFS Module** — [sidex15](https://github.com/sidex15)
- **NoMount** — [maxsteeel](https://github.com/maxsteeel/nomount)
- **DroidSpaces-OSS** — [ravindu644](https://github.com/ravindu644/Droidspaces-OSS)
- **Baseband-guard (BBG)** — [vc-teahouse](https://github.com/vc-teahouse/Baseband-guard)
- **Kernel Patches** — [WildKernels/kernel_patches](https://github.com/WildKernels/kernel_patches)
- **AnyKernel3** — [osm0sis](https://github.com/osm0sis/AnyKernel3)
- **Sultan Kernels (Pixel)** — [kerneltoast](https://github.com/kerneltoast)
- **Device Boot Fix** — [Boot fix commit](https://github.com/Anything-at-25-00/android_kernel_common_android12-5.10/commit/2476d262b597fe8af82cfb7aaf96676f51c6b4ed)

**Contributors to this repository:**
[![Contributors](https://contrib.rocks/image?repo=WildKernels/Samsung_KernelSU_SUSFS)](https://github.com/WildKernels/Samsung_KernelSU_SUSFS/graphs/contributors)
Have an idea or improvement in mind? Contributions are always welcome — feel free to open a pull request or share your thoughts!

---

## Community

<div align="center">

[![Telegram Group](https://img.shields.io/badge/Telegram-%40WildKernelsTG-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/WildKernelsTG)
[![Telegram DM](https://img.shields.io/badge/Telegram-%40Jimsterino98-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/Jimsterino98)

</div>

Need help? Open an issue in this repository or reach out on Telegram. Please ask in the [WildKernelsTG group](https://t.me/WildKernelsTG) first for general issues.

---

## Donations

> [!IMPORTANT]
> **Kind note:** A donation is truly just a gift — not a payment for support, features, or priority. It doesn't unlock anything extra on our side and doesn't change how we help you; everyone gets the same community support whether you donate or not. Think of it as a kind “thank you” to help keep development going — not a transaction. If you do choose to give, we're genuinely grateful, but please never feel obligated.

- PayPal: [paypal.me/NgadhnjimHoxha](paypal.me/NgadhnjimHoxha)
- Wise: [wise.com/pay/me/ngadhnjimh](wise.com/pay/me/ngadhnjimh)
- Ko-fi: [https://ko-fi.com/jimsterino98](https://ko-fi.com/jimsterino98)
- Buy me a coffee: [buymeacoffee.com/jimsterino98](buymeacoffee.com/jimsterino98)
- Crypto: DM on Telegram for crypto donations!
