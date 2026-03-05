#include "vm/qemuargs.h"

#include <QTest>

#include <algorithm>

namespace {

QemuConfig baseConfig()
{
    QemuConfig config;
    config.isoPath = "/isos/mint.iso";
    config.accelerator = "kvm";
    config.ramMb = 4096;
    config.cpus = 4;
    config.title = "Linux Mint 22.2 in Testux";
    return config;
}

} // namespace
