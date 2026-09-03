# 50-experiments index
- [[exp-0001-proxy-detection|EXP-0001]] 2.1.91 static — DEMONSTRATED: obfuscated proxy/lab detection + prompt steganography (supports CLM-0003, CLM-0011)
- [[exp-0002-native-binary-telemetry|EXP-0002]] 2.1.196+2.1.246 static — SPLIT: mechanism byte-equivalent in 196, REMOVED in 246 (extends CLM-0011, new CLM-0012)
- EXP-0003 2026-08-26 static cold re-run (ses-0005) — POSITIVE x3: quota probe / anti-distillation fake_tools / token-budget auto-continue → CLM-0015/16/19 g4 (logs raw/exp-logs-orcrist-tree-audit-2026-08-24)
- EXP-0004 2026-08-26 static (ses-0005) — PARTIAL/SCOPE-CORRECTED: policy channel real (1h poll, ETag cache) but enforced keys exhaustively = allow_remote_control/allow_remote_sessions/allow_product_feedback only → CLM-0014 superseded by CLM-0020 g4
- EXP-0005 2026-08-26 static (ses-0005) — NEGATIVE: no hidden YOLO/Haiku judge; CLM-0013 g3→g2
- EXP-0006 2026-08-26 static recount (ses-0005) — dormancy counts recorded; 108-figure demoted (CLM-0017 verified-partial, CLM-0018 noted)
- [[exp-0007|EXP-0007]] 2026-09-02 dynamic offline e2e (ses-0006) — SUPPORTS CLM-0020 g4: fake localhost policy server + genuine held-tree service; fetch/parse/cache/apply + 1h poll + ETag 304 + corrected-key decisions demonstrated; refuted keys have zero callsites
