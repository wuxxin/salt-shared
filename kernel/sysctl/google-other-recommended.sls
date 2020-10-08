{# https://cloud.google.com/compute/docs/images/building-custom-os#kernelsecurity #}


# Provide protection from ToCToU races
fs.protected_hardlinks:
  sysctl.present:
    - value: 1

# Provide protection from ToCToU races
fs.protected_symlinks:
  sysctl.present:
    - value: 1

# Randomize addresses of mmap base, heap, stack and VDSO page
kernel.randomize_va_space:
  sysctl.present:
    - value: 2

# Make locating kernel addresses more difficult
kernel.kptr_restrict:
  sysctl.present:
    - value: 1

# Set ptrace protections
kernel.yama.ptrace_scope:
  sysctl.present:
    - value: 1

# Set perf only available to root
kernel.perf_event_paranoid:
  sysctl.present:
    - value: 2
