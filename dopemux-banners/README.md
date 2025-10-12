# Dopemux Banner Mapping

| Banner File | When to Output |
|-------------|----------------|
| `system_boot_unicode.txt` | On system/CLI start |
| `ultraslicer_max_context.txt` | When starting extraction or chunking |
| `dopamine_hit.txt` | On successful block or test pass |
| `context_drift.txt` | On error or drift |
| `atomic_pr.txt` | At PR creation |
| `ascii_fallback.txt` | When Unicode is not supported |
| `ansi_color_examples.py` | Example for colorized banners |
| `roast_lines.txt` | Roast lines for failures |
| `color_protocol.md` | Color troubleshooting |

```python
def print_banner(filename):
    with open(filename) as f:
        print(f.read())
```
